#!/bin/bash

git submodule init
git submodule sync
git submodule update

# local.conf won't exist until this step on first execution
source poky/oe-init-build-env

CONFLINE="MACHINE = \"raspberypi5\""

cat conf/local.conf | grep "${CONFLINE}" > /dev/null
local_conf_info=$?

if [ $local_conf_info -ne 0 ];then
	echo "Append ${CONFLINE} in the local.conf file"
	echo ${CONFLINE} >> conf/local.conf
	
else
	echo "${CONFLINE} already exists in the local.conf file"
fi


bitbake-layers show-layers | grep "meta-raspberrypi" > /dev/null
layer_info=$?

if [ $layer_info -ne 0 ];then
	echo "Adding meta-raspberrypi layer"
	bitbake-layers add-layer ../meta-raspberrypi
else
	echo "meta-raspberrypi layer already exists"
fi

set -e
bitbake core-image-minimal
