## Overview

This repository is the entry point for deploying and configuring.




### Forking (or not)

This repository will contain your secrets such as private keys and access tokents you should make a copy of this repository and make it private.
Unfortunately you can't use the "Fork" button on GitHub and then make it private.

To create a private fork.
1. Create a new empty private repo
1. Push from a clone of the public repo into the private repo.

### Access

To give access to your private repo you will need to authenticate.

The below example has setup the config repo with token access.
And embedded the token in the below URLs.
Keep this token secret!

### Updating values

It is recommended to change all the security parameters from this configuratoin.
In particular you should change the following:

On all three:
 * `jenkins::slave::ui_pass`
 * on the master this should be the hashed password from above `user::admin::password_hash`
 * If you don't use the master branch on all machines change: `autoreconfigure::branch`


 On repo:
 * `jenkins-slave::authorized_keys`
 * `jenkins-slave::gpg_public_key`
 * `jenkins-slave::gpg_private_key`
 * `master::ip`

 On the master:
  * `jenkins::authorized_keys`
  * `jenkins::private_ssh_key`
  * `master::ip`
  * `repo::ip`

On the slave:
  * `master::ip`
  * `repo::ip`

## Provisioning

The following EC2 instance types are recommended when deploying to Amazon EC2.<br/>
They are intended as a guideline for choosing the appropriate parameters when deploying to other platforms.

### Master

<table>
<tr><td>Memory</td><td>30Gb</td></tr>
<tr><td>Disk space</td><td>200Gb</td></tr>
<tr><td><strong>Recommendation</strong></td><td>r3.xlarge</td></tr>
</table>

### Slave

<table>
<tr><td>Disk space</td><td>200Gb+</td></tr>
<tr><td><strong>Recommendation</strong></td><td>c3.large or faster</td></tr>
</table>

### Repo

<table>
<tr><td>Disk space</td><td>100Gb</td></tr>
<tr><td><strong>Recommendation</strong></td><td>t2.medium</td></tr>
</table>


## Deployment

Once you have customized all the content of

### Master deployment

    sudo su root
    cd
    apt-get update
    apt-get install -y git

    # Customize this URL for your fork
    git clone https://8d25f41a3ed71b0b9fc571c8a35bcb47fb4f6489@github.com/YOUR_ORG/buildfarm_deployment_config.git
    cd buildfarm_deployment_config
    ./reconfigure.bash master


### repo deployment

    sudo su root
    cd
    apt-get update
    apt-get install -y git

    # Customize this URL for your fork
    git clone https://8d25f41a3ed71b0b9fc571c8a35bcb47fb4f6489@github.com/YOUR_ORG/buildfarm_deployment_config.git
    cd buildfarm_deployment_config
    ./reconfigure.bash repo

### slave deployment

    sudo su root
    cd
    apt-get update
    apt-get install -y git

    # Customize this URL for your fork
    git clone https://8d25f41a3ed71b0b9fc571c8a35bcb47fb4f6489@github.com/YOUR_ORG/buildfarm_deployment_config.git
    cd buildfarm_deployment_config
    ./reconfigure.bash slave

## After Deployment

Now that you have a running system you will need to add jobs for one or more rosdistros.
See the [ros_buildfarm repo](https://github.com/ros-infrastructure/ros_buildfarm) for more info.
