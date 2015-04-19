#!/bin/bash
VERSION=`cat /vagrant/VERSION`
sudo cp /vagrant/build_docker.sh /tmp/build_docker.sh
sudo chmod +x /tmp/build_docker.sh
sudo /tmp/build_docker.sh $VERSION &> /vagrant/build.log
sudo mv /tmp/docker-${VERSION}.tar.gz /vagrant
