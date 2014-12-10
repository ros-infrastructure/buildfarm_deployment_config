#!/bin/bash

set -o errexit

BUILDFARM_DEPLOYMENT_PATH=/root/buildfarm_deployment
BUILDFARM_DEPLOYMENT_URL=https://github.com/ros-infrastructure/buildfarm_deployment.git
BUILDFARM_DEPLOYMENT_BRANCH=new_config

if [ ! -d $1 ]; then
  echo "$1 is not a valid subdirectory"
  return 1
fi

cp $1/hiera.yaml /etc/puppet
mkdir -p /etc/puppet/hieradata
cp $1/common.yaml /etc/puppet/hieradata


if [ ! -d /root/buildfarm_deployment ]; then
  git clone $BUILDFARM_DEPLOYMENT_URL /root/buildfarm_deployment -b $BUILDFARM_DEPLOYMENT_BRANCH
  # todo make this more robust to changing prerequisites
  $BUILDFARM_DEPLOYMENT_PATH/$1/install_prerequisites.bash
fi



cd $BUILDFARM_DEPLOYMENT_PATH && git fetch origin && git reset --hard $BUILDFARM_DEPLOYMENT_BRANCH
puppet apply -v $BUILDFARM_DEPLOYMENT_PATH/master/manifests/site.pp --modulepath=/etc/puppet/modules:/usr/share/puppet/modules:$BUILDFARM_DEPLOYMENT_PATH/$1 -l /var/log/puppet.log
