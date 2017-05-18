# prometheus

Prometheus is a time series database, this role runs it inside docker and lets
it pull monitoring targets through consul.

To have a service monitored by prometheus, announce it inside consul with the
`monitoring` tag and it will start pulling the data automatically.

## Variables

* `prometheus_image = prom/prometheus`
* `prometheus_version = v1.6.1`

## TODO

* Run prometheus as a service so that containers do not have to export ports for
  monitoring but instead just use the prometheus network.