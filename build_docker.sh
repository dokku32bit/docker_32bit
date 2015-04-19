#!/bin/bash
set -e
if [ -z "$1" ]; then
	echo "no version number provided, exiting..."
	exit 1
fi

VERSION=$1
rm -rf /tmp/build_docker
mkdir -p /tmp/build_docker
cd /tmp/build_docker
echo "Installing base dependencies . . ."

sudo apt-get update
sudo apt-get -y install aufs-tools automake btrfs-tools build-essential \
			wget dpkg-sig git iptables libapparmor-dev libcap-dev  btrfs-tools\
			libsqlite3-dev lxc mercurial parallel reprepro ruby1.9.1 uuid-dev \
			ruby1.9.1-dev pkg-config libpcre* nano git bzr ca-certificates \
			libblkid-dev asciidoc xmlto libattr1-dev libblkid-dev liblzo2-dev \
			zlib1g-dev libacl1-dev e2fslibs-dev \
			--no-install-recommends
			
echo "Compiling Go . . ."
mkdir -p /tmp/build_docker/goroot
wget -qO- https://storage.googleapis.com/golang/go1.4.linux-386.tar.gz | tar xzf - -C /tmp/build_docker/goroot --strip-components=1
mkdir -p /tmp/build_docker/gopath
export GOPATH=/tmp/build_docker/gopath
export GOROOT=/tmp/build_docker/goroot
export PATH=$GOPATH/bin:$PATH:$GOROOT/bin
export AUTO_GOPATH=1
cd /tmp/build_docker

echo "Compiling lvm2 . . ."
git clone https://git.fedorahosted.org/git/lvm2.git
cd lvm2
(git checkout -q v2_02_103 && ./configure --enable-static_link && make device-mapper && make install_device-mapper && echo lvm build OK!) || (echo lvm2 build failed && exit 1)
cd /tmp/build_docker


echo "providing btrfs driver"
# can not use latest tag, version mismatch for docker 1.6
git clone --branch v3.17 git://git.kernel.org/pub/scm/linux/kernel/git/kdave/btrfs-progs.git
mv btrfs-progs btrfs 
export PATH=$(pwd):$PATH
cd btrfs
export PATH=$(pwd):$PATH
make || (echo "btrfs compile failed" && exit 1) 
make install
export C_INCLUDE_PATH=$C_INCLUDE_PATH:$(pwd) 
export CPLUS_INCLUDE_PATH=$CPLUS_INCLUDE_PATH:$(pwd) 
echo PATH: $PATH
cd /tmp/build_docker


echo "Compiling Docker . . ."
export DOCKER_GITCOMMIT="i386"
mkdir -p $GOPATH/src/github.com/docker/docker
if [ "$VERSION" != "dev" ]; then
	wget -qO- https://github.com/docker/docker/archive/v${VERSION}.tar.gz | tar xfz - -C $GOPATH/src/github.com/docker/docker --strip-components=1
else
	git clone https://github.com/docker/docker $GOPATH/src/github.com/docker/docker
fi
for f in `grep -r "if runtime.GOARCH \!\= \"amd64\" {" $GOPATH/src/* | cut -d: -f1`; do
	echo "Patching $f"
	sed -i 's/if runtime.GOARCH != "amd64" {/if runtime.GOARCH != "amd64" \&\& runtime.GOARCH != "386" {/g' $f
done

cd $GOPATH/src/github.com/docker/docker/
./hack/make.sh binary
if [ "$VERSION" != "dev" ]; then
	cd $GOPATH/src/github.com/docker/docker/bundles/${VERSION}/binary && tar cfz /tmp/docker-${VERSION}.tar.gz * 
else 
	cd $GOPATH/src/github.com/docker/docker/bundles/latest/binary && tar cfz /tmp/docker-${VERSION}.tar.gz * 
fi
echo "finished"