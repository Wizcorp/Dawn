#
# This file sets the vault variables if a vault configuration exists at the
# right location, if they do not, show a friendly warning explaining to the user
# that they won't be able to access docker via TLS.
#

VAULT_CERT_PATH="${HOME}/certs/vault"

export VAULT_ADDR="https://${CONTROL_NODE}:8200"

# If we can resolve the local domain properly, use that instead (usually local
# dev envs won't be able to resolve unless the user changes his DNS)
if
    nslookup "vault.${LOCAL_DOMAIN}" 1>/dev/null 2>&1
then
    export VAULT_ADDR="http://vault.${LOCAL_DOMAIN}"
fi

export VAULT_CACERT="${VAULT_CERT_PATH}/client.ca.pem"
export VAULT_CLIENT_CERT="${VAULT_CERT_PATH}/client.cert.pem"
export VAULT_CLIENT_KEY="${VAULT_CERT_PATH}/client.key.pem"

# Automatically unseal vault if possible
if
    [ -f "${HOME}/.vault.root.conf" ] \
        && [ "$(vault status | grep Sealed | cut -d ' ' -f 2)" == "true" ]
then
    echo "Automatically unsealing vault"
    jq -r .keys[] ~/.vault.root.conf | head -n 3 | xargs -n 1 vault unseal >/dev/null
fi

# set VAULT environment variables, we first attempt to login using a generic
# configuration, this configuration is created by the admin for each user and
# should be installed manually on first setup. If this configuration does not
# exist we check for the ansible configuration, and finally the root conf.
if
    [ -f "${HOME}/.vault.conf" ]
then
    VAULT_AUTH_BACKEND="$( jq -r .backend "${HOME}/.vault.conf" )"
    VAULT_AUTH_DATA="$( jq -cM .data "${HOME}/.vault.conf" )"

    export VAULT_TOKEN="$( curl --connect-timeout 3 --cacert "${VAULT_CACERT}" -XPOST -sS "${VAULT_ADDR}/v1/auth/${VAULT_AUTH_BACKEND}/login" -d "${VAULT_AUTH_DATA}" | jq -r .auth.client_token )"
elif
    [ -f "${HOME}/.vault.ansible.conf" ]
then
    export VAULT_TOKEN="$( curl --connect-timeout 3 --cacert "${VAULT_CACERT}" -XPOST -sS "${VAULT_ADDR}/v1/auth/approle/login" -d "$( cat ${HOME}/.vault.ansible.conf )" | jq -r .auth.client_token )"
elif
    [ -f "${HOME}/.vault.root.conf" ]
then
    export VAULT_TOKEN="$( jq -r '.root_token' /home/dawn/.vault.root.conf )"
else
    cat <<- EOM

None of the vault configuration files were found at either ~/.vault.conf or
~/.vault.root.conf, this means that we cannot generate a valid certificate for
connecting to docker. Please contact an administrator of the project to procure
a valid vault AppRole and save it in "${HOME}/.vault.conf".

If you intend to rotate certificates or do any action in ansible that requires
vault access, you will need a valid ~/.vault.ansible.conf file, as above please
contact your administrator if you are missing this file.

EOM
fi
