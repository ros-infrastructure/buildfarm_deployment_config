#!/bin/bash

set -o errexit

apt-get update
apt-get install -y ruby ruby1.9.1-dev
gem install puppet librarian-puppet --no-rdoc --no-ri

# config for librarian for more efficient syncronization
librarian-puppet config rsync true --global
