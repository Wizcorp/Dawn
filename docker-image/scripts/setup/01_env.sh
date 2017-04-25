# Link inventory to global hosts file
sudo ln -sfT ${PROJECT_ENVIRONMENT_FILES_PATH}/inventory /etc/ansible/hosts

# get hosts out of inventory
hosts="$(cat inventory | grep ansible_ssh_host | sed -r 's/^([a-z0-9\._-]+).*ansible_ssh_host="([^"]+)".*/\1 \2/gi')"
hostvars="$(ANSIBLE_STDOUT_CALLBACK=json ansible-playbook /dawn/ansible/dump_facts.yml)"

# fetch domain names
export LOCAL_DOMAIN="$(echo ${hostvars} | jq -r '[..|.local_domain_name?]|map(select(.))|unique[0]')"
export LOCAL_DOMAIN_DC="$(echo ${hostvars} | jq -r '[..|.local_domain_dc?]|map(select(.))|unique[0]')"

# set DOCKER_HOST
export EDGE_NODE="$(echo "${hosts}" | grep edge | head -n1 | cut -d " " -f2)"
export CONTROL_NODE="$(echo "${hosts}" | grep control | head -n1 | cut -d " " -f2)"

# Set the PS1
export PS1="${PROJECT_NAME} (${PROJECT_ENVIRONMENT}) \w $ "
