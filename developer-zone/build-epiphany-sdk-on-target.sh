#!/bin/sh

if [ "$(uname -m)" != "armv7l" ]
then
  echo "ERROR: Only use this script on target. This is $(uname -m)"
  echo "       The script will changes /usr folder so requires root"
  echo
  exit 0
fi

export SDKBUILDROOT=${PWD}

export EPIPHANY_HOME=${SDKBUILDROOT}/epiphany-sdk
export EPIPHANY_HDF=${EPIPHANY_HOME}/bsps/current/platform.hdf
export LD_LIBRARY_PATH=/usr/lib/epiphany-elf:/usr/lib:${LD_LIBRARY_PATH}

mkdir -p epiphany-sdk/bsps
mkdir -p epiphany-sdk/tools/host
mkdir -p epiphany-sdk/tools/e-gnu/epiphany-elf
mkdir -p epiphany-sdk/tools/e-gnu/lib
mkdir -p epiphany-sdk/tools/e-gnu/libexec

## Now construct the SDK on the target
ln -s /usr/include ${EPIPHANY_HOME}/tools/host/
ln -s /usr/lib ${EPIPHANY_HOME}/tools/host/
ln -s /usr/bin ${EPIPHANY_HOME}/tools/host/

ln -s /usr/epiphany-elf/bin ${EPIPHANY_HOME}/tools/e-gnu/epiphany-elf/
ln -s /usr/epiphany-elf/include ${EPIPHANY_HOME}/tools/e-gnu/epiphany-elf/sys-include
ln -s /usr/epiphany-elf/include ${EPIPHANY_HOME}/tools/e-gnu/epiphany-elf/
ln -s /usr/lib/epiphany-elf ${EPIPHANY_HOME}/tools/e-gnu/epiphany-elf/lib
ln -s /usr/epiphany-elf/lib/ldscripts /usr/lib/epiphany-elf/
ln -s /usr/bin ${EPIPHANY_HOME}/tools/e-gnu/
ln -s /usr/lib/epiphany-elf/gcc ${EPIPHANY_HOME}/tools/e-gnu/lib
ln -s /usr/lib/epiphany-elf/gcc ${EPIPHANY_HOME}/tools/e-gnu/libexec

ln -s  /usr/bin/epiphany-elf-ar /usr/bin/e-ar
ln -s  /usr/bin/epiphany-elf-as /usr/bin/e-as
ln -s  /usr/bin/epiphany-elf-gcc /usr/bin/e-gcc

git clone https://github.com/adapteva/epiphany-libs.git

cd epiphany-libs/
git checkout -b esdk.5.13.09.10 esdk.5.13.09.10

ln -s  ${SDKBUILDROOT}/epiphany-libs/bsps/parallella_E16G3_1GB ${EPIPHANY_HOME}/bsps/current

cd src/e-xml/Release
make clean
make all
cd ../../../

cd src/e-loader/Release
make clean
make all
cd ../../../

cd src/e-hal/Release
make clean
make all

BSPS=parallella_E16G3_1GB

        for bsp in ${BSPS}; do
                cp -f libe-hal.so ../../../bsps/${bsp}
        done

cd ../../../

#        cd src/e-server/Release
#        make clean
#        make all
#        cd ../../../

cd src/e-utils
cd e-reset
./build.sh
cd ../

cd e-loader/Debug
make clean
make all
cd ../../

cd e-read/Debug
make clean
make all
cd ../../

cd e-write/Debug
make clean
make all
cd ../../

cd e-hw-rev
./build.sh
cd ../
cd ../../

cd src/e-lib/Release

make clean
make all
cd ../../../../

ln -s  ${SDKBUILDROOT}/epiphany-libs/src/e-utils/e-objcopy /usr/bin/
ln -s  ${SDKBUILDROOT}/epiphany-libs/src/e-utils/e-hw-rev/e-hw-rev.sh /usr/bin/e-hw-rev
ln -s  ${SDKBUILDROOT}/epiphany-libs/src/e-utils/e-hw-rev/e-hw-rev /usr/bin/e-hw-rev.e
ln -s  ${SDKBUILDROOT}/epiphany-libs/src/e-utils/e-loader/e-loader.sh /usr/bin/e-loader
ln -s  ${SDKBUILDROOT}/epiphany-libs/src/e-utils/e-loader/Debug/e-loader /usr/bin/e-loader.e
ln -s  ${SDKBUILDROOT}/epiphany-libs/src/e-utils/e-read/e-read.sh /usr/bin/e-read
ln -s  ${SDKBUILDROOT}/epiphany-libs/src/e-utils/e-read/Debug/e-read /usr/bin/e-read.e
ln -s  ${SDKBUILDROOT}/epiphany-libs/src/e-utils/e-reset/e-reset.sh /usr/bin/e-reset
ln -s  ${SDKBUILDROOT}/epiphany-libs/src/e-utils/e-reset/e-reset /usr/bin/e-reset.e
ln -s  ${SDKBUILDROOT}/epiphany-libs/src/e-utils/e-write/e-write.sh /usr/bin/e-write
ln -s  ${SDKBUILDROOT}/epiphany-libs/src/e-utils/e-write/Debug/e-write /usr/bin/e-write.e

ln -s ${SDKBUILDROOT}/epiphany-libs/src/e-hal/src/epiphany-hal-api.h /usr/include/
ln -s ${SDKBUILDROOT}/epiphany-libs/src/e-hal/src/epiphany-hal.h /usr/include/
ln -s ${SDKBUILDROOT}/epiphany-libs/src/e-hal/src/epiphany-hal.h /usr/include/e-hal.h
ln -s ${SDKBUILDROOT}/epiphany-libs/src/e-hal/src/epiphany-hal.h /usr/include/e_hal.h
ln -s ${SDKBUILDROOT}/epiphany-libs/src/e-hal/src/epiphany-hal-data.h /usr/include/
ln -s ${SDKBUILDROOT}/epiphany-libs/src/e-hal/src/epiphany-hal-data-local.h /usr/include/

ln -s ${SDKBUILDROOT}/epiphany-libs/src/e-lib/include/e_lib.h /usr/epiphany-elf/include/
ln -s ${SDKBUILDROOT}/epiphany-libs/src/e-lib/include/e_lib.h /usr/epiphany-elf/include/e-lib.h
ln -s ${SDKBUILDROOT}/epiphany-libs/src/e-lib/include/e_common.h /usr/epiphany-elf/include/
ln -s ${SDKBUILDROOT}/epiphany-libs/src/e-lib/include/e_types.h /usr/epiphany-elf/include/
ln -s ${SDKBUILDROOT}/epiphany-libs/src/e-lib/include/e_regs.h /usr/epiphany-elf/include/
ln -s ${SDKBUILDROOT}/epiphany-libs/src/e-lib/include/e_dma.h /usr/epiphany-elf/include/
ln -s ${SDKBUILDROOT}/epiphany-libs/src/e-lib/include/e_ctimers.h /usr/epiphany-elf/include/
ln -s ${SDKBUILDROOT}/epiphany-libs/src/e-lib/include/e_ic.h /usr/epiphany-elf/include/
ln -s ${SDKBUILDROOT}/epiphany-libs/src/e-lib/include/e_mem.h /usr/epiphany-elf/include/
ln -s ${SDKBUILDROOT}/epiphany-libs/src/e-lib/include/e_mutex.h /usr/epiphany-elf/include/
ln -s ${SDKBUILDROOT}/epiphany-libs/src/e-lib/include/e_coreid.h /usr/epiphany-elf/include/

ln -s ${SDKBUILDROOT}/epiphany-libs/src/e-loader/src/e-loader.h /usr/include/
ln -s ${SDKBUILDROOT}/epiphany-libs/src/e-loader/src/e-loader.h /usr/include/e_loader.h
ln -s ${SDKBUILDROOT}/epiphany-libs/src/e-loader/Release/libe-loader.so /usr/lib/
ln -s ${SDKBUILDROOT}/epiphany-libs/src/e-xml/Release/libe-xml.so /usr/lib/
ln -s ${SDKBUILDROOT}/epiphany-libs/bsps/parallella_E16G3_1GB/libe-hal.so /usr/lib/

ln -s ${SDKBUILDROOT}/epiphany-libs/src/e-lib/Release/libe-lib.a /usr/lib/epiphany-elf/
ln -s ${SDKBUILDROOT}/epiphany-libs/src/e-lib/Release/libe-lib.a /usr/lib/epiphany-elf/libelib.a

