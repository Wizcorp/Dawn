import customssl
import json
import os
import socket
import ssl
import urllib2
import warnings


class VaultClient(object):
    """	Very basic wrapper for the vault client, uses a custom ssl context
    that supports verifying IP SANs on python 2.7
    """

    def __init__(self, vault_addr, vault_cacert=None, vault_token=None):
        self._ctx = customssl.create_default_context()

        if vault_cacert is not None:
            self._ctx.load_verify_locations(vault_cacert)
            self._ctx.verify_flags = ssl.VERIFY_DEFAULT
        else:
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
    vault_cacert = "whatever"
    vault_cacert_source = "vault"

    try:
        local_domain_name = env.get_var("local_domain_name")
        # If we can resolve the local domain properly, use that instead
        # (usually local dev envs won't be able to resolve unless the user
        # changes his DNS)
        socket.gethostbyname("vault.%s" % local_domain_name)
        vault_addr = "https://vault.%s" % local_domain_name

        if env.get_var("https_custom_ca") is not None:
            vault_cacert = env.get_var("https_custom_ca")
            vault_cacert_source = "custom"
        else:
            # this cert if fetched from the vault server itself
            vault_cacert = "https"
            vault_cacert_source = "https"
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

    # retrieve the vault CA certificate if necessary
    if not os.path.exists(vault_cacert) and vault_cacert_source != "custom":
        warnings.simplefilter("ignore", RuntimeWarning)
        vault_cacert = os.tempnam()
        with open(vault_cacert, "w") as fd:
            # first fetch the root CA
            root_ca_url = "%s/v1/pki/ca/pem" % (vault_addr)

            # do not check the certificate's validity
            ctx = ssl.create_default_context()
            ctx.check_hostname = False
            ctx.verify_mode = ssl.CERT_NONE

            fd.write(urllib2.urlopen(root_ca_url, context=ctx).read())
            fd.write("\n")

            # then add the intermediate CA
            ca_url = "%s/v1/%s/pki/ca/pem" % (vault_addr, vault_cacert_source)

            fd.write(urllib2.urlopen(ca_url, context=ctx).read())

    # recreate the vault with the proper ca_cert
    vault_client = VaultClient(vault_addr, vault_cacert)

    # try one of the many supported login methods
    vault_token = None

    # from the environment
    if 'VAULT_TOKEN' in os.environ:
        vault_token = os.environ.get('VAULT_TOKEN')

    # from the default vault login mechanism
    vault_token_file = os.path.join(home_folder, '.vault-token')
    if vault_token is None and os.path.exists(vault_token_file):
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
        'cacert': vault_cacert,
        'token': vault_token
    })

    return '''# Vault setup
export VAULT_ADDR={{ vault.addr }}
export VAULT_CACERT={{ vault.cacert }}
{% if vault.token is defined and vault.token != None %}
export VAULT_TOKEN={{ vault.token }}
{% else %}
cat <<- EOM

None of the vault configuration files were found at either ~/.vault.conf or
~/.vault.root.conf, this means that we cannot generate a valid certificate for
connecting to docker. Please contact an administrator of the project to procure
a valid vault AppRole and save it in "${HOME}/.vault.conf".

If you intend to rotate certificates or do any action in ansible that requires
vault access, you will need a valid ~/.vault.ansible.conf file, as above please
contact your administrator if you are missing this file.

EOM
{% endif %}
'''
