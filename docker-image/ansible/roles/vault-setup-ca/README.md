# vault-setup-ca

Used as a dependency by roles to create an intermediate CA used for generating
self-signed TLS certificates.

## Usage

```yaml
dependencies:
  - role: vault-setup-ca
    backend_name: docker
    server_ttl: 17520h
    client_ttl: 8760h
```

## Variables

* `vault_root_ca_ttl: 87600h`
* `vault_intermediate_ca_ttl: 17520h`
* `vault_server_max_ttl: 17520h`
* `vault_client_max_ttl: 8760h`