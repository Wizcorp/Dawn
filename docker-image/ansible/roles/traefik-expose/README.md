# traefik-expose

Designed to be used as a dependency, creates traefik entries in consul to
expose services that might not be running in swarm (ie. vault, ldap, etc...).

## Usage

```yaml
dependencies:
  - role: traefik-expose
  	# required
    service_name: grafana
	# required
    service_port: 3000
	# optional, defaults to {{ private_ipv4 }}
    service_ip: "{{ group_ipv4.monitor[0] }}"
	# optional, defaults to http
	service_scheme: https
```