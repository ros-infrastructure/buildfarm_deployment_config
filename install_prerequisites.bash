#!/bin/bash

set -o errexit

apt-get update
apt-get install -y ruby ruby-dev make
# hold json_pure down, 2.0 requires ruby 2.0
gem install json_pure -v 1.8.3 --no-rdoc --no-ri
# hold puppet version down, not all modules work with 4.0
#gem install puppet -v 3.7 --no-rdoc --no-ri
apt-get install -y puppet
gem install librarian-puppet --no-rdoc --no-ri
gem install syck --no-rdoc --no-ri # https://github.com/dtao/safe_yaml/issues/76

# install pip3 via pypi to avoid https://github.com/ros-infrastructure/buildfarm_deployment/issues/64

apt-get install -y python3-pip puppet
#pip3 install -U pip

# config for librarian for more efficient syncronization
librarian-puppet config rsync true --global
