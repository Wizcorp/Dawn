# common

Does tasks common to all systems:

* Set the timezone
* Set the hostname to match the inventory name
* Add all hosts in the cluster to /etc/hosts
* When running on CentOS enable EPEL
* Allows upgrading the system

## Variables

* `timezone = UTC`: Set the timezone of the machine
* `system_upgrade`: When set to 1, will upgrade all packages on the system