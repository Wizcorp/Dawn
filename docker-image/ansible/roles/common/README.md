# common

Does tasks common to all systems:

* Set the timezone
* Set the hostname to match the inventory name
* Add all hosts in the cluster to /etc/hosts
* When running on CentOS enable EPEL

## Variables

* `timezone = UTC`: Set the timezone of the machine