# -*- mode: ruby -*-
# vi: set ft=ruby :

class Machine
  attr_reader :name, :ip, :groups, :memory
  def initialize(name, ip, groups, memory: "1024")
    @name = name
    @ip = ip
    @groups = groups
    @memory = memory
  end
end

class Container
  attr_reader :image, :cmd, :args
  def initialize(image, cmd: "", args: "")
    @image = image
    @cmd = cmd
    @args = args
  end
end

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/xenial64"
  #config.vm.box = "centos/7"

  machines = [
    # monitor needs 4G due to elasticsearch
    Machine.new("monitor",  "10.0.0.20",  ["docker", "consul"], memory: "4096"),
    Machine.new("leader-1", "10.0.0.50",  ["docker", "swarm", "consul"]),
    Machine.new("worker-1", "10.0.0.100", ["docker", "swarm", "consul"]),
    Machine.new("worker-2", "10.0.0.101", ["docker", "swarm", "consul"]),
    Machine.new("balancer", "10.0.0.200", ["docker", "swarm", "consul"])
  ]

  machines.each_index do |machine_id|
    machine_info = machines[machine_id]

    config.vm.define machine_info.name do |machine|
      machine.vm.provider "virtualbox" do |vb|
        # Customize the amount of memory on the VM:
        vb.linked_clone = true
        vb.memory = machine_info.memory
        vb.cpus = 2
      end

      machine.vm.hostname = machine_info.name
      machine.vm.network :private_network, ip: machine_info.ip

      # The base xenial box doesn't have python installed so we need to install it manually
      # We also boost the max map count, though it's only used by elasticsearch
      machine.vm.provision "shell", inline: <<-SHELL
        if
          [[ ! -f /usr/bin/python ]];
        then
          apt-get update
          apt-get install -y python-minimal
        fi

        [[ "$( cat /proc/sys/vm/max_map_count )" -lt 262144 ]] && sysctl -w vm.max_map_count=262144 || true
SHELL

      machine.vm.provision "ansible" do |ansible|
        ansible.playbook = "ansible/compute-node.yml"
        ansible.galaxy_role_file = "ansible/dependencies.yml"
        ansible.groups = machine_info.groups.map{
          |group| [group, [machine_info.name]]
        }.to_h
      end
    end
  end
end
