# docker

Wraps the [AerisCloud.docker](https://github.com/aeriscloud/ansible-docker) role
and adds TLS certificate management on top of it as well as enabling service
discovery for consul.

## Variables

* `docker_key_file = /etc/ssl/certs/docker/server.key.pem`
* `docker_cert_file = /etc/ssl/certs/docker/server.cert.pem`
* `docker_ca_file = /etc/ssl/certs/docker/server.ca.pem`
* `docker_client_key_file = /etc/ssl/certs/docker/client.key.pem`
* `docker_client_cert_file = /etc/ssl/certs/docker/client.cert.pem`
* `docker_client_ca_file = /etc/ssl/certs/docker/client.ca.pem`
* `docker_server_max_ttl = 17520h`
* `docker_client_max_ttl = 8760h`