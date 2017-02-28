Contributing
============

Before getting started
----------------------

Make sure to read the
[Architecture Overview](https://docs.google.com/document/d/1l5bsWv6ARzTVkm9x84ONRJS0tzwvQeuIdP3CStg3Mro/edit#)
document. If you wish to add or alter a feature, please create an
issue to present your idea first; this should make it
easier for your contributions to get merged afterward.

Requirements
------------

**Note**: you will need at least 8GB of available memory to start all 5 VMs locally.

|  Software  | Version |
|------------|---------|
| Virtualbox | 5.1.14+ |
| Vagrant    | 1.9.1+  |
| Docker     | 1.13+   |
| Go	     | 1.7+    |

Quick Start
-----------

### `dawn` binary

You can run the `dawn` binary from the current codebase as follow:

```bash
go run ./src/dawn.go [arguments]
```

See [./src/README.md] for more details (how to build, etc).

### Local container

You will need to build the local container as follow:

```bash
docker build . -t dawn:development
```

You will need to run this command every time you make a change
to the content of the container; however, this step is not necessary
when you are making changes to either templates or Ansible playbook.
Instead, set the following environment variable to make `dawn` mount
the related folders onto the container:

```bash
# *nix
export DAWN_DEVELOPMENT=$(pwd)
# Windows
set env:DAWN_DEVELOPMENT="$pwd"
```

### Ansible playbook development

Simply make your change, create a local environment and
run provision. From the project's root, you can run:

```bash
export DAWN_DEVELOPMENT=$(pwd)
go run ./src/dawn.go local
# Select the local template, then start provisioning
cd dawn/local
vagrant up
cd ../..
go run ./src/dawn.go local 

# Then, from inside the container
ansible-playbook /dawn/ansible/dawn.yml
```

### Templates development

Template development works in the same way as Ansible 
playbook development.




