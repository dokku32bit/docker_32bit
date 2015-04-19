#!/bin/bash
pushd `dirname $0` > /dev/null
SCRIPTPATH=`pwd -P`
popd > /dev/null
echo $SCRIPTPATH
VERSION=`cat VERSION`

rebuild_lxc () {
	# stop the container if already running
	lxc-stop -n ubuntu_docker

	# destroy the container
	lxc-destroy -n ubuntu_docker

	#create new container with sshkey
	lxc-create --name ubuntu_docker -t ubuntu -- --release trusty –-arch i386
}

echo -n "(Re)build Docker build environment (Y/N)? "
read REPLY
case "$REPLY" in
	Y|y)
		echo Rebuilding docker build environment
		rebuild_lxc
	;;
	N|n|*)
		echo Not rebuilding docker build environment;;
esac

#Start/restart the build container

lxc-stop -n ubuntu_docker
lxc-start -n ubuntu_docker -d
if [ $? -ne 0 ]; then
    echo "not container found - building"
    rebuild_lxc
    lxc-start -n ubuntu_docker -d
fi

#Get the IP address of the container
while [ -z "$(lxc-info -i -n ubuntu_docker)" ]; do
	echo "container not started yet, retrying"
	sleep 5s
done
IP=$(lxc-info -i -n ubuntu_docker | cut -d ':' -f 2 | sort | head -1 | tr -d ' ')
echo Main Container IP: $IP

echo Pushing script to IP $IP
scp -o StrictHostKeyChecking=no $SCRIPTPATH/build.sh ubuntu@$IP:/tmp
while [ $? -ne 0 ]
do
scp -o StrictHostKeyChecking=no $SCRIPTPATH/build.sh ubuntu@$IP:/tmp
done

lxc-attach -n ubuntu_docker '/tmp/build_docker.sh $VERSION'

scp -o StrictHostKeyChecking=no ubuntu@$IP:/tmp/docker-${VERSION}.tar.gz $SCRIPTPATH/docker-${VERSION}.tar.gz

lxc-stop -n ubuntu_docker
