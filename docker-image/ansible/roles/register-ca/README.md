# register-ca

Registers a vault CA with each host's trusted CA folder by saving it on each
host's [anchors](http://wiki.cacert.org/FAQ/ImportRootCert#Linux)
folder and running `update-ca-certificates`.

This allows containers to trust the local self-signed CAs by mounting
`/etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem`.

## Usage

```yaml
dependencies:
  - role: register-ca
    backend: my-ca-name
```

## Variables

* `backend`: The name of the backend to create