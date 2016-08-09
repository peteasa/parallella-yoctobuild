#!/bin/bash

if [[ $_ = $0 ]]
then
  echo "ERROR: to set the environment variables run"
  echo "  source setup-epiphany-sdk-in-poky-sdk.sh"
  [[ $PS1 ]] && return || exit;
fi

if ! [ -d "/opt/poky/2.0.1" ]
then
  echo
  echo "ERROR:  Only run this script on a poky SDK build machine"
  echo "    To run this script you must create the yocto SDK"
  echo "    including IMAGE_INSTALL += kernel-dev kernel-devsrc see hdmi-image.bb"
  echo "One way to create the SDK is with: bitbake -c populate_sdk hdmi-image"
  echo "    Then install the SDK on a compatible using the script found at "
  echo "    build_parallella/tmp/deploy/sdk/poky-glibc-x86_64-hdmi-image-debug-armv7ahf-vfp-neon-toolchain-2.0.1.sh"
  echo
  [[ $PS1 ]] && return || exit;
else
  source /opt/poky/2.0.1/environment-setup-armv7ahf-vfp-neon-poky-linux-gnueabi
fi

# Test to see if yocto sdk is correctly setup
# Note it is not essential to use /opt/poky/2.0.1 as the location
: ${OECORE_NATIVE_SYSROOT?"Please fix poky sdk, following command failed:- source /opt/poky/2.0.1/environment-setup-armv7ahf-vfp-neon-poky-linux-gnueabi"}

## This is the location of the epiphany sdk
export EXOTIC_TARGET_ARCH=epiphany
export EXOTIC_TARGET_SYS=${EXOTIC_TARGET_ARCH}-elf
export EXOTIC_TARGET_PREFIX=${EXOTIC_TARGET_SYS}-
export PARALLELLA_LINUX_HOME=${OECORE_TARGET_SYSROOT}/usr/src/kernel

export EPIPHANY_HOME=${OECORE_NATIVE_SYSROOT}/usr/${EXOTIC_TARGET_ARCH}/epiphany-sdk
export EPIPHANY_HDF=${EPIPHANY_HOME}/bsps/current/platform.hdf

##
## The end!
##

