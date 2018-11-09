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

export PS1="\\[\\e[36m\\]{{ env.PROJECT_NAME }} \\[\\e[35m\\]{{ env.PROJECT_ENVIRONMENT }} \\[\\e[32m\\]\w\\[\\e[0m\\] $ "

tsh() {
    if
        echo "${@}" | grep -q "\\-\\-proxy="
    then
         /usr/bin/tsh ${@}
    else
        /usr/bin/tsh --proxy=teleport.{{ local_domain_name }}:443 ${@}
    fi
}

export -f tsh
'''

# MOTD is only shown if the user is running a shell, and shows details about
# the current environment
motd_template = '''# Show MOTD
motd() {
    motd_title() {
        echo -en "\\e[36m${1}\\e[0m"
    }

    motd_prefix() {
        echo -en "\\e[35m${1}\\e[0m"
    }

    motd_prefix_bold() {
        echo -en "\\e[95m${1}\\e[0m"
    }

    motd_info() {
        echo -en "${1}"
    }

    motd_title_entry() {
        printf "%-20s %s\\n" "$(motd_prefix_bold "${1}")" "$(motd_info "${2}")"
    }

    motd_section() {
        echo "$(motd_title "${1}")"
    }

    motd_section_entry() {
        printf "%-20s %s\\n" "$(motd_prefix "${1}")" "$(motd_info "${2}")"
    }

    motd_section_end() {
        echo ""
    }

    esc="$(printf '\033')"
    echo "$(figlet "${BINARY_NAME}")" \
        | sed "s/^\(.*\)$/${esc}[36m\\1${esc}[0m/" \
        | sed "3s/$/ $(motd_title_entry "Project" "${PROJECT_NAME}")/" \
        | sed "4s/$/ $(motd_title_entry "Environment" "${PROJECT_ENVIRONMENT}")/" \
        | sed "5s/$/ $(motd_title_entry "Domain" "{{ local_domain_name }}")/"

    motd_section "Service Discovery"
    motd_section_entry "Consul" "https://{{ edge_ip }}:8500/ui/"
    motd_section_entry "Consul DNS" "{{ edge_ip }}:8600"
    motd_section_entry "DNSMasq DNS" "{{ edge_ip }}:53"
    motd_section_end

    # display additional information
    motd_section "Web UI"
    motd_section_entry "Kibana" "https://kibana.{{ local_domain_name }}/"
    motd_section_entry "Grafana" "https://grafana.{{ local_domain_name }}/"
    motd_section_entry "Prometheus" "https://prometheus.{{ local_domain_name }}"
    motd_section_entry "Traefik" "https://{{ local_domain_name }}:8080"
    motd_section_entry "LDAP Admin" "https://ldap-admin.{{ local_domain_name }}"
    motd_section_entry "Teleport" "https://teleport.{{ local_domain_name }}"
    motd_section_end

    {% if vault is defined and vault.token is defined and vault.token != None %}
    motd_section "Security"
    motd_section_entry "Vault" "{{ vault.addr }}"
    motd_section_end
    {% endif %}
}
export -f motd

motd
'''

# If a run.sh file exists in the current project environment, run it
run_template = '''# Run custom profile setup
pushd "${PROJECT_ENVIRONMENT_FILES_PATH}" &> /dev/null
source "run.sh"
popd &> /dev/null
'''
