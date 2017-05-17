# consul

Installs consul in a secure manner by wrapping [AerisCloud.consul](https://github.com/aeriscloud/ansible-consul).
We generate a custom TLS certificate on the fly and set the server to listen
unsecured on 127.0.0.1 and secure on the machine's external IP.

We store both the server and client certificates on the each machine so that
docker containers can mount the client certificate and talk with the consul
cluster.

## Variables

* `consul_key_file = /etc/ssl/certs/consul/server.key.pem`: Where to store the server TLS key
* `consul_cert_file = /etc/ssl/certs/consul/server.cert.pem`: Where to store the server TLS cert
* `consul_ca_file = /etc/ssl/certs/consul/server.ca.pem`: Where to store the server TLS CA
* `consul_client_key_file = /etc/ssl/certs/consul/client.key.pem`: Where to store the client TLS key
* `consul_client_cert_file = /etc/ssl/certs/consul/client.cert.pem`: Where to store the client TLS cert
* `consul_client_ca_file = /etc/ssl/certs/consul/client.ca.pem`: Where to store the client TLS CA
* `consul_server_max_ttl = 17520h`: The TTL of the server certificate
* `consul_client_max_ttl = 8760h`: The TTL of the client certificate
