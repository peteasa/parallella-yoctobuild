#!/bin/sh

if [ "$(uname -m)" != "armv7l" ]
then
  echo "ERROR: Only use this script on target. This is $(uname -m)"
  echo "       The script will changes /usr folder so requires root"
  echo
  exit 0
fi

export EPIPHANY_HOME=/usr/epiphany/epiphany-sdk
export EPIPHANY_HDF=${EPIPHANY_HOME}/bsps/current/platform.hdf
export LD_LIBRARY_PATH=/usr/lib/epiphany-elf:/usr/lib:${LD_LIBRARY_PATH}

## EXOTIC_TARGET_SYS is used in yocto Makefiles for epiphany code so define it here 
export EXOTIC_TARGET_SYS=epiphany-elf
## yocto Makefiles for epiphany code expect the tools in /usr/bin/epiphany-elf
mkdir /usr/bin/epiphany-elf
ln -s /usr/bin/epiphany-elf-gcc /usr/bin/epiphany-elf/gcc
ln -s /usr/bin/epiphany-elf-objcopy /usr/bin/epiphany-elf/objcopy

##
## The end!
##

