#!/bin/sh

if [[ $_ = $0 ]]
then
  echo "ERROR: to set the environment variables run"
  echo "  source setup-epiphany-sdk-in-poky-sdk.sh"
  [[ $PS1 ]] && return || exit;
fi

if [ "$(uname -m)" != "armv7l" ]
then
  echo "ERROR: Only use this script on target. This is $(uname -m)"
  echo "       The script will make changes in /usr folder so requires root"
  echo
  [[ $PS1 ]] && return || exit;
fi

export CROSS_COMPILE=
export EPIPHANY_HOME=/usr/epiphany/epiphany-sdk
export EPIPHANY_HDF=${EPIPHANY_HOME}/bsps/current/platform.hdf
export LD_LIBRARY_PATH=/usr/local/lib:/usr/lib/epiphany-elf:/usr/lib:${LD_LIBRARY_PATH}

## EXOTIC_TARGET_SYS is used in yocto Makefiles for epiphany code so define it here 
export EXOTIC_TARGET_SYS=epiphany-elf
## yocto Makefiles for epiphany code expect the tools in /usr/bin/epiphany-elf
mkdir -p /usr/bin/epiphany-elf

if ! [ -e "/usr/bin/epiphany-elf/gcc" ]
then
  ln -s /usr/bin/epiphany-elf-gcc /usr/bin/epiphany-elf/gcc
  ln -s /usr/bin/epiphany-elf-objcopy /usr/bin/epiphany-elf/objcopy

  ## make linux uapi available for applications that use the epiphany driver
  ln -s /usr/src/kernel/include/uapi/linux /usr/include/uapi/linux
fi

##
## The end!
##

