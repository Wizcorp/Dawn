# telegraf

Telegraf is a tool that collect metrics and makes them available for prometheus.
It exposes metrics on port 9126, path `/metrics` of each node.

## TODO

* Add support for enabling extra plugins. For now users can drop configuration
  files inside the `/etc/telegraf/telegraf.d/` folder and restart the service.