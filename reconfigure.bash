#!/bin/bash

set -o errexit

BUILDFARM_DEPLOYMENT_PATH=/root/buildfarm_deployment
BUILDFARM_DEPLOYMENT_URL=https://github.com/nuclearsandwich/buildfarm_deployment.git
BUILDFARM_DEPLOYMENT_BRANCH=xenialize
if [ -z $1 ]; then
  echo "No role specified."
  return 1
fi

buildfarm_role="$1"

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
  --modulepath=$BUILDFARM_DEPLOYMENT_PATH \
  --logdest /var/log/puppet.log \
  -e "include role::buildfarm::${buildfarm_role}" \
  || { r=$?; echo "puppet failed, please check /var/log/puppet.log, the last 10 lines are:"; tail -n 10 /var/log/puppet.log; exit $r; }
