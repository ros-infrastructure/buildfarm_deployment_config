#!/bin/bash

set -o errexit

function usage {
  echo -e "USAGE: $(basename $0) [ROLE]\n"
  echo -e "Where ROLE is one of 'master', 'agent' or 'repo' (without quotes).\n"
  echo -e "The role can be omitted if this script has run previously.\n"
  exit 1
}

BUILDFARM_DEPLOYMENT_PATH=/root/buildfarm_deployment
BUILDFARM_DEPLOYMENT_URL=https://github.com/ros-infrastructure/buildfarm_deployment.git
BUILDFARM_DEPLOYMENT_BRANCH=pre-jep-200

script_dir="$(dirname $0)"

if [[ $# -gt 1 ]]; then
  usage
elif [[ $# -eq 1 ]] && [[ $1 != "master" && $1 != "agent" && $1 != "repo" ]]; then
  usage
elif [[ $# -eq 0 ]] && [[ ! -f "${script_dir}/role" ]]; then
  usage
fi


# Check if a role file exists for the current machine.
if [ -f "${script_dir}/role" ]; then
  buildfarm_role=$(cat "${script_dir}/role")
  if [ $1 != $buildfarm_role ]; then
    echo "ERROR: this machine was previously provisioned as ${buildfarm_role}"
    echo "  To change role to $1 please delete the 'role' file and rerun this command."
    exit 1
  fi
else
  buildfarm_role="$1"
  echo $buildfarm_role > "${script_dir}/role"
fi

if [ ! -d /root/buildfarm_deployment ]; then
  echo "/root/buildfarm_deplyment did not exist, cloning."
  git clone $BUILDFARM_DEPLOYMENT_URL /root/buildfarm_deployment -b $BUILDFARM_DEPLOYMENT_BRANCH
fi

echo "Copying in configuration"
mkdir -p /etc/puppet/hieradata
cp hiera/hiera.yaml /etc/puppet/
cp -r hiera/hieradata/* /etc/puppet/hieradata/

echo "Asserting latest version of $BUILDFARM_DEPLOYMENT_URL as $BUILDFARM_DEPLOYMENT_BRANCH"
cd $BUILDFARM_DEPLOYMENT_PATH && git fetch origin && git reset --hard origin/$BUILDFARM_DEPLOYMENT_BRANCH
echo "Running librarian-puppet"
(cd $BUILDFARM_DEPLOYMENT_PATH/ && librarian-puppet install --verbose)
echo "Running puppet"
env FACTER_buildfarm_role="$buildfarm_role" puppet apply --verbose \
  --parser future \
  --modulepath="${BUILDFARM_DEPLOYMENT_PATH}/modules" \
  --logdest /var/log/puppet.log \
  -e "include role::buildfarm::${buildfarm_role}" \
  || { r=$?; echo "puppet failed, please check /var/log/puppet.log, the last 10 lines are:"; tail -n 10 /var/log/puppet.log; exit $r; }
