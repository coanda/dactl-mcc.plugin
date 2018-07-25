#!/bin/bash

dependencies=(
  libusbx libusbx-devel hidapi hidapi-devel
)

dnf -y install ${dependencies[*]}

CACHEDIR="/var/cache/fedy/dactl-mcc"

mkdir -p $CACHEDIR
cd $CACHEDIR

# Driver and dependency installation
git clone https://github.com/wjasper/Linux_Drivers.git
cp Linux_Drivers/61-mcc.rules /etc/udev/rules.d/
udevadm control --reload && udevadm trigger
cd Linux_Drivers/USB/mcc-libusb
make && make install

cd $CACHEDIR
git clone git://github.com/signal11/hidapi.git
cd hidapi
./bootstrap
./configure
make && sudo make install

cd $CACHEDIR
git clone https://github.com/coanda/mcc-vapi.git
cd mcc-vapi
cp libmccusb.{deps,vapi} /usr/share/vala/vapi/
cp libmccusb.pc /usr/share/pkgconfig/

# Dactl configuration setup
cd $CACHEDIR
git clone https://github.com/coanda/dactl-mcc-config.git
mkdir /usr/local/share/dactl
chown -R `whoami`.$(id -gn `whoami`) /usr/local/share/dactl
chmod -R g+w /usr/share/dactl
cp dactl-mcc-config/dactl.xml /usr/local/share/dactl/

# Dactl plugin installation
cd $CACHEDIR
git clone https://github.com/coanda/dactl-mcc-plugin.git
cd dactl-mcc-plugin
cp vapi/hidapi.vapi /usr/share/vala/vapi/
PKG_CONFIG_PATH=/usr/local/lib64/pkgconfig/ ./autogen.sh
make && make install

sudo mkdir -p /srv/data/dactl
sudo chown -R `whoami`.$(id -gn `whoami`) /srv/data/dactl
chmod -R g+w /srv/data/dactl
cp /usr/local/lib/dactl/plugins/* /usr/local/lib64/dactl/plugins/

# Post install
ldconfig
