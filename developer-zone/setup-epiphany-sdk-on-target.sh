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

##
## The end!
##

