import ansible
import docker
import os
import vault

all = ['ansible', 'docker', 'vault',
       'base_template', 'motd_template', 'run_template']

# Base template, sets up several useful global variables
base_template = '''# Basic setup
export LOCAL_DOMAIN={{ local_domain_name | quote }}
export LOCAL_DOMAIN_DC={{ local_domain_dc | quote }}

export EDGE_NODE={{ groups['edge'][0] | quote }}
export CONTROL_NODE={{ groups['control'][0] | quote }}

export PS1="{{ env.PROJECT_NAME }} ({{ env.PROJECT_ENVIRONMENT }}) \w $ "
'''

# MOTD is only shown if the user is running a shell, and shows details about
# the current environment
motd_template = '''# Show MOTD
figlet "${BINARY_NAME}"
printf "%-20s %s\\n" "Project:" "${PROJECT_NAME}"
printf "%-20s %s\\n" "Environment:" "${PROJECT_ENVIRONMENT}"
echo ""

# display additional information
echo "* Monitoring:"
printf "%-20s %s\\n" "  - Kibana:" "http://{{ monitor_ip }}:5601/"
printf "%-20s %s\\n" "  - ElasticSearch:" "http://{{ monitor_ip }}:9200/"
printf "%-20s %s\\n" "  - Grafana:" "https://grafana.{{ local_domain_name }}/"

echo "* Service Discovery:"
printf "%-20s %s\\n" "  - Consul:" "https://{{ control_ip }}:8500/ui/"
printf "%-20s %s\\n" "  - Consul DNS:" "{{ control_ip }}:8600"
printf "%-20s %s\\n" "  - DNSMasq DNS:" "{{ control_ip }}:53"

echo "* Load Balancing"
printf "%-20s %s\\n" "  - Traefik:" "https://{{ edge_ip }}:8080"

{% if vault is defined and vault.token is defined and vault.token != None %}
echo "* Security"
printf "%-20s %s\\n" "  - Vault:" "{{ vault.addr }}"
{% endif %}

echo ""
'''

# If a run.sh file exists in the current project environment, run it
run_template = '''# Run custom profile setup
pushd "${PROJECT_ENVIRONMENT_FILES_PATH}" &> /dev/null
source "run.sh"
popd &> /dev/null
'''
