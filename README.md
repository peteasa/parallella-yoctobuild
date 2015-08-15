# parallella-yoctobuild `parallella-elink-redesign`

THIS BRANCH IS IN DEVELOPMENT.  The aim is to create an hdmi version of the elink-redesign project with 2015.1 SDK

COMBINED FPGA and LINUX environment START IN https://github.com/peteasa/parallella branch `elink-redesign`

If you want the yocto build environment START IN https://github.com/peteasa/parallella-yocobuild branch `elink-redesign`

If you just want the `stable` yocto build environment START IN https://github.com/peteasa/parallella-yocobuild branch `yoctobuild`

## Instructions

For full instructions see https://github.com/peteasa/parallella branch `parallella-elink-redesign`

### Installing required packages

To use `yocto` you first need to install some packages. See latest [Yocto Project Quick Start](http://www.yoctoproject.org/docs/latest/yocto-project-qs/yocto-project-qs.html). This assumes you are working on a Ubuntu machine:

```bash
$ sudo apt-get install gawk wget git-core diffstat unzip texinfo gcc-multilib build-essential chrpath socat libsdl1.2-dev xterm
```

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
