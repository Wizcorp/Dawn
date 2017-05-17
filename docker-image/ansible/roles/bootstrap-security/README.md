# bootstrap-security

This role takes care of the initial security bootstrap for your cluster, it will
run on your first control node and do in order:

1. Install consul listening only on localhost
2. Install vault listening only on localhost with consul as a backend
3. Init vault, save the unseal keys and root token in `.vault.root.conf` in the
  user storage folder
4. Create the root CA and tune it properly
5. Create an ansible approle to be used for provisioning, with the role and
  secret id saved in `.vault.ansible.conf`
6. Store a small file to mark the bootstrap success and prevent running it again

## Variables

Usually you won't need to change those beside the TTL durations to match the
security requirements of your organization.

* `vault_root_ca_ttl = 87600h`: How long the root CA is valid
* `vault_ansible_token_tt = 7200`: Default token TTL for ansible role
* `vault_ansible_token_max_ttl = 7200`: Max token TTL for ansible role
* `vault_ansible_secret_id_ttl = 31536000`: How long the secret id is valid (in seconds)
* `vault_ansible_secret_id_num_uses = 0` How many times the secret can be used
* `vault_local_root_config = "{{ local_storage_dir }}/.vault.root.conf"`: Where to store the root informations
* `vault_local_ansible_config = "{{ local_storage_dir }}/.vault.ansible.conf"`: Where to store the ansible login info
