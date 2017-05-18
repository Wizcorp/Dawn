# openldap

Starts an openldap server and phpldapadmin instance on docker.

If `ldap_external_server` is defined it will skip the installation. Remember to
set `ldap_server` to point to your actual server!

## Variables

* `ldap_server_max_ttl = 17520h`
* `ldap_client_max_ttl = 8760h`
* `ldap_cert_file = /etc/ssl/certs/ldap/server.key.pem`
* `ldap_key_file = /etc/ssl/certs/ldap/server.cert.pem`
* `ldap_ca_file = /etc/ssl/certs/ldap/server.ca.pem`
* `ldap_organisation = Dawn`
* `openldap_image = osixia/openldap`
* `openldap_version = 1.1.8`
* `phpldapadmin_image = osixia/phpldapadmin`
* `phpldapadmin_version = 0.6.12`
