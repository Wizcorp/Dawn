# registry

Runs a docker registry on the control nodes, and sets up `docker_auth` with a
connection to ldap to allow users to login/logout to the registry.

This role can just be skipped if you are instead using GitLab to provide your
registry.

## Variables

* `registry_image = registry`
* `registry_version = 2`
* `docker_auth_image = cesanta/docker_auth`
* `docker_auth_version = 1`
