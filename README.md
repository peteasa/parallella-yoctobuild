# parallella-yoctobuild - yoctobuild branch

NOTE: This branch uses rather old linux and fpga.  It still all works but you might be better off moving to the elink-redesign branch or even visiting [FPGA and Linux Development Combined](https://github.com/peteasa/parallella)

A Simple build environment for [Parallella](http://www.parallella.org/) using [Yocto](http://www.yoctoproject.org/)

## Instructions

### Installing required packages

To use `yocto` you first need to install some packages. See latest [Yocto Project Quick Start](http://www.yoctoproject.org/docs/latest/yocto-project-qs/yocto-project-qs.html). This assumes you are working on a Ubuntu machine:

```bash
$ sudo apt-get install gawk wget git-core diffstat unzip texinfo gcc-multilib build-essential chrpath socat libsdl1.2-dev xterm
```

### Cloning this repository

Clone this repository onto your Linux build machine:
```bash
$ git clone git@github.com:peteasa/parallella-yoctobuild
$ cd parallella-yoctobuild
```

To prepare the environment and download the necessary git submodules, you need to run the `initgitsubmodules.sh` script. This only needs to be done once:

```bash
$ source initgitsubmodules.sh
```

The result will be new folders `poky`, `meta-xilinx`, `meta-parallella` and `meta-epiphany` created from specific commits on github.

### Setting up your shell environment

To prepare and run `oe-init-build-env` you need to run the `prepareyoctobuild.sh` script:

```bash
$ source prepareyoctobuild.sh
```

This needs to be done once per session.

`oe-init-build-env` will change the working directory to the `build` folder.

### Building a new development environment

To start the yocto build in the `build` folder run:

```bash
$ bitbake hdmi-image
```

If you want an SDK then in the same `build` folder, run:

```bash
$ bitbake -c populate_sdk hdmi-image
```

Other images to build can be found in `meta-parallella/recipes-epiphany/images`.

The result will be a complete build for the parallella board built on the build machine

`parallella-yoctobuild/build_parallella/tmp/deploy/images/parallella-hdmi`

Plus for free a complete distribution folder that you publish from a web server to update specific packages on the target - just like you use when you run `sudo apt-get install` on your Linux build machine.  This project uses [smart](https://labix.org/smart) as the package manager on the target:

```bash
$ smart update
$ smart upgrade
```

The SDK is found at `parallella-yoctobuild/build_parallella/tmp/deploy/sdk`

### Links to other information

Troubleshooting notes - [Troubleshooting notes](https://github.com/peteasa/parallella-yoctobuild/wiki/Troubleshooting-notes)

Instructions for contributors - [Instructions for contributors](https://github.com/peteasa/parallella-yoctobuild/wiki/Instructions-for-contributors)


---------------------------------------

  * TODO instructions for writing to the SD card.
