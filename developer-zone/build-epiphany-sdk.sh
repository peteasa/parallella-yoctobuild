#!/bin/bash

if ! [ -d "/opt/poky" ]
then
  echo
  echo "NOTE: To run this script you must create the yocto SDK including IMAGE_INSTALL += kernel-dev"
  echo "One way to create the SDK is with: bitbake -c populate_sdk hdmi-image"
  echo "    Then install the SDK using the script found at "
  echo "    build_parallella/tmp/deploy/sdk/poky-glibc-x86_64-hdmi-image-debug-armv7ahf-vfp-neon-toolchain-1.7.sh"
  echo
fi

if [ "$(uname -m)" != "x86_64" ]
then
  echo "WARNING: This script has been used on x86_64 only. This is $(uname -m)"
  echo
fi

if [ "${USER}" = "root" ]
then
  echo "ERROR: run this script as root it could damage your system"
  exit 0
fi

# Test to see if yocto sdk is correctly setup
# Note it is not essential to use /opt/poky/1.7 as the location in 
: ${OECORE_TARGET_SYSROOT?"Please run: source /opt/poky/1.7/environment-setup-armv7ahf-vfp-neon-poky-linux-gnueabi"}

export PARALLELLA_LINUX_HOME=${OECORE_TARGET_SYSROOT}
if ! [ -d ${PARALLELLA_LINUX_HOME}/include/uapi/linux ]
then
  export PARALLELLA_LINUX_HOME=${OECORE_TARGET_SYSROOT}/usr/src/kernel
fi

if ! [ -d ${PARALLELLA_LINUX_HOME}/include/uapi/linux ]
then
  echo "NOTE: To build e-hal you need uapi. Rebuild SDK with IMAGE_INSTALL += kernel-dev"
  echo "Continuing without e-hal"
  echo
fi

## This is the epiphany sdk as it will appear on the target system
export EPIPHANY_HOME_TARGET=${OECORE_TARGET_SYSROOT}/usr/epiphany/epiphany-sdk
## This is the epiphany sdk that will be of use on the build machine 
export EPIPHANY_HOME=${OECORE_NATIVE_SYSROOT}/usr/epiphany/epiphany-sdk

##
##
## Now attempt to construct the environment needed for epiphany-libs
##
##

if ! [ -f ${OECORE_NATIVE_SYSROOT}/usr/epiphany-elf/lib/libepiphany.a ]
then
  echo "Attempting to create epiphany friendly yocto SDK!"
  echo

  ## I thought that LIBRARY_PATH would pick these up but it does not
  ## epiphany-elf-g++ is searching for crt0.o etc in internal paths first
  ## and finds arm-poky-linux-gnueabi- versions that are no good.
  ## TODO fix up the bb scripts to copy the files into the SDK locations.

  # libgcc
  cp ${OECORE_TARGET_SYSROOT}/usr/lib/epiphany-elf/gcc/epiphany-elf/4.8.2/crt*.o ${OECORE_NATIVE_SYSROOT}/usr/lib/epiphany-elf/gcc/epiphany-elf/4.8.2/
  cp ${OECORE_TARGET_SYSROOT}/usr/lib/epiphany-elf/gcc/epiphany-elf/4.8.2/libg*.a ${OECORE_NATIVE_SYSROOT}/usr/lib/epiphany-elf/gcc/epiphany-elf/4.8.2/

  # libgloss
  cp ${OECORE_TARGET_SYSROOT}/usr/lib/epiphany-elf/cache*.o  ${OECORE_NATIVE_SYSROOT}/usr/epiphany-elf/lib/
  cp ${OECORE_TARGET_SYSROOT}/usr/lib/epiphany-elf/crt0.o  ${OECORE_NATIVE_SYSROOT}/usr/epiphany-elf/lib/
  cp ${OECORE_TARGET_SYSROOT}/usr/lib/epiphany-elf/libepi*  ${OECORE_NATIVE_SYSROOT}/usr/epiphany-elf/lib/
  cp ${OECORE_TARGET_SYSROOT}/usr/lib/epiphany-elf/libnosys*  ${OECORE_NATIVE_SYSROOT}/usr/epiphany-elf/lib/

  # newlib
  cp -r ${OECORE_TARGET_SYSROOT}/usr/epiphany-elf/include/ ${OECORE_NATIVE_SYSROOT}/usr/epiphany-elf/
  cp ${OECORE_TARGET_SYSROOT}/usr/lib/epiphany-elf/libc.a ${OECORE_NATIVE_SYSROOT}/usr/epiphany-elf/lib
  cp ${OECORE_TARGET_SYSROOT}/usr/lib/epiphany-elf/libg.a ${OECORE_NATIVE_SYSROOT}/usr/epiphany-elf/lib
  cp ${OECORE_TARGET_SYSROOT}/usr/lib/epiphany-elf/libm.a ${OECORE_NATIVE_SYSROOT}/usr/epiphany-elf/lib

  # gcc-runtime
  cp -r ${OECORE_TARGET_SYSROOT}/usr/epiphany-elf/include/c++ ${OECORE_NATIVE_SYSROOT}/usr/epiphany-elf/include 
  cp ${OECORE_TARGET_SYSROOT}/usr/lib/epiphany-elf/libs* ${OECORE_NATIVE_SYSROOT}/usr/epiphany-elf/lib/
fi

export EPIPHANY_HDF=${EPIPHANY_HOME_TARGET}/bsps/current/platform.hdf

##
##
## Now attempt to construct the sdk
##
##

## but first tidy up if this is the second run of the script
rm -r ${EPIPHANY_HOME_TARGET}
rm -r ${EPIPHANY_HOME}
rm ${OECORE_TARGET_SYSROOT}/usr/bin/e-ar
rm ${OECORE_NATIVE_SYSROOT}/usr/bin/e-ar
rm ${OECORE_TARGET_SYSROOT}/usr/bin/e-as
rm ${OECORE_NATIVE_SYSROOT}/usr/bin/e-as
# OECORE_TARGET_SYSROOT has all the epiphany-elf- tools in the bin folder so dont remove
rm ${OECORE_NATIVE_SYSROOT}/usr/bin/epiphany-elf-objcopy
rm ${OECORE_TARGET_SYSROOT}/usr/bin/e-gcc
rm ${OECORE_NATIVE_SYSROOT}/usr/bin/e-gcc
# OECORE_TARGET_SYSROOT gcc is from yocto sdk so dont remove that
rm ${OECORE_NATIVE_SYSROOT}/usr/bin/arm-linux-gnueabihf-gcc
rm ${OECORE_NATIVE_SYSROOT}/usr/bin/gcc
rm ${OECORE_TARGET_SYSROOT}/usr/lib/epiphany-elf/ldscripts
rm ${OECORE_NATIVE_SYSROOT}/usr/lib/epiphany-elf/ldscripts

if [[ -L ${OECORE_TARGET_SYSROOT}/usr/include/uapi/linux ]]
then
  rm ${OECORE_TARGET_SYSROOT}/usr/include/uapi/linux
  rm ${OECORE_NATIVE_SYSROOT}/usr/include/uapi/linux
fi

## Now start to reconstruct the epiphany sdk from the yocto sdk

## for uapi/linux/epiphany.h
if ! [ -d ${OECORE_TARGET_SYSROOT}/usr/include/uapi/linux ]
then
  if [ -d ${PARALLELLA_LINUX_HOME}/include/uapi/linux ]
  then
    ln -s ${PARALLELLA_LINUX_HOME}/include/uapi/linux ${OECORE_TARGET_SYSROOT}/usr/include/uapi
    ## oops bug here... if the ${OECORE_TARGET_SYSROOT}/usr/include/uapi/linux exists
    ## then we still need to create a version at ${OECORE_NATIVE_SYSROOT}/usr/include/uapi
    ## not an issue at the moment because ${OECORE_TARGET_SYSROOT}/usr/include/uapi/linux does not exist
    mkdir -p ${OECORE_NATIVE_SYSROOT}/usr/include/uapi
    ln -s ${PARALLELLA_LINUX_HOME}/include/uapi/linux ${OECORE_NATIVE_SYSROOT}/usr/include/uapi
  fi
fi

mkdir -p ${EPIPHANY_HOME_TARGET}/bsps
mkdir -p ${EPIPHANY_HOME}/bsps
mkdir -p ${EPIPHANY_HOME_TARGET}/tools/host
mkdir -p ${EPIPHANY_HOME}/tools/host
mkdir -p ${EPIPHANY_HOME_TARGET}/tools/e-gnu/epiphany-elf
mkdir -p ${EPIPHANY_HOME}/tools/e-gnu/epiphany-elf
mkdir -p ${EPIPHANY_HOME_TARGET}/tools/e-gnu/lib
mkdir -p ${EPIPHANY_HOME}/tools/e-gnu/lib
mkdir -p ${EPIPHANY_HOME_TARGET}/tools/e-gnu/libexec
mkdir -p ${EPIPHANY_HOME}/tools/e-gnu/libexec

## Now construct the SDK on the target
ln -s ${OECORE_TARGET_SYSROOT}/usr/include ${EPIPHANY_HOME_TARGET}/tools/host/
## Keep it simple and ensure the include folder at least is the same for the two epiphany sdks
ln -s ${OECORE_TARGET_SYSROOT}/usr/include ${EPIPHANY_HOME}/tools/host/
ln -s ${OECORE_TARGET_SYSROOT}/usr/lib ${EPIPHANY_HOME_TARGET}/tools/host/
ln -s ${OECORE_NATIVE_SYSROOT}/usr/lib ${EPIPHANY_HOME}/tools/host/
ln -s ${OECORE_TARGET_SYSROOT}/usr/bin ${EPIPHANY_HOME_TARGET}/tools/host/
ln -s ${OECORE_NATIVE_SYSROOT}/usr/bin ${EPIPHANY_HOME}/tools/host/

ln -s ${OECORE_TARGET_SYSROOT}/usr/bin ${EPIPHANY_HOME_TARGET}/tools/e-gnu/epiphany-elf/
ln -s ${OECORE_NATIVE_SYSROOT}/usr/bin ${EPIPHANY_HOME}/tools/e-gnu/epiphany-elf/
ln -s ${OECORE_TARGET_SYSROOT}/usr/epiphany-elf/include ${EPIPHANY_HOME_TARGET}/tools/e-gnu/epiphany-elf/sys-include
ln -s ${OECORE_NATIVE_SYSROOT}/usr/epiphany-elf/include ${EPIPHANY_HOME}/tools/e-gnu/epiphany-elf/sys-include
ln -s ${OECORE_TARGET_SYSROOT}/usr/epiphany-elf/include ${EPIPHANY_HOME_TARGET}/tools/e-gnu/epiphany-elf/
ln -s ${OECORE_NATIVE_SYSROOT}/usr/epiphany-elf/include ${EPIPHANY_HOME}/tools/e-gnu/epiphany-elf/
ln -s ${OECORE_TARGET_SYSROOT}/usr/lib/epiphany-elf ${EPIPHANY_HOME_TARGET}/tools/e-gnu/epiphany-elf/lib
ln -s ${OECORE_NATIVE_SYSROOT}/usr/lib/epiphany-elf ${EPIPHANY_HOME}/tools/e-gnu/epiphany-elf/lib
ln -s ${OECORE_TARGET_SYSROOT}/usr/epiphany-elf/lib/ldscripts ${OECORE_TARGET_SYSROOT}/usr/lib/epiphany-elf/
ln -s ${OECORE_NATIVE_SYSROOT}/usr/epiphany-elf/lib/ldscripts ${OECORE_NATIVE_SYSROOT}/usr/lib/epiphany-elf/
ln -s ${OECORE_TARGET_SYSROOT}/usr/bin ${EPIPHANY_HOME_TARGET}/tools/e-gnu/
ln -s ${OECORE_NATIVE_SYSROOT}/usr/bin ${EPIPHANY_HOME}/tools/e-gnu/
ln -s ${OECORE_TARGET_SYSROOT}/usr/lib/epiphany-elf/gcc ${EPIPHANY_HOME_TARGET}/tools/e-gnu/lib
ln -s ${OECORE_NATIVE_SYSROOT}/usr/lib/epiphany-elf/gcc ${EPIPHANY_HOME}/tools/e-gnu/lib
ln -s ${OECORE_TARGET_SYSROOT}/usr/lib/epiphany-elf/gcc ${EPIPHANY_HOME_TARGET}/tools/e-gnu/libexec
ln -s ${OECORE_NATIVE_SYSROOT}/usr/lib/epiphany-elf/gcc ${EPIPHANY_HOME}/tools/e-gnu/libexec

ln -s  ${OECORE_TARGET_SYSROOT}/usr/bin/epiphany-elf-ar ${OECORE_TARGET_SYSROOT}/usr/bin/e-ar
ln -s  ${OECORE_NATIVE_SYSROOT}/usr/bin/epiphany-elf/epiphany-elf-ar ${OECORE_NATIVE_SYSROOT}/usr/bin/e-ar
ln -s  ${OECORE_TARGET_SYSROOT}/usr/bin/epiphany-elf-as ${OECORE_TARGET_SYSROOT}/usr/bin/e-as
ln -s  ${OECORE_NATIVE_SYSROOT}/usr/bin/epiphany-elf/epiphany-elf-as ${OECORE_NATIVE_SYSROOT}/usr/bin/e-as
ln -s  ${OECORE_NATIVE_SYSROOT}/usr/bin/epiphany-elf/epiphany-elf-objcopy ${OECORE_NATIVE_SYSROOT}/usr/bin
ln -s  ${OECORE_TARGET_SYSROOT}/usr/bin/epiphany-elf-gcc ${OECORE_TARGET_SYSROOT}/usr/bin/e-gcc
ln -s  ${OECORE_NATIVE_SYSROOT}/usr/bin/epiphany-elf/epiphany-elf-gcc ${OECORE_NATIVE_SYSROOT}/usr/bin/e-gcc

##
## Attempt to create a version of gcc that calls the correct cross compiler
##
cat <<EOF > ${OECORE_NATIVE_SYSROOT}/usr/bin/arm-linux-gnueabihf-gcc
#!/bin/sh

${OECORE_NATIVE_SYSROOT}/usr/bin/arm-poky-linux-gnueabi/arm-poky-linux-gnueabi-gcc -march=armv7-a -mthumb-interwork -mfloat-abi=hard -mfpu=neon --sysroot=${OECORE_TARGET_SYSROOT} "\$@"

EOF

chmod +x ${OECORE_NATIVE_SYSROOT}/usr/bin/arm-linux-gnueabihf-gcc

cat <<EOF > ${OECORE_NATIVE_SYSROOT}/usr/bin/gcc
#!/bin/sh

${OECORE_NATIVE_SYSROOT}/usr/bin/arm-poky-linux-gnueabi/arm-poky-linux-gnueabi-gcc -march=armv7-a -mthumb-interwork -mfloat-abi=hard -mfpu=neon --sysroot=${OECORE_TARGET_SYSROOT} "\$@"

EOF

chmod +x ${OECORE_NATIVE_SYSROOT}/usr/bin/gcc

##
##
## Now pull in the epiphany-libs
##
##
export SDKBUILDROOT=${PWD}

if ! [ -d epiphany-libs ]
then
  echo "Fetch the epiphany-libs"
  echo

  git clone -b 2015.1 https://github.com/adapteva/epiphany-libs.git

  ##
  ## Now apply the patches to make the Makefile yocto friendly
  ##
  cd ${SDKBUILDROOT}/epiphany-libs
  git apply --stat ${SDKBUILDROOT}/epiphany-libs.patch
fi

##
##
## Now start the build
##
##
MAKE="make  " 
CLEAN=" clean "

function build-xml() {
	# Build the XML parser library
	echo '==============================='
	echo '============ E-XML ============'
	echo '==============================='
	cd src/e-xml
	${MAKE} $CLEAN all
	cd ../../
}


function build-loader() {
	# Build the Epiphany Loader library
	echo '=================================='
	echo '============ E-LOADER ============'
	echo '=================================='
	cd src/e-loader
	${MAKE} $CLEAN all
	cd ../../
}


function build-hal() {
	# Build the memory management library
	echo '==============================='
	echo '========== E-MEMMAN ==========='
	echo '==============================='

	echo 'Building e-memman library'
	cd src/e-memman
	${MAKE} $CLEAN all
	cd ../../

	# Build the Epiphnay HAL library
	echo '==============================='
	echo '============ E-HAL ============'
	echo '==============================='
	cd src/e-hal
	${MAKE} $CLEAN all
	for bsp in ${BSPS}; do
		cp -f Release/libe-hal.so ../../bsps/${bsp}
	done
	cd ../../
}


function build-server() {
	# Build the Epiphnay GDB RSP Server
	echo '=================================='
	echo '============ E-SERVER ============'
	echo '=================================='
	cd src/e-server
	${MAKE} $CLEAN all
	cd ../../
}


function build-utils() {
	# Install the Epiphnay GNU Tools wrappers
	echo '================================='
	echo '============ E-UTILS ============'
	echo '================================='

	cd src/e-utils

	echo 'Building e-reset'
	cd e-reset
	${MAKE} $CLEAN all
	cd ../

	echo 'Building e-loader'
	cd e-loader
	${MAKE} $CLEAN all
	cd ../

	echo 'Building e-read'
	cd e-read
	${MAKE} $CLEAN all
	cd ../

	echo 'Building e-write'
	cd e-write
	${MAKE} $CLEAN all
	cd ../

	echo 'Building e-hw-rev'
	cd e-hw-rev
	${MAKE} $CLEAN all
	cd ../

	echo 'Building e-trace library'
	cd e-trace
	${MAKE} $CLEAN all
	cd ../

	echo 'Building e-trace-server'
	cd e-trace-server
	${MAKE} $CLEAN all
	cd ../

	echo 'Building e-trace-dump'
	cd e-trace-dump
	${MAKE} $CLEAN all
	cd ../

	echo 'Building e-clear-shmtable'
	cd e-clear-shmtable
	${MAKE} $CLEAN all
	cd ../

	cd ../../
}


function build-lib() {
	# build the Epiphnay Runtime Library
	echo '==============================='
	echo '============ E-LIB ============'
	echo '==============================='
	cd src/e-lib

	## 
	## Save the CROSS_COMPILE variable
	##
        CROSS_COMPILE_SAVE=$CROSS_COMPILE
	TARGET_SYS=epiphany-elf
	TOOLDIR=$OECORE_NATIVE_SYSROOT/usr/bin/$TARGET_SYS
	CROSS_COMPILE=$TOOLDIR/$TARGET_SYS-
	##
	## make_common.rules removes CFLAGS for this CROSS_COMPILE
	## 
	${MAKE} $CLEAN CROSS_COMPILE=$CROSS_COMPILE $CLEAN all

	##
	## Restore the CROSS_COMPILER
	##
	export CROSS_COMPILE=$CROSS_COMPILE_SAVE

	cd ../../
}

cd ${SDKBUILDROOT}/epiphany-libs
build-xml
cd ${SDKBUILDROOT}/epiphany-libs
build-loader
cd ${SDKBUILDROOT}/epiphany-libs
build-hal
cd ${SDKBUILDROOT}/epiphany-libs
build-server
cd ${SDKBUILDROOT}/epiphany-libs
build-utils
cd ${SDKBUILDROOT}/epiphany-libs
build-lib

##
##
## Now attempt to construct the sdk
##
##
cp  ${SDKBUILDROOT}/epiphany-libs/src/e-utils/e-objcopy ${OECORE_TARGET_SYSROOT}/usr/bin/
cp  ${SDKBUILDROOT}/epiphany-libs/src/e-utils/e-objcopy ${OECORE_NATIVE_SYSROOT}/usr/bin/
#cp  ${SDKBUILDROOT}/epiphany-libs/src/e-utils/e-hw-rev/e-hw-rev.sh ${OECORE_TARGET_SYSROOT}/usr/bin/e-hw-rev
cp  ${SDKBUILDROOT}/epiphany-libs/src/e-utils/e-hw-rev/e-hw-rev ${OECORE_TARGET_SYSROOT}/usr/bin/e-hw-rev.e
cp  ${SDKBUILDROOT}/epiphany-libs/src/e-utils/e-hw-rev/e-hw-rev ${OECORE_NATIVE_SYSROOT}/usr/bin/e-hw-rev.e
#cp  ${SDKBUILDROOT}/epiphany-libs/src/e-utils/e-loader/e-loader.sh ${OECORE_TARGET_SYSROOT}/usr/bin/e-loader
cp  ${SDKBUILDROOT}/epiphany-libs/src/e-utils/e-loader/Debug/e-loader ${OECORE_TARGET_SYSROOT}/usr/bin/e-loader.e
cp  ${SDKBUILDROOT}/epiphany-libs/src/e-utils/e-loader/Debug/e-loader ${OECORE_NATIVE_SYSROOT}/usr/bin/e-loader.e
#cp  ${SDKBUILDROOT}/epiphany-libs/src/e-utils/e-read/e-read.sh ${OECORE_TARGET_SYSROOT}/usr/bin/e-read
cp  ${SDKBUILDROOT}/epiphany-libs/src/e-utils/e-read/Debug/e-read ${OECORE_TARGET_SYSROOT}/usr/bin/e-read.e
cp  ${SDKBUILDROOT}/epiphany-libs/src/e-utils/e-read/Debug/e-read ${OECORE_NATIVE_SYSROOT}/usr/bin/e-read.e
#cp  ${SDKBUILDROOT}/epiphany-libs/src/e-utils/e-reset/e-reset.sh ${OECORE_TARGET_SYSROOT}/usr/bin/e-reset
cp  ${SDKBUILDROOT}/epiphany-libs/src/e-utils/e-reset/e-reset ${OECORE_TARGET_SYSROOT}/usr/bin/e-reset.e
cp  ${SDKBUILDROOT}/epiphany-libs/src/e-utils/e-reset/e-reset ${OECORE_NATIVE_SYSROOT}/usr/bin/e-reset.e
#cp  ${SDKBUILDROOT}/epiphany-libs/src/e-utils/e-write/e-write.sh ${OECORE_TARGET_SYSROOT}/usr/bin/e-write
cp  ${SDKBUILDROOT}/epiphany-libs/src/e-utils/e-write/Debug/e-write ${OECORE_TARGET_SYSROOT}/usr/bin/e-write.e
cp  ${SDKBUILDROOT}/epiphany-libs/src/e-utils/e-write/Debug/e-write ${OECORE_NATIVE_SYSROOT}/usr/bin/e-write.e

cp ${SDKBUILDROOT}/epiphany-libs/src/e-hal/src/epiphany-hal-api.h ${OECORE_TARGET_SYSROOT}/usr/include/
cp ${SDKBUILDROOT}/epiphany-libs/src/e-hal/src/epiphany-hal-api.h ${OECORE_NATIVE_SYSROOT}/usr/include/
cp ${SDKBUILDROOT}/epiphany-libs/src/e-hal/src/epiphany-hal.h ${OECORE_TARGET_SYSROOT}/usr/include/
cp ${SDKBUILDROOT}/epiphany-libs/src/e-hal/src/epiphany-hal.h ${OECORE_NATIVE_SYSROOT}/usr/include/

rm ${OECORE_TARGET_SYSROOT}/usr/include/e-hal.h
rm ${OECORE_NATIVE_SYSROOT}/usr/include/e-hal.h
ln -s ${OECORE_TARGET_SYSROOT}/usr/include/epiphany-hal.h ${OECORE_TARGET_SYSROOT}/usr/include/e-hal.h
ln -s ${OECORE_NATIVE_SYSROOT}/usr/include/epiphany-hal.h ${OECORE_NATIVE_SYSROOT}/usr/include/e-hal.h
rm ${OECORE_TARGET_SYSROOT}/usr/include/e_hal.h
rm ${OECORE_NATIVE_SYSROOT}/usr/include/e_hal.h
ln -s ${OECORE_TARGET_SYSROOT}/usr/include/epiphany-hal.h ${OECORE_TARGET_SYSROOT}/usr/include/e_hal.h
ln -s ${OECORE_NATIVE_SYSROOT}/usr/include/epiphany-hal.h ${OECORE_NATIVE_SYSROOT}/usr/include/e_hal.h

cp ${SDKBUILDROOT}/epiphany-libs/src/e-hal/src/epiphany-hal-data.h ${OECORE_TARGET_SYSROOT}/usr/include/
cp ${SDKBUILDROOT}/epiphany-libs/src/e-hal/src/epiphany-hal-data.h ${OECORE_NATIVE_SYSROOT}/usr/include/
cp ${SDKBUILDROOT}/epiphany-libs/src/e-hal/src/epiphany-hal-data-local.h ${OECORE_TARGET_SYSROOT}/usr/include/
cp ${SDKBUILDROOT}/epiphany-libs/src/e-hal/src/epiphany-hal-data-local.h ${OECORE_NATIVE_SYSROOT}/usr/include/
cp ${SDKBUILDROOT}/epiphany-libs/src/e-hal/src/epiphany-shm-manager.h ${OECORE_TARGET_SYSROOT}/usr/include/
cp ${SDKBUILDROOT}/epiphany-libs/src/e-hal/src/epiphany-shm-manager.h ${OECORE_NATIVE_SYSROOT}/usr/include/

cp ${SDKBUILDROOT}/epiphany-libs/src/e-lib/include/e_lib.h ${OECORE_TARGET_SYSROOT}/usr/epiphany-elf/include/
cp ${SDKBUILDROOT}/epiphany-libs/src/e-lib/include/e_lib.h ${OECORE_NATIVE_SYSROOT}/usr/epiphany-elf/include/

rm ${OECORE_TARGET_SYSROOT}/usr/epiphany-elf/include/e-lib.h
rm ${OECORE_NATIVE_SYSROOT}/usr/epiphany-elf/include/e-lib.h
ln -s ${OECORE_TARGET_SYSROOT}/usr/epiphany-elf/include/e_lib.h ${OECORE_TARGET_SYSROOT}/usr/epiphany-elf/include/e-lib.h
ln -s ${OECORE_NATIVE_SYSROOT}/usr/epiphany-elf/include/e_lib.h ${OECORE_NATIVE_SYSROOT}/usr/epiphany-elf/include/e-lib.h

cp ${SDKBUILDROOT}/epiphany-libs/src/e-lib/include/e_common.h ${OECORE_TARGET_SYSROOT}/usr/epiphany-elf/include/
cp ${SDKBUILDROOT}/epiphany-libs/src/e-lib/include/e_common.h ${OECORE_NATIVE_SYSROOT}/usr/epiphany-elf/include/
cp ${SDKBUILDROOT}/epiphany-libs/src/e-lib/include/e_types.h ${OECORE_TARGET_SYSROOT}/usr/epiphany-elf/include/
cp ${SDKBUILDROOT}/epiphany-libs/src/e-lib/include/e_types.h ${OECORE_NATIVE_SYSROOT}/usr/epiphany-elf/include/
cp ${SDKBUILDROOT}/epiphany-libs/src/e-lib/include/e_regs.h ${OECORE_TARGET_SYSROOT}/usr/epiphany-elf/include/
cp ${SDKBUILDROOT}/epiphany-libs/src/e-lib/include/e_regs.h ${OECORE_NATIVE_SYSROOT}/usr/epiphany-elf/include/
cp ${SDKBUILDROOT}/epiphany-libs/src/e-lib/include/e_dma.h ${OECORE_TARGET_SYSROOT}/usr/epiphany-elf/include/
cp ${SDKBUILDROOT}/epiphany-libs/src/e-lib/include/e_dma.h ${OECORE_NATIVE_SYSROOT}/usr/epiphany-elf/include/
cp ${SDKBUILDROOT}/epiphany-libs/src/e-lib/include/e_ctimers.h ${OECORE_TARGET_SYSROOT}/usr/epiphany-elf/include/
cp ${SDKBUILDROOT}/epiphany-libs/src/e-lib/include/e_ctimers.h ${OECORE_NATIVE_SYSROOT}/usr/epiphany-elf/include/
cp ${SDKBUILDROOT}/epiphany-libs/src/e-lib/include/e_ic.h ${OECORE_TARGET_SYSROOT}/usr/epiphany-elf/include/
cp ${SDKBUILDROOT}/epiphany-libs/src/e-lib/include/e_ic.h ${OECORE_NATIVE_SYSROOT}/usr/epiphany-elf/include/
cp ${SDKBUILDROOT}/epiphany-libs/src/e-lib/include/e_mem.h ${OECORE_TARGET_SYSROOT}/usr/epiphany-elf/include/
cp ${SDKBUILDROOT}/epiphany-libs/src/e-lib/include/e_mem.h ${OECORE_NATIVE_SYSROOT}/usr/epiphany-elf/include/
cp ${SDKBUILDROOT}/epiphany-libs/src/e-lib/include/e_mutex.h ${OECORE_TARGET_SYSROOT}/usr/epiphany-elf/include/
cp ${SDKBUILDROOT}/epiphany-libs/src/e-lib/include/e_mutex.h ${OECORE_NATIVE_SYSROOT}/usr/epiphany-elf/include/
cp ${SDKBUILDROOT}/epiphany-libs/src/e-lib/include/e_coreid.h ${OECORE_TARGET_SYSROOT}/usr/epiphany-elf/include/
cp ${SDKBUILDROOT}/epiphany-libs/src/e-lib/include/e_coreid.h ${OECORE_NATIVE_SYSROOT}/usr/epiphany-elf/include/
cp ${SDKBUILDROOT}/epiphany-libs/src/e-lib/include/e_trace.h ${OECORE_TARGET_SYSROOT}/usr/epiphany-elf/include/
cp ${SDKBUILDROOT}/epiphany-libs/src/e-lib/include/e_trace.h ${OECORE_NATIVE_SYSROOT}/usr/epiphany-elf/include/
cp ${SDKBUILDROOT}/epiphany-libs/src/e-lib/include/e_shm.h ${OECORE_TARGET_SYSROOT}/usr/epiphany-elf/include/
cp ${SDKBUILDROOT}/epiphany-libs/src/e-lib/include/e_shm.h ${OECORE_NATIVE_SYSROOT}/usr/epiphany-elf/include/

cp ${SDKBUILDROOT}/epiphany-libs/src/e-loader/src/e-loader.h ${OECORE_TARGET_SYSROOT}/usr/include/
cp ${SDKBUILDROOT}/epiphany-libs/src/e-loader/src/e-loader.h ${OECORE_NATIVE_SYSROOT}/usr/include/

rm ${OECORE_TARGET_SYSROOT}/usr/include/e_loader.h
rm ${OECORE_NATIVE_SYSROOT}/usr/include/e_loader.h
ln -s ${OECORE_TARGET_SYSROOT}/usr/include/e-loader.h ${OECORE_TARGET_SYSROOT}/usr/include/e_loader.h
ln -s ${OECORE_NATIVE_SYSROOT}/usr/include/e-loader.h ${OECORE_NATIVE_SYSROOT}/usr/include/e_loader.h

cp ${SDKBUILDROOT}/epiphany-libs/src/e-loader/Release/libe-loader.so ${OECORE_TARGET_SYSROOT}/usr/lib/
cp ${SDKBUILDROOT}/epiphany-libs/src/e-loader/Release/libe-loader.so ${OECORE_NATIVE_SYSROOT}/usr/lib/
cp ${SDKBUILDROOT}/epiphany-libs/src/e-xml/Release/libe-xml.so ${OECORE_TARGET_SYSROOT}/usr/lib/
cp ${SDKBUILDROOT}/epiphany-libs/src/e-xml/Release/libe-xml.so ${OECORE_NATIVE_SYSROOT}/usr/lib/
cp ${SDKBUILDROOT}/epiphany-libs/bsps/parallella_E16G3_1GB/libe-hal.so ${OECORE_TARGET_SYSROOT}/usr/lib/
cp ${SDKBUILDROOT}/epiphany-libs/bsps/parallella_E16G3_1GB/libe-hal.so ${OECORE_NATIVE_SYSROOT}/usr/lib/

cp ${SDKBUILDROOT}/epiphany-libs/src/e-lib/Release/libe-lib.a ${OECORE_TARGET_SYSROOT}/usr/lib/epiphany-elf/
cp ${SDKBUILDROOT}/epiphany-libs/src/e-lib/Release/libe-lib.a ${OECORE_NATIVE_SYSROOT}/usr/epiphany-elf/lib

rm ${OECORE_TARGET_SYSROOT}/usr/lib/epiphany-elf/libelib.a
rm ${OECORE_NATIVE_SYSROOT}/usr/epiphany-elf/lib/libelib.a
ln -s ${OECORE_TARGET_SYSROOT}/usr/lib/epiphany-elf/libe-lib.a ${OECORE_TARGET_SYSROOT}/usr/lib/epiphany-elf/libelib.a
ln -s ${OECORE_NATIVE_SYSROOT}/usr/epiphany-elf/lib/libe-lib.a ${OECORE_NATIVE_SYSROOT}/usr/epiphany-elf/lib/libelib.a

cp -r ${SDKBUILDROOT}/epiphany-libs/bsps/p64v1521 ${EPIPHANY_HOME_TARGET}/bsps
cp -r ${SDKBUILDROOT}/epiphany-libs/bsps/p64v1521 ${EPIPHANY_HOME}/bsps
cp -r ${SDKBUILDROOT}/epiphany-libs/bsps/parallella64 ${EPIPHANY_HOME_TARGET}/bsps
cp -r ${SDKBUILDROOT}/epiphany-libs/bsps/parallella64 ${EPIPHANY_HOME}/bsps
cp -r ${SDKBUILDROOT}/epiphany-libs/bsps/parallella_E16G3_1GB ${EPIPHANY_HOME_TARGET}/bsps
cp -r ${SDKBUILDROOT}/epiphany-libs/bsps/parallella_E16G3_1GB ${EPIPHANY_HOME}/bsps
cp -r ${SDKBUILDROOT}/epiphany-libs/bsps/zed_E16G3_512mb ${EPIPHANY_HOME_TARGET}/bsps
cp -r ${SDKBUILDROOT}/epiphany-libs/bsps/zed_E16G3_512mb ${EPIPHANY_HOME}/bsps
cp -r ${SDKBUILDROOT}/epiphany-libs/bsps/zed_E64G4_512mb ${EPIPHANY_HOME_TARGET}/bsps
cp -r ${SDKBUILDROOT}/epiphany-libs/bsps/zed_E64G4_512mb ${EPIPHANY_HOME}/bsps

## Now I have a parallella E16 so I am going to set that up...
ln -s ${EPIPHANY_HOME_TARGET}/bsps/parallella_E16G3_1GB ${EPIPHANY_HOME_TARGET}/bsps/current
ln -s ${EPIPHANY_HOME}/bsps/parallella_E16G3_1GB ${EPIPHANY_HOME}/bsps/current

##
## The end!
##

cd ${SDKBUILDROOT}
