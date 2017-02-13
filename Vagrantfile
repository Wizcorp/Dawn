# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'

# generates the inventory file for our setup
def generate_inventory(configuration)
  inventory_filename = File.expand_path('ansible/inventory', File.dirname(__FILE__))
  inventory_file = File.new(inventory_filename, "w")

  groups = {}

  # first write the instance informations
  configuration["instances"].each do |instance_name, instance_info|
    private_key = File.expand_path(".vagrant/machines/#{instance_name}/virtualbox/private_key", File.dirname(__FILE__))

     ansible_vars = [
      instance_name,
      "ansible_ssh_host=#{instance_info["ip"]}",
      "ansible_ssh_port=22",
      "ansible_ssh_user=#{configuration.fetch("user", "vagrant")}",
      "ansible_ssh_private_key_file='#{private_key}'",
      "docker_labels='#{instance_info["labels"].to_json}'"
    ]

    #ansible_vars.push (if instance_info.fetch("swarm", "worker") == "worker" then "swarm_worker=True" else "swarm_leader=True" end)

    inventory_file.puts ansible_vars.join(" ")

    instance_info["groups"].each do |group, _|
      groups.store(group, []) unless groups.has_key?(group)
      groups[group].push instance_name
    end
  end

  # write groups
  groups.each do |group_name, instances|
    inventory_file.puts "\n[#{group_name}]"
    instances.each do |instance|
      inventory_file.puts instance
    end
  end

  # finally some useful variables related to vagrant
  inventory_file.puts <<-vars

[all:vars]
private_interface=eth1

vars

  inventory_file.close
end

Vagrant.configure("2") do |config|
  # load configuration
  configuration = YAML::load_file("instances.yml")

  config.vm.box = configuration["image"]

  # generate the inventory
  generate_inventory(configuration)

  configuration["instances"].each do |instance_name, instance_info|
    config.vm.define instance_name do |instance|
      instance.vm.provider "virtualbox" do |vb|
        # Customize the amount of memory on the VM:
        vb.linked_clone = true
        vb.memory = instance_info['memory'].to_s # for some reason virtualbox wants a string here
        vb.cpus = instance_info['cpus']
      end

      # we don't need this (also causes issues with centos 7 image)
      instance.vm.synced_folder ".", "/vagrant", disabled: true

      instance.vm.hostname = instance_name
      instance.vm.network :private_network, ip: instance_info['ip']

      # The base xenial box doesn't have python installed so we need to install it manually
      # We also boost the max map count, though it's only used by elasticsearch
      instance.vm.provision "shell", inline: <<-SHELL
        if
          [[ ! -f /usr/bin/python ]];
        then
          apt-get update
          apt-get install -y python-minimal
        fi

        [[ -f /etc/redhat-release ]] && systemctl restart network
SHELL

      # only run ansible once everything is up
      if instance_name == configuration["instances"].keys.last
        instance.vm.provision "ansible" do |ansible|
          ansible.limit = "all"
          ansible.playbook = "ansible/compute-node.yml"
          ansible.galaxy_role_file = "ansible/dependencies.yml" if ENV['DAWN_SKIP_GALAXY'].nil?
          ansible.inventory_path = "ansible/inventory"
          ansible.host_key_checking = false
        end
      end
    end
  end
end
