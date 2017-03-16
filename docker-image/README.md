Local image, Ansible and templates
==================================

The dawn local image contains:

  1. All the tools required, at the desired version. This includes:
      - Ansible (ansible ansible-playbook, ansible-console) 
      - Terraform
      - Docker binaries
  2. Ansible playbook to provision a Dawn cluster
  3. Templates

When a user runs `dawn [environment] [optional command]`, 
the local binary will start a throw-away container and
set it up:

  1. Mount `/home/dawn` to your local machine's configuration folder
     (`~/Libary` on macOS, `~/AppData` on Windows, etc) to store ssh keys, 
     bash history, and other user-specific files
  2. Mount `/dawn/project` to your project's folder, so that you may have access
     to all its files (including, of course, the ones specific to the environment
     the user wishes to provision)

If the environment you are refering to does not exist in your project,
the container will invite the user to create it using one of the templates:

```bash
The local environment does not exist. Would you like to create it? [y/n]: y

You have the option to set up your new environment from a template:

    local                Local test environment (requires Vagrant)
    baremetal            Baremetal datacenter (using Ansible)
    aws                  AWS setup (using Terraform and Ansible)

Select one, or press Enter to skip: local

This container will now exit; please run the following locally:

  cd ./dawn/local

  # On Linux, macOS
  vagrant up

  # On Windows
  .\vagrant-up.ps1

  cd  ../..

Then run 'dawn local' once again
to open a shell and start provisioning
```
    