# parallella-yoctobuild y2024.2

The aim of this project is to create an hdmi version for the parallella board using an fpga built from the oh project with the latest Epiphany SDK

A Simple build environment for [Parallella](http://www.parallella.org/) using [Yocto](http://www.yoctoproject.org/)

One branch is significant in this repository:

- [y2024.2](https://github.com/peteasa/parallella-yoctobuild/tree/y2024.2) - this branch 

## Instructions

### Installing required packages


### Cloning this repository

Clone this repository onto your Linux build machine:

```bash
$ git clone git@github.com:peteasa/parallella-yoctobuild --recurse-submodules
$ cd parallella-yoctobuild
$ git checkout y2024.2
```

Make sure submodules are set up correctly

```bash
$ git submodule update --init
```

The result will be new folders `poky`, `meta-parallella` and `meta-epiphany` created from specific commits on github.

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

I am building up a new set of notes about FGPA and embedded development Linux here: [PYNQ-e](https://paracpg.gitlab.io/).

Please feel free to open a Discussion or an Issue if you are having problems!
