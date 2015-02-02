FROM ubuntu:trusty
MAINTAINER "Tully Foote" <tfoote@@osrfoundation.org>

RUN apt-get update && apt-get dist-upgrade -y

# Prerequisites implicitly installed, but explicit allows docker caching
RUN apt-get update && apt-get install -y git wget openjdk-7-jdk ca-certificates
# installing here to leverage docker caching (will be enforced by puppet later)
RUN apt-get update && apt-get install -y curl python3-yaml python3-empy apt-transport-https bzr mercurial
RUN apt-get update && apt-get install -y apparmor cgroup-lite ntp openssh-server python-yaml python-configparser

# Docker specific changes.

# Inject wrapdocker needed for docker in docker dind
ADD wrapdocker /tmp/wrapdocker
# XXX: Workaround for https://github.com/docker/docker/issues/6345
RUN ln -s -f /bin/true /usr/bin/chfn


# Install tools needed to bootstrap
ADD install_prerequisites.bash /tmp/install_prerequisites.bash
RUN /tmp/install_prerequisites.bash

ADD @(folder) /root/buildfarm_deployment_config/@(folder)
ADD reconfigure.bash /root/buildfarm_deployment_config/reconfigure.bash

WORKDIR /root/buildfarm_deployment_config
RUN ./reconfigure.bash @(folder)


VOLUME /var/lib/docker
ENV DOCKER_DAEMON_ARGS --storage-driver=devicemapper
# dmsetup needed to initialize devicemapper
@[if folder == 'master' ]@
EXPOSE 8080
CMD bash -c 'service jenkins start && service jenkins-slave start && dmsetup mknodes && /tmp/wrapdocker && while true; do sleep 1; done'
@[end if]@
@[if folder == 'slave']@
CMD bash -c '/etc/init.d/jenkins-slave start && dmsetup mknodes && /tmp/wrapdocker && while true; do sleep 1; done'
@[end if]
@[if folder == 'repo']@
CMD bash -c 'service ssh start && service apache2 start && /etc/init.d/jenkins-slave start && dmsetup mknodes && /tmp/wrapdocker && while true; do sleep 1; done'
@[end if]@
