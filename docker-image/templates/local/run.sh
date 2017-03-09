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
export DAWN_EDGE="$(echo ${hosts} | grep edge | head -n1 | cut -d " " -f2)"
export DAWN_CONTROL="$(echo ${hosts} | grep control | head -n1 | cut -d " " -f2)"

# set DOCKER_HOST
export DOCKER_HOST="${DAWN_CONTROL}:2376"

# display additional information
echo "* Monitoring:"
printf "%-15s %s\n" "  - Kibana:" "http://${DAWN_CONTROL}:5601/"
printf "%-15s %s\n" "  - ElasticSearch:" "http://${DAWN_CONTROL}:9200/"
printf "%-15s %s\n" "  - Grafana:" "http://${DAWN_CONTROL}:3000/"

echo "* Service Discovery:"
printf "%-15s %s\n" "  - Consul:" "http://${DAWN_CONTROL}:8500/ui/"
printf "%-15s %s\n" "  - Consul DNS:" "${DAWN_CONTROL}:8600"
printf "%-15s %s\n" "  - DNSMasq DNS:" "${DAWN_CONTROL}:53"

echo "* Load Balancing"
printf "%-15s %s\n" "  - Traefik:" "http://${DAWN_EDGE}"
echo ""
