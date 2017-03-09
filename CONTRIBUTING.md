Contributing
============

Before getting started
----------------------

Make sure to read the [Concepts](https://dawn.sh/docs#concepts)
part of the documentation. If you wish to add or alter a feature, 
please create an issue to present your idea first; this should make it
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

All scripts for building, developing and releasing the Docker image,
the binary and the documentation can be found under the `./script`
folder.

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
  4. Make the binary mount `./docker-image/ansible`, `./docker-image/templates` and
     `./docker-image/scripts` at runtime (so you will not need to rebuild the 
     Docker image every time you make a change to either folder's content)
  5. Open a sub-shell

Once you are in the sub-shell, you can run `dawn` anywhere. From there, you will normally want
to set up a local environment; you will be using this environment to run the playbook against.
Simply run `dawn local`, and select the local template to get started.

### Building

From within the shell, you can run:

```
# Rebuild all
rebuild

# Or rebuild just a part
rebuild-image
rebuild-binary
rebuild-docs
```

You may also call the scripts those commands point to directly; you will find
them under the `./scripts` folder.

Releasing
---------

To make a release, update `buildconfig.yml`, then:

```bash
./scripts/release/release.sh
```

Unfortunately, the release script has not been ported to PowerShell yet.
