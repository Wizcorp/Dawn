import os
import urllib2

from vault import VaultClient

keymap = [
    ('private_key', 'key.pem'),
    ('issuing_ca',  'ca.pem'),
    ('certificate', 'cert.pem'),
]


def setup_docker(env):
    vault_addr = env.get_var('vault.addr')
    vault_cacert = env.get_var('vault.cacert')
    vault_token = env.get_var('vault.token')
    vault_client = VaultClient(vault_addr, vault_cacert, vault_token)

    if vault_token is None:
        return '''# Docker setup (canceled due to vault not being ready)'''

    cert_path = os.path.join(os.environ.get('HOME'), 'certs/docker')
    if not os.path.exists(cert_path):
        os.makedirs(cert_path, mode=0770)

    # fetch the certificates
    certificates = vault_client.query('docker/pki/issue/client', {
        'common_name': env.template('local.client.{{ local_domain_name }}')
    })

    # then write them
    for key, filename in keymap:
        if key not in certificates['data']:
            continue

        with open(os.path.join(cert_path, filename), 'w') as fd:
            fd.write(certificates['data'][key])

    return '''# Setup docker
export DOCKER_HOST=tcp://{{ edge_ip }}:2376
export DOCKER_TLS_VERIFY=1
export DOCKER_CERT_PATH="${HOME}/certs/docker"

# This is a useful helper for users to select a specific docker node to query
function docker-select() {
    if
        [ -z "${1}" ]
    then
        echo "usage: docker-select <host>"
    else
        echo "Selecting docker server ${1}"
        export DOCKER_HOST="tcp://${1}.node.{{ local_domain_name }}:2376"
    fi
}
export -f docker-select
'''
