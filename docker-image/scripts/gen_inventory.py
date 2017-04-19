#!/usr/bin/env python2

# From a terraform.tfstate file, generates an inventory, is called automatically
# at the end of the terraform apply command via a local-exec provisionier, if
# not desired feel free to modify/delete provision.tf

from __future__ import print_function

import json
import os
import sys

TERRAFORM_STATE_FILE = "terraform.tfstate"
INVENTORY_POST_FILE = "inventory.post"

if not os.path.isfile(TERRAFORM_STATE_FILE):
	print("No state file found, please run terraform apply")
	sys.exit(1)

hosts = {}
groups = {}

# adds a host to a group
def add_to_group(group_name, instance_name):
	if group_name not in groups:
		groups[group_name] = []
	groups[group_name].append(instance_name)

# open our tfstat file
with open(TERRAFORM_STATE_FILE) as raw_state:
	state = json.load(raw_state)

	for module in state['modules']:
		instances = [
			resource
			for key, resource in module['resources'].items()
			if key.startswith('aws_instance')
		]

		for instance in instances:
			attributes = instance['primary']['attributes']

			tags = dict([
				(key[5:], value)
				for key, value in attributes.items()
				if key.startswith('tags.')
			])

			name = tags['Name']

			# convert some of our current tags to actual ansible variables
			instance_data = {
				'name': name,
				'vars': {
					'ansible_ssh_host': attributes['public_ip'] or attributes['private_ip'],
					'ansible_ssh_user': tags['sshUser'],
					'ansible_ssh_port': 22,
					'ansible_ssh_private_key_file': '~/.ssh/deploy',
					'docker_labels': '["dawn.node.type=%s"]' % (tags['dockerType'])
				}
			}

			# might not always be defined
			if 'sshExtraArgs' in tags:
				instance_data['vars']['ansible_ssh_common_args'] = tags['sshExtraArgs']

			# for edges, we want to make sure docker listens on every possible
			# interfaces so that external connections can be routed properly
			if 'dockerType' is 'edge':
				instance_data['vars']['docker_ip'] = '0.0.0.0'

			# instances are always part of those groups by default
			add_to_group('all', name)
			add_to_group('docker', name)
			add_to_group('swarm', name)
			add_to_group('consul', name)

			if 'roles' in tags:
				for group_name in tags['roles'].split(','):
					add_to_group(group_name, name)

			if 'role' in tags:
				add_to_group(tags['role'], name)

			hosts[name] = instance_data

	for name, host in hosts.items():
		print('%s %s' % (
			name,
			' '.join(['%s=%s' % (key, json.dumps(val)) for key, val in host['vars'].items()])
		))

	for group_name, instances in groups.items():
		print('\n[%s]' % (group_name))

		for instance in instances:
			print(instance)

if os.path.isfile(INVENTORY_POST_FILE):
	print('')
	with open(INVENTORY_POST_FILE) as fd_vars:
		for line in fd_vars:
			print(line, end='')
	print('')
