Contributing
============

Before getting started
----------------------

Make sure to read the
[Architecture Overview](https://docs.google.com/document/d/1l5bsWv6ARzTVkm9x84ONRJS0tzwvQeuIdP3CStg3Mro/edit#)
document. If you wish to add or alter a feature, please create an
issue to present your idea first; this should make it
easier for your contributions to get merged afterward.

Requirements
------------

**Note**: you will need at least 8GB of available memory (16GB recommended)
to start all 5 VMs locally.

|  Software  | Version | Note                    |
|------------|---------|-------------------------|
| Docker     | 1.13+   |                         |
| Vagrant    | 1.9.1+  |                         |
| Virtualbox | 5.1.14+ | Not required on Windows |


Quick Start
-----------

All scripts for building, developing and releasing Dawn's docker image and binary are
under `./script`.

### Development

#### macOS, Linux

```bash
./scripts/development/bash.sh
```

#### Windows

```posh
.\scripts\development\powershell.ps1
```

#### Details

The development scripts will:

  1. Make a local build of the docker image (`./docker-image`)
  2. Make a local build of the local binary (`./src`)
  3. Add `./src/dist/[platform]/` to your PATH (env:Path on Windows)
  4. Make the binary mount `./docker-image/ansible` and `./docker-image/templates` at runtime 
     (so you will not need to rebuild the Docker image every time you make a change to either 
     folder's content)
  5. Open a sub-shell

Whenever you need to rebuild the project, simply type `rebuild`.

Once you are in the sub-shell, you can run `dawn` anywhere. From there, you will normally want
to set up a local environment; you will be using this environment to run the playbook against.
Simply run `dawn local`, and select the local template to get started.

### Building

#### macOS, Linux

```bash
./scripts/build/nix.sh [version number, default: development] [darwin|windows|linux|all, default: local platform]
```

#### Windows

```posh
.\scripts\build\windows.ps1 [-version version number, default: development] [-target darwin|windows|linux|all, default: windows]
```

#### Details

The build script will
  
  1. Build the docker image, and tag it with dawn:[version number] 
  2. Build the local binary and assign it [version number] as the default 
     image and the binary's own version (if target is `all`, binaries for all
     supported platforms will be built)

Releasing
---------

To make a release:

```
git tag v0.0.1
./scripts/release/release.sh
```
