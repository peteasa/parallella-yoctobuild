# parallella-yoctobuild `parallella-elink-redesign`

The aim of this project is to create an hdmi version of the elink-redesign project with 2015.1 SDK

A Simple build environment for [Parallella](http://www.parallella.org/) using [Yocto](http://www.yoctoproject.org/)

The following branches are significant in this repository:

- [parallella-elink-redesign](https://github.com/peteasa/parallella-yoctobuild/tree/parallella-elink-redesign) - this branch - contains an example layer that demonstrates how to extend the yocto build to add your own design.  See the [parallella](https://github.com/peteasa/parallella/wiki) project for more details and Tutorials
- [elink-redesign](https://github.com/peteasa/parallella-yoctobuild/tree/elink-redesign) - the default branch that contains a working yocto build environment using official bitstream published by the Parallella team.
- of historical interest [yoctobuild](https://github.com/peteasa/parallella-yoctobuild/tree/yoctobuild) - old elink and build environment for original parallella linux distribution

## Instructions

### Installing required packages

To use `yocto` you first need to install some packages. See latest [Yocto Project Quick Start](http://www.yoctoproject.org/docs/latest/yocto-project-qs/yocto-project-qs.html). This assumes you are working on a Ubuntu machine:

```bash
$ sudo apt-get install gawk wget git-core diffstat unzip texinfo gcc-multilib build-essential chrpath socat libsdl1.2-dev xterm
```

### Cloning the super project

Clone git@github.com:peteasa/parallella onto your Linux build machine:
```bash
$ git clone git@github.com:peteasa/parallella
$ cd parallella
```

To prepare the environment and download the necessary git submodules, you need to run the `initgitsubmodules.sh` script. This only needs to be done once:

```bash
$ source initgitsubmodules.sh
```

```bash
$ cd parallella-yoctobuild
```

The result will be new folders in the submodule `parallella/parallella-yoctobuild`, these are `poky`, `meta-xilinx`, `meta-parallella`, `meta-epiphany`, `meta-exotic` and `meta-example`, created from specific commits on github.

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

Other images to build can be found in `meta-example/recipes/images` and `meta-parallella/recipes-epiphany/images`

The result will be a complete build for the parallella board built on the build machine

`parallella/parallella-yoctobuild/build_parallella/tmp/deploy/images/parallella-hdmi`

Plus for free a complete distribution folder that you publish from a web server to update specific packages on the target - just like you use when you run `sudo apt-get install` on your Linux build machine.  This project uses [smart](https://labix.org/smart) as the package manager on the target:

```bash
$ smart update
$ smart upgrade
```

The SDK is found at `parallella/parallella-yoctobuild/build_parallella/tmp/deploy/sdk`

### Links to other information

Troubleshooting notes - [Troubleshooting notes](https://github.com/peteasa/parallella-yoctobuild/wiki/Troubleshooting-notes)

Instructions for contributors - [Instructions for contributors](https://github.com/peteasa/parallella-yoctobuild/wiki/Instructions-for-contributors)


---------------------------------------

  * TODO instructions for writing to the SD card.
