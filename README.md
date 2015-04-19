docker 32bit
===================

The scripts in this repository ease up the process of building 32bit docker binary files.
Current docker version: __1.6.0__

#### build with vagrant
Simply go into the folder with the scripts and start the vagrant box via `vagrant up`.
The box will provision the script itself, download requirements and build it.

You can remove the vagrant box after completion with `vagrant destroy`

#### build with lxc
You need to install lxc on your system first (required for running docker later on)
Once lxc is installed, enter the directory and run `./lxc_build_docker.sh`

When asked for a password, use _ubuntu_ 
If you want to remove the lxc container afterwards, type `lxc-destroy -n ubuntu_docker`

#### build a different version
Change the version number in the file VERSION. For current releases check the [official release page](https://github.com/docker/docker/releases)
The script expects the version with the leading 'v'

If you want to build the latest github version, replace the version number with 'dev'

#### pre built versions
A couple of pre-compiled versions can be found in the [dist branch](https://github.com/dokku32bit/docker_32bit/tree/dist/dist)
Direct links:
* [docker-v1.6.0](https://github.com/dokku32bit/docker_32bit/raw/dist/dist/docker-1.6.0.tar.gz)
* [docker-v1.5.0](https://github.com/dokku32bit/docker_32bit/raw/dist/dist/docker-1.5.0.tar.gz)
* [docker-v1.4.1](https://github.com/dokku32bit/docker_32bit/raw/dist/dist/docker-1.4.1.tar.gz)

#### 32bit docker images
Resources for 32bit docker images are:
* https://github.com/docker-32bit
* https://registry.hub.docker.com/repos/32bit/


#### Acknowledgements
Basis for the buildscripts were provided by [blenderfox](http://blenderfox.com/2014/09/14/building-docker-io-on-32-bit-arch/) 
Also thanks to [M whiteley](http://mwhiteley.com/linux-containers/2013/08/31/docker-on-i386.html) for exploring the idea already in 2013




