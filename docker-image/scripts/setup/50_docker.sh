#
# This file sets the docker environment variables as well as helper functions,
# if vault is available, it will also generate a client certificate on the fly
# from vault to allow the user to connect via TLS
#

export DOCKER_HOST="${EDGE_NODE}:2375"

if
    [ ! -z "${VAULT_TOKEN}" ]
then
    export DOCKER_HOST="tcp://${EDGE_NODE}:2376"
    export DOCKER_TLS_VERIFY=1
    export DOCKER_CERT_PATH="${HOME}/certs/docker"

    # Get a new certificate set from vault for this connection
    mkdir "${DOCKER_CERT_PATH}" >/dev/null 2>&1 || true
    VAULT_TMP_FILE="$( mktemp )"

    if
        vault write --format=json \
            docker/pki/issue/client \
            common_name=local.client.${LOCAL_DOMAIN} > "${VAULT_TMP_FILE}"
    then
        jq -r .data.certificate "${VAULT_TMP_FILE}" > "${DOCKER_CERT_PATH}/cert.pem"
        jq -r .data.issuing_ca "${VAULT_TMP_FILE}"  > "${DOCKER_CERT_PATH}/ca.pem"
        jq -r .data.private_key "${VAULT_TMP_FILE}" > "${DOCKER_CERT_PATH}/key.pem"

        rm "${VAULT_TMP_FILE}"
    fi
fi

# This is a useful helper for users to select a specific docker node to query
function docker-select() {
    if
        [ -z "${1}" ]
    then
        echo "usage: docker-select <host>"
    else
        echo "Selecting docker server ${1}"
        export DOCKER_HOST="tcp://${1}.node.${LOCAL_DOMAIN_DC}.${LOCAL_DOMAIN}:2376"
    fi
}
export -f docker-select
