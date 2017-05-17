# traefik

Traefik is the de-facto http load balancer that comes with Dawn, allowing users
to easily expose services by using docker swarm labels.

## Variables

* `traefik_version = v1.2.3`
* `traefik_image = "traefik:{{ traefik_version }}"`
* `traefik_stack = traefik`
* `traefik_stack_file = /opt/dawn/traefik.yml`
* `traefik_domain = "{{ local_domain_name }}"`
* `traefik_extra_args`: Add extra arguments to the traefik command line