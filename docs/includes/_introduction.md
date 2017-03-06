<h1 style="margin-top: 0.3em;">Introduction</h1>

## What is Dawn?

Dawn is a set of tools and configuration to help you bootstrap and maintain a Docker-based PaaS. 
On top of configuring Docker Swarm, Dawn also configures and maintain the systems required for 
traffic routing, service discovery, logging, monitoring and storage.

## Why use Dawn?

### Multi-platform client

You can run `dawn` to set up both local and remote environments
from Windows, Linux and macOS.

Note that throughout this documentation, you can switch the samples
found on the right of this content between their `shell` (bash, zsh, etc)
and PowerShell versions.

### All the basics

Dawn infrastructures include all the basics (what we sometimes
refer to as the Primary Infrastructure). On top of setting
up a Docker Swarm cluster for you, it also sets up the endpoints 
for log and metrics aggregation, service discovery, distributed storage 
and route management. Once you are done provisioning your cluster,
you should be able to `docker deploy` or `docker service` be up and running.

But it goes beyond this; all the tools (suck as `docker`, `ansible`, etc),
playbooks and templates for configuring clusters are shipped in a Docker 
image which `dawn` uses at runtime. So in general, all you need to
get started is Docker, and Dawn itself, making local installation and usage
as simple as can be.

### Deploy anywhere

Dawn ships with templates; templates are a set of files and configuration 
which you will need to customise and version.

Most templates will simply use a combination of `terraform` and `ansible`
configurations to describe your desired architecture. This means that 
to use Dawn, you do not need to learn new tools; Dawn only makes it easier
to simply use the ones you already know.

### Versioned and customisable

> Example ./dawn/dawn.yml configuration

```yaml
project_name: hello-world
image: 1.0.0 # This will be used as the default version

environment: 
    # Bump the image version number for the staging environment
    staging: 
        image: 1.0.1

    # Maintain an experimental environment using a custom local container
    experimental:
        image: stelcheck/dawn-custom:latest
```

When creating a new environment, we hard-code the version of the local Docker image
used; this means that whenever you will come back to this environment at a later time,
you will be able to re-run the same playbooks with the same tools at the same version
as you initially did.

You can also create your own local Docker containers, and configure your
Dawn environment to use that instead; this way, you can add or customise tools
and configurations to your liking, and then distribute the setup to the 
rest of your team.

And this is not only true for Docker images, but for the project as a whole;
you should be able to create your own build pipelines, inserting the customisations
you wish to either the base image, the `dawn` local binary or even generate your own
documentation. You should be able to create your own `myorg-dawn` in no time!

### Easy to develop and improve

> This script will also automatically build both the Docker image and the binary

```shell
~/Sources/Dawn $ ./scripts/development/bash.sh
# [...]

# Run the copy of dawn we just built
~/Sources/Dawn [dawn development] $ dawn --help

dawn starts a pre-configured docker container on your local machine,
# [...]

# Rebuild
~/Sources/Dawn [dawn development] $ rebuild
```

```powershell
PS C:\Users\stelcheck\Sources\dawn> .\scripts\development\powershell.ps1

# [...]

# Run the copy of dawn we just built
PS [dawn-development] C:\Users\stelcheck\Sources\dawn> dawn --help

dawn starts a pre-configured docker container on your local machine,
# [...]

# Rebuild
PS [dawn-development] C:\Users\stelcheck\Sources\dawn> rebuild
```

Just like our client, our development and build environments are
multi-platform. But we also spent additional time to make sure
that getting set up for developing Dawn would be as easy as possible.
For instance, just like for using Dawn, Docker is the only required 
dependency; the entirely build toolchain has been Dockerized to ensure
that you will never have to figure out how to install

We believe this to be important because not only should it be easy for newcomers
to contribute to Dawn, but we might also need help from the community
do debug issues on versions of Dawn yet to be released. To us, if
its not easy, its a bug.

And did we mention that everything is customisable? Even if we
were to stop maintaining the project, or if you had to maintain
a fork of the dawn toolchain for your organisation, you will be able
to get yourself set up in no time.

## Help and support

Outside of this documentation, you can find support online on 
[Gitter](https://gitter.im/Wizcorp/Dawn) and
[StackOverflow](https://stackoverflow.com/questions/tagged/dawn); 
if you suspect a bug, please feel free to 
[submit an issue](https://github.com/Wizcorp/Dawn/issues/new).

## Contributing

We always welcome new contributors! 

First, you will want to start by [reading the contribution guide](https://github.com/Wizcorp/Dawn/blob/develop/CONTRIBUTING.md).
There, we explain in more details how the project is structured, how
to set yourself up for development and how to submit new code.

In the case of submitting new features, we strongly recommend to first
[create an issue](https://github.com/Wizcorp/Dawn/issues/new) to 
discuss your idea; this way, you will be able to discuss and 
confirm with the rest of the community that this feature belongs 
in Dawn.
