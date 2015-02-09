# parallella-yoctobuild

START HERE - A Simple build environment for [Parallella](http://www.parallella.org/) using [Yocto](http://www.yoctoproject.org/)

## Instructions

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

Plus for free a complete distribution folder that you publish from a web server to update specific packages on the target - just like you use when you run `sudo apt-get install` on your Linux build machine:

```bash
$ parallella-yoctobuild/build_parallella/tmp/deploy/rpm
```

The SDK is found at `parallella-yoctobuild/build_parallella/tmp/deploy/sdk`

---------------------------------------

  * TODO instructions for writing to the SD card.
  * TODO instructions for contributors.
  * TODO how to apt-get install any other packages needed - e.g. `chrpath`, `libsdl-native`.
