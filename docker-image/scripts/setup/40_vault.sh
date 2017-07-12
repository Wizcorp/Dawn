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
    export VAULT_ADDR="https://vault.${LOCAL_DOMAIN}"
else
    # if we go through the IP we need to trust the certificate
    export VAULT_CACERT="${HOME}/certs/vault/client.ca.pem"
fi

# When running inside a custom container we can end up in a situation where the
# cacert is not available, in that case pull it from the vault instance and
# check the fingerprint if provided by the user
if
    [ ! -z "${VAULT_CACERT}" ] && [ ! -f "${VAULT_CACERT}" ]
then
    # Change the CA cert to point to a tmp file
    export VAULT_CACERT="$( mktemp )"

    # Retrieve the remote cert
    curl -sk "${VAULT_ADDR}/v1/vault/pki/ca/pem" -o "${VAULT_CACERT}"
fi

# If provided extract the fingerprint and compare it
if
    [ ! -z "${VAULT_TRUSTED_FINGERPRINT}" ] \
        && [ "$( openssl x509 -in "${VAULT_CACERT}" -noout -sha256 -fingerprint )" != "${VAULT_TRUSTED_FINGERPRINT}" ]
then
    echo "Invalid fingerprint retrieved from server, expected '${VAULT_TRUSTED_FINGERPRINT}' but got '$( openssl x509 -in "${VAULT_CACERT}" -noout -sha256 -fingerprint )'"
    exit 1
fi

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
#
# This step is skipped if the user provides a vault token manually
[ ! -z "${VAULT_TOKEN}" ] && return 0

if
    [ ! -z "${VAULT_ROLE_ID}" ] && [ ! -z "${VAULT_SECRET_ID}" ]
then
    VAULT_PAYLOAD='{"role_id":"'${VAULT_ROLE_ID}'","secret_id":"'${VAULT_SECRET_ID}'"}'
    export VAULT_TOKEN="$( curl --connect-timeout 3 -k -XPOST -sS "${VAULT_ADDR}/v1/auth/approle/login" -d "${VAULT_PAYLOAD}" | jq -r .auth.client_token )"
elif
    [ -f "${HOME}/.vault.conf" ]
then
    VAULT_AUTH_BACKEND="$( jq -r .backend "${HOME}/.vault.conf" )"
    VAULT_AUTH_DATA="$( jq -cM .data "${HOME}/.vault.conf" )"

    export VAULT_TOKEN="$( curl --connect-timeout 3 -k -XPOST -sS "${VAULT_ADDR}/v1/auth/${VAULT_AUTH_BACKEND}/login" -d "${VAULT_AUTH_DATA}" | jq -r .auth.client_token )"
elif
    [ -f "${HOME}/.vault.ansible.conf" ]
then
    export VAULT_TOKEN="$( curl --connect-timeout 3 -k -XPOST -sS "${VAULT_ADDR}/v1/auth/approle/login" -d "$( cat ${HOME}/.vault.ansible.conf )" | jq -r .auth.client_token )"
elif
    [ -f "${HOME}/.vault.root.conf" ]
then
    export VAULT_TOKEN="$( jq -r '.root_token' /home/dawn/.vault.root.conf )"
elif
    [ -f "${HOME}/.vault-token" ]
then
    # do nothing, we are auth already
    true
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
