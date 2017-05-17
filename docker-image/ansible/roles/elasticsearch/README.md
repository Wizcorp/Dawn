# elasticsearch

Installs elasticsearch through docker

## Variables

* `elasticsearch_image = docker.elastic.co/elasticsearch/elasticsearch`
* `elasticsearch_version = 5.4.0`
* `elasticsearch_java_opts = "-Xms512m -Xmx512m"`
* `logstash_image = docker.elastic.co/logstash/logstash`
* `kibana_image = docker.elastic.co/kibana/kibana`

Both the logstash and kibana images use the `elasticsearch_version` variable
to always be on the same version as elasticsearch.

## TODO:

* Make the storage configurable
* Support for X-Pack and LDAP