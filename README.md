parallella-yoctobuild
=====================

START HERE - A Simple to use build environment for parallella using yocto

Instructions
============

Clone this onto your Linux build machine then

Once only task - to prepare the environment, in this folder type
   source initgitsubmodules.sh

The result will be new folders poky, meta-xilinx, meta-parallella
and meta-epiphany created from specific commits on github.

Once per session - to prepare and run oe-init-build-env type
   source prepareyoctobuild.sh

oe-init-build-env will change the working directory to the build folder
To start the yocto build in the build folder type
   bitbake hdmi-image

Other images to build can be found in meta-project/recipes/images

The result will be a complete build for the parallella board built on
the build machine.

TODO writing to the SD card
