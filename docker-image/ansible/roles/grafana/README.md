# grafana

Installs grafana in docker and preconfigure it with prometheus and a docker
dashboard.

## Requirements

* Prometheus running in docker

## Variables

* `grafana_image = grafana/grafana`
* `grafana_version = 4.2.0`
* `grafana_user = admin`
* `grafana_password = admin`
* `grafana_link_to_container = prometheus`

## TODO

* More configuration on how to query/connect to the remote LDAP server
