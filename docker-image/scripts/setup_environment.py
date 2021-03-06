#!/usr/bin/env python

import os
import sys
import traceback
import urllib2

from pylib import base_template, motd_template, run_template
from pylib.ansible import AnsibleEnvironment
from pylib.docker import setup_docker
from pylib.vault import setup_vault

def append_run_script(templates):
    # run run.sh if it exists
    run_file = os.path.join(
        os.environ.get('PROJECT_ENVIRONMENT_FILES_PATH'), 'run.sh')
    if os.path.exists(run_file):
        templates.append(run_template)

if __name__ == "__main__":
    env = AnsibleEnvironment()

    # setup vault and docker
    try:
        vault_template = setup_vault(env)
        docker_template = setup_docker(env)
    except urllib2.HTTPError as e:
        print('echo "Vault seems to be having troubles, try to restart it and logout/login again":')
        print('echo "  %s"' % e.read())
        sys.exit(0)
    except Exception as e:
        print('echo "Vault cannot be reached, try to restart it and logout/login again":')
        print('echo "  %s"' % e)
        traceback.print_exc()
        sys.exit(0)

    # setup our templates
    templates = [
        base_template,
        vault_template,
        docker_template
    ]

    # show MOTD is running a shell
    if os.environ.get('COMMAND').startswith('bash'):
        templates.append(motd_template)

    append_run_script(templates)

    # print all the templates
    try:
        print(env.template(*templates))
    except Exception as e:
        # template rendering issue means that the inventory is empty or was not
        # generated properly
        print('''
cat <<- EOM

No inventory file was found in the project folder, either run the provisioning
tool associated with your environment (vagrant, terraform, etc...) or write your
own inventory (see the documentation for more details).

Once the inventory file exists either logout/login or source ~/.bash/profile to
load the environment variables associated with your project.

EOM
''')
        templates = []
        append_run_script(templates)
        print(env.template(*templates))
        sys.exit(0)
