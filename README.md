# parallella-yoctobuild elink-redesign

The aim of this project is to create an hdmi version for the parallella board using an fpga built from the oh project with 2015.1 SDK

A Simple build environment for [Parallella](http://www.parallella.org/) using [Yocto](http://www.yoctoproject.org/)

Two branches are significant in this repository:

- [elink-redesign](https://github.com/peteasa/parallella-yoctobuild) - this branch 
- [parallella-elink-redesign](https://github.com/peteasa/parallella-yoctobuild/tree/parallella-elink-redesign) - contains an example layer that demonstrates how to extend the yocto build to add your own design.  See the [parallella](https://github.com/peteasa/parallella/wiki) project for more details and Tutorials

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

The result will be new folders `poky`, `meta-xilinx`, `meta-parallella`, `meta-epiphany` and `meta-exotic` created from specific commits on github.

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

### Adding your own projects or modifying this environment

Yocto allows you to inherit from recipes and override things that you need to replace.  In practice, to tailor this environment to your own requirements you only have to create a version of the bblayers.conf and local.conf files that suit your needs and copy them to build_parallella/conf at the appropriate time.  The .gitignore file in this environment allows you to create folders like:

```bash
$ mkdir meta_mywork
$ mkdir meta-project
$ mkdir meta-projects
$ mkdir meta-test
```

the above folders will remain ignored by git system.  With your version of local.conf and bblayers.conf and any additional layers or bbappend recipes stored in one of these four folders it is then possible to create the build that you need whilst at the same time being able to easily take new versions of this environment with a simple git update.  So you dont need to modify any of the files I provide, making git updating easier (no conflicts or local checked out files).

Your workflow would be:

```bash
$ cd meta-project
$ source prepare-project.sh
```

prepare-project.sh would contain something like:
```
#!/bin/sh

cd ..
source poky/oe-init-build-env build_parallella
cp ../meta-project/local_conf/*.conf ./conf
```

### Links to other information

Tutorials - [](https://github.com/peteasa/parallella/wiki/Tutorial-index)

Troubleshooting notes - [Troubleshooting notes](https://github.com/peteasa/parallella-yoctobuild/wiki/Troubleshooting-notes)

Instructions for contributors - [Instructions for contributors](https://github.com/peteasa/parallella-yoctobuild/wiki/Instructions-for-contributors)

Instructions for  writing to the SD card - [Create SD card](https://github.com/peteasa/parallella/wiki/Create-SD-card)
