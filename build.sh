#!/bin/bash
# Script to build image for raspberry5.

git submodule init
git submodule sync
git submodule update

# local.conf won't exist until this step on first execution
source poky/oe-init-build-env

CONFLINE="MACHINE = \"raspberrypi5-64\""

cat conf/local.conf | grep "${CONFLINE}" > /dev/null
local_conf_info=$?

if [ $local_conf_info -ne 0 ];then
	echo "Append ${CONFLINE} in the local.conf file"
	echo ${CONFLINE} >> conf/local.conf
	
else
	echo "${CONFLINE} already exists in the local.conf file"
fi


bitbake-layers show-layers | grep "meta-oe" > /dev/null
layer_info=$?

if [ $layer_info -ne 0 ];then
	echo "Adding meta-oe layer"
	bitbake-layers add-layer ../meta-openembedded/meta-oe/
else
	echo "meta-oe layer already exists"
fi

bitbake-layers show-layers | grep "meta-python" > /dev/null
layer_info=$?

if [ $layer_info -ne 0 ];then
	echo "Adding meta-python layer"
	bitbake-layers add-layer ../meta-python
else
	echo "meta-python layer already exists"
fi

bitbake-layers show-layers | grep "meta-networking" > /dev/null
layer_info=$?

if [ $layer_info -ne 0 ];then
	echo "Adding meta-networking layer"
	bitbake-layers add-layer ../meta-networking
else
	echo "meta-networking layer already exists"
fi

bitbake-layers show-layers | grep "meta-multimedia" > /dev/null
layer_info=$?

if [ $layer_info -ne 0 ];then
	echo "Adding meta-multimedia layer"
	bitbake-layers add-layer ../meta-multimedia
else
	echo "meta-multimedia layer already exists"
fi

bitbake-layers show-layers | grep "meta-raspberrypi" > /dev/null
layer_info=$?

if [ $layer_info -ne 0 ];then
	echo "Adding meta-raspberrypi layer"
	bitbake-layers add-layer ../meta-raspberrypi
else
	echo "meta-raspberrypi layer already exists"
fi

bitbake-layers show-layers | grep "meta-tensorflow-lite" > /dev/null
layer_info=$?

if [ $layer_info -ne 0 ];then
	echo "Adding meta-tensorflow-lite layer"
	bitbake-layers add-layer ../meta-tensorflow-lite
else
	echo "meta-tensorflow-lite layer already exists"
fi


# Path to the 'conf/auto.conf' file
FILE="conf/auto.conf"

# Lines to be added
FORTRAN_LINE='FORTRAN:forcevariable = ",fortran"'
MACHINE_LINE='MACHINE ?= "raspberrypi5-64"'
IMAGE_INSTALL_LINE='IMAGE_INSTALL:append = " python3-tensorflow-lite libtensorflow-lite"'

# Function to add a line if it doesn't already exist
add_line_if_not_exists() {
    local line="$1"
    local file="$2"
    grep -qxF "$line" "$file" || echo "$line" >> "$file"
}

# Add the lines to the file
add_line_if_not_exists "$FORTRAN_LINE" "$FILE"
add_line_if_not_exists "$MACHINE_LINE" "$FILE"
add_line_if_not_exists "$IMAGE_INSTALL_LINE" "$FILE"


set -e
bitbake core-image-detection
