#!/bin/bash

set -o errexit

apt-get update
apt-get install -y ruby ruby1.9.1-dev make
# hold puppet version down, not all modules work with 4.0
gem install puppet -v 3.7 --no-rdoc --no-ri
get installl librarian-puppet --no-rdoc --no-ri

# config for librarian for more efficient syncronization
librarian-puppet config rsync true --global
