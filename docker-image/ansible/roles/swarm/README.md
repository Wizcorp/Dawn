# swarm

Initializes swarm and lets other managers and workers join it. The role of each
node is currently determined by which group it is part of among `control`, `edge`
or `worker`.

## Variables

* `swarm_docker_url = ""`
* `swarm_leader = "{{ groups['control'][0] == inventory_hostname }}"`
* `swarm_manager = "{{ (inventory_hostname in groups['control'] and groups['control'][0] != inventory_hostname) or inventory_hostname in groups['edge'] }}"`
* `swarm_worker = "{{ inventory_hostname not in groups['control'] and inventory_hostname not in groups['edge'] }}"`
* `swarm_remote_addrs = []`
* `swarm_listen_addr = 0.0.0.0`
* `swarm_listen_addr = 172.18.0.1/16`
* `swarm_advertise_addr = "{{ private_ipv4 }}"`
