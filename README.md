

Master deployment

    sudo su root
    cd
    apt-get update
    apt-get install -y git

    # Customize this URL for your fork
    git clone https://github.com/tfoote/buildfarm_deployment_config.git
    cd buildfarm_deployment_config
    ./reconfigure.bash master
