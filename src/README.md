dawn binary
===========

The dawn binary is essentially a wrapper around `docker run`;
it takes care of ensuring that a `./dawn` folder exists in your 
project, and that a `./dawn/dawn.yml` configuration file is present.


```bash
dawn starts a pre-configured docker container on your local machine,
from which you can set up and manage your deployments.

Usage: dawn [environment] [command]

    environment    The environment you wish to set up for
    command        Command you wish to run (or run bash if omitted)

Flags

    --update       Update this binary
    --version      Show version information
    --help         Show this screen

For more information: https://dawn.sh/docs
```
