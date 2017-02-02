Contributing to Dawn
====================

Before getting started
----------------------

Make sure to read the [Architecture Overview](https://docs.google.com/document/d/1l5bsWv6ARzTVkm9x84ONRJS0tzwvQeuIdP3CStg3Mro/edit#) 
document. If you wish to add or alter a feature, please create an issue to present your idea first; this should make it
easier for your contributions to get merged afterward.

Requirements
------------

**Note**: you will need at least 8GB of available memory to start all 5 VMs locally.

|  Software  | Version |
|------------|---------|
| Virtualbox | 5.1.14+ |
| Vagrant    | 1.9.1+  |
| Ansible    | 2.2+    |

Quick Start
-----------

Run vagrant up, wait for it to finish, once finished set your DNS to point to 10.0.0.50 and you should get access to:

* Docker Swarm:
  - Leader-1: 10.0.0.50:2376
  - Worker-1: 10.0.0.100:2376
  - Worker-2: 10.0.0.101:2376
  - Balancer: 10.0.0.200:2376
* Monitoring:
  - Kibana: http://10.0.0.20:5601/
  - ElasticSearch: http://10.0.0.20:9200/
  - Grafana: http://10.0.0.20:3000/ (admin:admin)
* Service Discovery:
  - Consul: http://10.0.0.20:8500/ui/
  - Consul DNS: 10.0.0.20:8600
  - DNSMasq DNS: 10.0.0.20:53
* Load Balancing:
  - Traefik: http://10.0.0.200

Docker Swarm
------------

Leader-1 is acting as the manager, just run `export DOCKER_HOST=10.0.0.50:2376` and you should be able to start sending
commands to the swarm manager.

All logs are forwarded to kibana, just go to http://10.0.0.20:5601/ and use the default settings when asked on the first
connection, logs should appear inside the top tab of Kibana.