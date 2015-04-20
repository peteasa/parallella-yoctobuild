#!/bin/bash

echo "Note to set the environment variables run"
echo "  source /opt/poky/1.7/environment-setup-armv7ahf-vfp-neon-poky-linux-gnueabi"
echo "  source setup-epiphany-sdk-in-poky-sdk.sh"

if ! [ -d "/opt/poky" ]
then
  echo
  echo "NOTE: To run this script you must create the yocto SDK including IMAGE_INSTALL += kernel-dev"
  echo "One way to create the SDK is with: bitbake -c populate_sdk hdmi-image"
  echo "    Then install the SDK using the script found at "
  echo "    build_parallella/tmp/deploy/sdk/poky-glibc-x86_64-hdmi-image-debug-armv7ahf-vfp-neon-toolchain-1.7.sh"
  echo
fi

# Test to see if yocto sdk is correctly setup
# Note it is not essential to use /opt/poky/1.7 as the location in 
: ${OECORE_NATIVE_SYSROOT?"Please run: source /opt/poky/1.7/environment-setup-armv7ahf-vfp-neon-poky-linux-gnueabi"}

## This is the location of the epiphany sdk
export EPIPHANY_HOME=${OECORE_NATIVE_SYSROOT}/usr/epiphany/epiphany-sdk
export EPIPHANY_HDF=${EPIPHANY_HOME}/bsps/current/platform.hdf

##
## The end!
##

