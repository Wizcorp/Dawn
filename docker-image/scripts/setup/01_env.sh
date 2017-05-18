# Link inventory to global hosts file
sudo ln -sfT ${PROJECT_ENVIRONMENT_FILES_PATH}/inventory /etc/ansible/hosts

# get hosts out of inventory
hosts="$(cat inventory | grep ansible_ssh_host | sed -r 's/^([a-z0-9\._-]+).*ansible_ssh_host="([^"]+)".*/\1 \2/gi')"

# fetch domain names
export LOCAL_DOMAIN="$( grep '^local_domain_name' ansible/group_vars/all | cut -f 2 -d ' ' )"
export LOCAL_DOMAIN_DC="$( grep '^local_domain_dc' ansible/group_vars/all | cut -f 2 -d ' ' )"

# set DOCKER_HOST
export EDGE_NODE="$(echo "${hosts}" | grep edge | head -n1 | cut -d " " -f2)"
export CONTROL_NODE="$(echo "${hosts}" | grep control | head -n1 | cut -d " " -f2)"

# Set the PS1
export PS1="${PROJECT_NAME} (${PROJECT_ENVIRONMENT}) \w $ "
