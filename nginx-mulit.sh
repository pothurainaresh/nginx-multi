#!/bin/bash

# Determine which distribution we're running on
if [[ $(lsb_release -d) == *CentOS* ]]; then
    distro=centos
elif [[ $(cat /etc/os-release) == *CentOS* ]]; then
    distro=centos
elif [[ $(cat /etc/os-release) == *Amazon* ]]; then
    distro=amazon	
elif [[ $(cat /etc/os-release) == *Red\ Hat* ]]; then
    distro=rhel
else
    echo "Unsupported distribution."
    exit 1
fi

# Install Nginx
if [ "$distro" = "ubuntu" ]; then
    apt-get update
    apt-get -y install nginx
elif [ "$distro" = "centos" ] || [ "$distro" = "rhel" ] ||[ "$distro" = "amazon" ]; then
    yum update
    yum -y install nginx
fi

# Start Nginx
systemctl start nginx

# Enable Nginx to start on boot
systemctl enable nginx

