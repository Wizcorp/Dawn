![Logo](./logo.png)

Dawn is a set of tools and configuration to help you bootstrap and maintain
a Docker-based PaaS. On top of configuring Docker Swarm, Dawn also
configures and maintain the systems required for traffic routing, service
discovery, logging, monitoring and storage.

Requirements
------------

|  Software  | Version |
|------------|---------|
| Docker     | 1.13.0+ |

Quick Start
-----------

The Dawn client consists of two components:

  - A small binary to run on your local machine
  - A local Docker container, containing playbooks
    and tools (Ansible, Terraform, Docker binaries, etc.)

Because tools and basic playbooks are bundled together
into a single Docker image, it makes it easier
to manage multiple deployments (by using a specific version of the
local container). It also makes it easier to create custom Docker
images (additional tools, playbook customisations, etc).

### Windows

```powershell
# Must run as administrator
Invoke-RestMethod https://dawn.sh/install-win | powershell -command -
# Or, to install a specific version
Invoke-WebRequest -uri https://dawn.sh/install-win -OutFile install.ps1
.\install.ps1 -version v0.0.1
```

### Other platforms (Linux, macOS)

```bash
# Will request sudo password after download
curl -fsSL https://dawn.sh/install | sh
# Or, to install a specific version
curl -fsSL https://dawn.sh/install | version=v0.0.1 sh
```

### Using Dawn

For a more elaborate walkthrough video, see [this tutorial](link-to-asciivideo).
You can also find the [documentation here](./docs-coming-soon).

What does it include?
---------------------

|  System                 | Software            |
|-------------------------|---------------------|
| Container execution     | [Docker Swarm](https://www.docker.com/products/docker-swarm)    |
| Traffic routing         | [Traefik](https://traefik.io/)         |
| Service discovery       | [Consul](https://www.consul.io/)          |
| Logging                 | [Kibana](https://www.elastic.co/products/kibana)          |
| Metrics                 | [Grafana](https://grafana.net/)         |
| Storage                 | [Ceph](https://ceph.com/)            |

We also install additional subsystems which will sit behind each components above;
for instance, logs are collected using [FluentD](http://www.fluentd.org/)
and are sent to [ElasticSearch](https://www.elastic.co/products/elasticsearch),
while metrics are collected with [Telegraf](https://github.com/influxdata/telegraf)
before being sent to [Prometheus](https://prometheus.io/).

For a more detailed view of what software Dawn will install for you, please
see the [ansible folder](./ansible).

Contributors
------------

Before contributing, please make sure to get familiar with [this document](./CONTRIBUTING.md)

All new contributors are welcome.

Local Development
-----------------

You will need the latest version of vagrant for that, for a quick start just run `vagrant up` in the current folder
and it will start a basic cluster with 2 workers, 1 edge and 1 control (6.5GB of memory necessary). If you want to
experiment with different types of clusters, create a copy of `instances.yml` under a new name then modify it to your
liking, then `export DAWN_CONFIG_FILE="my-config.yml"` to use it.

Once everything is up you should be able to access the different services on the IPs set inside your configuration file.

Credits
-------

### Logo

Nature graphic by <a href="http://www.flaticon.com/authors/freepik">Freepik</a>
from <a href="http://www.flaticon.com/">Flaticon</a> is licensed under
<a href="http://creativecommons.org/licenses/by/3.0/" title="Creative Commons BY 3.0">CC BY 3.0</a>.
Made with <a href="http://logomakr.com" title="Logo Maker">Logo Maker</a>

License
-------

Private.

Copyrights
----------

@wizcorp 2017 - All rights reserved
