#!/usr/bin/env python

import os

from pylib import base_template, motd_template, run_template
from pylib.ansible import AnsibleEnvironment
from pylib.docker import setup_docker
from pylib.vault import setup_vault

if __name__ == "__main__":
    env = AnsibleEnvironment()

    # setup vault and docker
    vault_template = setup_vault(env)
    docker_template = setup_docker(env)

    # setup our templates
    templates = [
        base_template,
        vault_template,
        docker_template
    ]

    # show MOTD is running a shell
    if os.environ.get('COMMAND').startswith('bash'):
        templates.append(motd_template)

    # run run.sh if it exists
    run_file = os.path.join(
        os.environ.get('PROJECT_ENVIRONMENT_FILES_PATH'), 'run.sh')
    if os.path.exists(run_file):
        templates.append(run_template)

    # print all the templates
    print(env.template(*templates))
