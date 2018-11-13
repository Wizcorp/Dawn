import customssl
import json
import os
import socket
import ssl
import time
import urllib2
import warnings


class VaultClient(object):
    """	Very basic wrapper for the vault client, uses a custom ssl context
    that supports verifying IP SANs on python 2.7
    """

    def __init__(self, vault_addr, vault_token=None):
        self._ctx = customssl.create_default_context()
        self._ctx.check_hostname = False
        self._ctx.verify_mode = ssl.CERT_NONE

        self._vault_addr = vault_addr
        self._vault_token = vault_token

    def query(self, path, data=None, headers={}):
        query_url = "%s/v1/%s" % (self._vault_addr, path)

        if data is not None:
            data = json.dumps(data)

        if self._vault_token is not None and 'X-Vault-Token' not in headers:
            headers['X-Vault-Token'] = self._vault_token

        request = urllib2.Request(query_url, data=data, headers=headers)
        response = urllib2.urlopen(request, context=self._ctx)

        return json.load(response)

    def try_login(self, method, login_data):
        res = self.query('auth/%s/login' % method, login_data)
        if 'auth' not in res or 'client_token' not in res['auth']:
            return None
        return res['auth']['client_token']


def setup_vault(env):
    """Finds how to communicate with vault and setups a valid vault token for
    use in the current session
    """

    home_folder = os.environ.get("HOME")
    config_generic = os.path.join(home_folder, ".vault.conf")
    config_ansible = os.path.join(home_folder, ".vault.ansible.conf")
    config_root = os.path.join(home_folder, ".vault.root.conf")

    vault_addr = env.template("https://{{ control_ip }}:8200")

    try:
        local_domain_name = env.get_var("local_domain_name")
        # If we can resolve the local domain properly, use that instead
        # (usually local dev envs won't be able to resolve unless the user
        # changes his DNS)
        socket.gethostbyname("vault.%s" % local_domain_name)
        vault_addr = "https://vault.%s" % local_domain_name
    except socket.gaierror:
        pass

    # create a client with no cert verification for unsealing
    vault_client = VaultClient(vault_addr)

    try:
        seal_status = vault_client.query("sys/seal-status")
    except urllib2.URLError:
        return '''# Vault not available
cat <<- EOM

A connection to Vault couldn't be achieved. This either means that the servers
are down or that provisioning has not being done yet.

Running the provisioning tools will resolve this issue in the vast majority of
cases. If you do not have the proper access to do so, contact your cluster's
administrator:

ansible-playbook ansible/playbook.yml

EOM
'''

    # if vault is sealed, try to unseal it
    if seal_status['sealed'] is True and os.path.exists(config_root):
        with open(config_root) as fd:
            unseal_data = json.load(fd)
            for unseal_key in unseal_data['keys']:
                res = vault_client.query('sys/unseal', {'key': unseal_key})
                if res['t'] <= 0:
                    break

    # recreate the vault with the proper ca_cert
    vault_client = VaultClient(vault_addr)

    # try one of the many supported login methods
    vault_token = None

    # from the environment
    if 'VAULT_TOKEN' in os.environ:
        vault_token = os.environ.get('VAULT_TOKEN')

    # from the default vault login mechanism
    vault_token_file = os.path.join(home_folder, '.vault-token')
    if vault_token is None and os.path.exists(vault_token_file):
        stats = os.stat(vault_token_file)
        last_time = time.time() - stats.st_mtime

        if last_time > 60 * 60 * 24:
            os.remove(vault_token_file)
        else:
            with open(vault_token_file) as fd:
                vault_token = fd.read()

    # from the environment as a role
    if (vault_token is None and 'VAULT_ROLE_ID' in os.environ and
            'VAULT_SECRET_ID' in os.environ):
        vault_token = vault_client.try_login('approle', {
            'role_id': os.environ.get('VAULT_ROLE_ID'),
            'secret_id': os.environ.get('VAULT_SECRET_ID')
        })

    # use generic login files in priority
    if vault_token is None and os.path.exists(config_generic):
        with open(config_generic) as fd:
            login_data = json.load(fd)
            vault_token = vault_client.try_login(
                login_data['backend'], login_data['data'])

    # try to login using ansible credentials
    if vault_token is None and os.path.exists(config_ansible):
        with open(config_ansible) as fd:
            login_data = json.load(fd)
            vault_token = vault_client.try_login('approle', login_data)

    # if using the root config, create a temporary token
    if vault_token is None and os.path.exists(config_root):
        with open(config_root) as fd:
            login_data = json.load(fd)
            res = vault_client.query('auth/token/create', data={
                'policies': ['ansible'],
                'ttl': '72h'
            }, headers={
                'X-Vault-Token': login_data['root_token']
            })

            if 'auth' in res and 'client_token' in res['auth']:
                vault_token = res['auth']['client_token']

    env.set_var('vault', {
        'addr': vault_addr,
        'token': vault_token
    })

    return '''# Vault setup
export VAULT_ADDR="{{ vault.addr }}"
{% if vault.token %}
export VAULT_TOKEN="{{ vault.token }}"
{% else %}
echo -e "\\n** Authenticating to vault **\\n"

while [ -z "${success}" ]
do
    echo -en "\\nEnter your LDAP username (leave empty to skip): "
    read -r username

    if
        [ -z "${username}" ]
    then
    echo "** Skipping"
        return 0
    fi

    if
        vault auth -method=ldap "username=${username}"
    then
        success=true
    elif
        [ "${?}" == "130" ]
    then
        echo -e "\\n** Aborting!"
        exit 0
    fi
done

source ~/.bash_profile
return
{% endif %}
'''
