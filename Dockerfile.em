FROM ubuntu:trusty
MAINTAINER "Tully Foote" <tfoote@@osrfoundation.org>

RUN apt-get update
RUN apt-get dist-upgrade -y


RUN apt-get install -y ruby
# Prerequisites implicitly installed, but explicit allows docker caching
RUN apt-get install -y git wget openjdk-7-jdk ca-certificates
# installing here to leverage docker caching (will be enforced by puppet later)
RUN apt-get install -y curl python3-pip python3-yaml python3-empy apt-transport-https bzr mercurial
RUN apt-get install -y apparmor cgroup-lite ntp

RUN gem install puppet --no-rdoc --no-ri
RUN puppet module install rtyler/jenkins
RUN puppet module install tracywebtech-pip
RUN puppet module install puppetlabs-ntp


ADD @(folder) /root/buildfarm_deployment_config/@(folder)
ADD reconfigure.bash /root/buildfarm_deployment_config/reconfigure.bash

WORKDIR /root/buildfarm_deployment_config
RUN ./reconfigure.bash @(folder)

EXPOSE 8080

# XXX: Workaround for https://github.com/docker/docker/issues/6345
RUN ln -s -f /bin/true /usr/bin/chfn

VOLUME /var/lib/docker
ENV DOCKER_DAEMON_ARGS --storage-driver=devicemapper
# dmsetup needed to initialize devicemapper
@[if folder == 'master' ]@
CMD bash -c 'service ntp start && service jenkins start && service jenkins-slave start && dmsetup mknodes && /var/lib/jenkins/wrapdocker && while true; do sleep 1; done'
@[end if]@
@[if folder == 'slave']@
CMD bash -c 'service ntp start && /etc/init.d/jenkins-slave start && dmsetup mknodes && /home/jenkins-slave/wrapdocker && while true; do sleep 1; done'
@[end if]
@[if folder == 'repo']@
CMD bash -c 'service ntp start && service ssh start && service apache2 start && /etc/init.d/jenkins-slave start && dmsetup mknodes && /home/jenkins-slave/wrapdocker && while true; do sleep 1; done'
@[end if]@
