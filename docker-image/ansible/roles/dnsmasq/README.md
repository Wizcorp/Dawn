# dnsmasq

Install dnsmasq on the server to act as a relay for the consul DNS, also adds
the `local_domain_name` to point to the edge nodes, as well as providing the
`dockerhost` hostname that points to the local machine's public IP.

Also updates the dhclient configuration to point `/etc/resolv.conf` to the
installed instance of dnsmasq.

## Variables

None