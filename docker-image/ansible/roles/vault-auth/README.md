# vault-auth

Authenticate to a vault server, unsealing it automatically if it is sealed and
the playbook has access to the server keys. Mainly used as a dependency in many
roles.

## Requirements

For authentication, `vault_local_ansible_config` is required to point to an
existing file that contains an admin `role_id` and `secret_id` in json format.

For automatic unsealing, `vault_local_root_config` must exists and contains the
unseal keys for the server.

Both files are generated at bootstrap time and should be securely saved
somewhere safe.

## Usage

```yaml
dependencies:
  - vault-auth
```

## Variables

* `vault_local_root_config: "/home/dawn/.vault.root.conf"`
* `vault_local_ansible_config: "/home/dawn/.vault.ansible.conf"`
* `vault_addr: "http://127.0.0.1:8200"`