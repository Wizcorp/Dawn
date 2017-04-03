export TERM=xterm-256color

if
    [ ! -f ./inventory ]
then
    echo "You must first run Vagrant locally!"
    exit 1
fi

# Link inventory to global hosts file
ln -s ${PROJECT_ENVIRONMENT_FILES_PATH}/inventory /etc/ansible/hosts

# get hosts out of inventory
hosts="$(cat inventory | grep ansible_ssh_host | cut -d" " -f1-2 | sed "s/ansible_ssh_host=//g")"

# set DOCKER_HOST
export EDGE_NODE="$(echo ${hosts} | grep edge | head -n1 | cut -d " " -f2)"
export CONTROL_NODE="$(echo ${hosts} | grep control | head -n1 | cut -d " " -f2)"

# set VAULT environment variables, make sure to use tmp tokens in priority
if
    [ -f /home/dawn/.vault.ansible.conf ]
then
    export VAULT_CACERT="/home/dawn/certs/vault/client.ca.pem"
    export VAULT_CLIENT_CERT="/home/dawn/certs/vault/client.cert.pem"
    export VAULT_CLIENT_KEY="/home/dawn/certs/vault/client.key.pem"

    export VAULT_ADDR="https://${CONTROL_NODE}:8200"
    export VAULT_TOKEN="$( curl --cacert "${VAULT_CACERT}" -XPOST -sS "${VAULT_ADDR}/v1/auth/approle/login" -d "$( cat /home/dawn/.vault.ansible.conf )" | jq -r .auth.client_token )"
elif
    [ -f /home/dawn/.vault.root.conf ]
then
    export VAULT_CACERT="/home/dawn/certs/vault/client.ca.pem"
    export VAULT_CLIENT_CERT="/home/dawn/certs/vault/client.cert.pem"
    export VAULT_CLIENT_KEY="/home/dawn/certs/vault/client.key.pem"

    export VAULT_ADDR="https://${CONTROL_NODE}:8200"
    export VAULT_TOKEN="$( jq -r '.root_token' /home/dawn/.vault.root.conf )"
fi

# set DOCKER_HOST
export DOCKER_HOST="${CONTROL_NODE}:2375"

if
    [ ! -z "${VAULT_TOKEN}" ]
then
    export DOCKER_HOST="tcp://${CONTROL_NODE}:2376"
    export DOCKER_TLS_VERIFY=1
    export DOCKER_CERT_PATH="/home/dawn/certs/docker"

    # Get a new certificate set from vault for this connection
    mkdir /home/dawn/certs/docker >/dev/null 2>&1 || true
    VAULT_TMP_FILE="$( mktemp )"

    if
        vault write --format=json \
            docker/pki/issue/client \
            common_name=local.client.dawn > "${VAULT_TMP_FILE}"
    then
        jq -r .data.certificate "${VAULT_TMP_FILE}" > "${DOCKER_CERT_PATH}/cert.pem"
        jq -r .data.issuing_ca "${VAULT_TMP_FILE}"  > "${DOCKER_CERT_PATH}/ca.pem"
        jq -r .data.private_key "${VAULT_TMP_FILE}" > "${DOCKER_CERT_PATH}/key.pem"

        rm "${VAULT_TMP_FILE}"
    fi
fi


# display additional information
echo "* Monitoring:"
printf "%-15s %s\n" "  - Kibana:" "http://${CONTROL_NODE}:5601/"
printf "%-15s %s\n" "  - ElasticSearch:" "http://${CONTROL_NODE}:9200/"
printf "%-15s %s\n" "  - Grafana:" "http://${CONTROL_NODE}:3000/"

echo "* Service Discovery:"
printf "%-15s %s\n" "  - Consul:" "http://${CONTROL_NODE}:8500/ui/"
printf "%-15s %s\n" "  - Consul DNS:" "${CONTROL_NODE}:8600"
printf "%-15s %s\n" "  - DNSMasq DNS:" "${CONTROL_NODE}:53"

echo "* Load Balancing"
printf "%-15s %s\n" "  - Traefik:" "http://${EDGE_NODE}"

if
    [ ! -z "${VAULT_TOKEN}" ]
then
    echo "* Security"
    printf "%-15s %s\n" "  - Vault:" "${VAULT_ADDR}"
fi

echo ""
