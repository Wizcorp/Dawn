#!/usr/bin/python2
'''
Allows one to manipulate a Swarm cluster through ansible directives
'''

# The MIT License (MIT)
#
# Copyright (c) 2017 Wizcorp
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

ANSIBLE_METADATA = {'status': ['stableinterface'],
                    'supported_by': 'committer',
                    'version': '1.0'}

DOCUMENTATION = '''
---
module: swarm
short_description: control the swarm configuration of a docker node
'''

EXAMPLES = '''
- name: init a new swarm (both addrs are optional), force will force init a new swarm every provisioning
  swarm: action=init listen_addr=10.0.0.5 advertise_addr=10.0.0.5 force=false
- name: join a swarm
  swarm: action=join type=worker remote_addrs="node1:2377,node2:2377" listen_addr=10.0.0.6 advertise_addr=10.0.0.6
- name: leave a swarm
  swarm: action=leave
'''

from ansible.module_utils.six import iteritems

from ansible.module_utils.basic import *
from ansible.module_utils.urls import *

from ansible.module_utils.docker_common import AnsibleDockerClient

import sys

def get_swarm_addrs(node_addr):
    info = get_info(url=node_addr)

    if 'Swarm' not in info or 'RemoteManagers' not in info['Swarm']:
        return None

    return [manager['Addr'] for manager in info['Swarm']['RemoteManagers']]

# ACTUAL DOCKER METHODS

def init(client):
    """Init a swarm cluster"""

    init_params = { key: client.module.params[key] for key in ['listen_addr', 'advertise_addr', 'force_new_cluster'] }

    try:
        res = client.init_swarm(**init_params)

        return True, res
    except Exception as e:
        if e.response.status_code == 406 or e.response.status_code == 503:
            return False, str(e)

        raise

def token(client):
    res = client.inspect_swarm()

    return False, res['JoinTokens']

def join(client):
    """Join a swarm cluster"""
    join_params = { key: client.module.params[key] for key in ['listen_addr', 'advertise_addr', 'remote_addrs', 'join_token'] }

    try:
        res = client.join_swarm(**join_params)

        return True, res
    except Exception as e:
        if e.response.status_code == 406 or e.response.status_code == 503:
            return False, str(e)

        raise

def main():
    #argument_spec = url_argument_spec()
    argument_spec = dict(
        url = dict(required=False),
        action = dict(required=True, choices=['init', 'join', 'token']),
        listen_addr = dict(required=False),
        advertise_addr = dict(required=False),
        force_new_cluster = dict(required=False, type='bool'),
        remote_addrs = dict(required=False, type='list'),
        join_token = dict(required=False),
        type = dict(required=False)
    )

    client = AnsibleDockerClient(
        argument_spec=argument_spec,
        supports_check_mode=True
    )

    action = client.module.params['action']

    try:
        res = None
        if action == 'init':
            changed, res = init(client)
        elif action == 'join':
            changed, res = join(client)
        elif action == 'token':
            changed, res = token(client)

        client.module.exit_json(changed=changed, result=res)
    except Exception as e:
        client.module.exit_json(failed=True, msg=str(e))

if __name__ == '__main__':
    main()
