# vault

Wraps around the [AerisCloud.vault](https://github.com/aeriscloud/ansible-vault)
role and adds TLS certificate management on top of it. The server is configured
to listen unencrypted on localhost and through TLS on the public IP.

Currently it does not verify the client certificates, this is done to prevent
users from locking themselves out of a cluster, and should be fine since vault
has proper auth mechanisms on it's own.

## Variables

* `vault_key_file: /etc/ssl/certs/vault/server.key.pem`
* `vault_cert_file: /etc/ssl/certs/vault/server.cert.pem`
* `vault_ca_file: /etc/ssl/certs/vault/server.ca.pem`
* `vault_client_key_file: /etc/ssl/certs/vault/client.key.pem`
* `vault_client_cert_file: /etc/ssl/certs/vault/client.cert.pem`
* `vault_client_ca_file: /etc/ssl/certs/vault/client.ca.pem`
* `vault_server_max_ttl: 17520h`
* `vault_client_max_ttl: 8760h`
