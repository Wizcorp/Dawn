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

# set DOCKER_HOST
export DOCKER_HOST="${CONTROL_NODE}:2376"

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
echo ""
