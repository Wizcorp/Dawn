# Notify user
echo ""
echo "This container will now exit; please run the following locally:"
echo ""
echo "  cd ./${CONFIG_FOLDER}/${PROJECT_ENVIRONMENT}"
echo ""
echo "  # On Linux, macOS"
echo "  vagrant up"
echo ""
echo "  # On Windows"
echo "  .\vagrant-up.ps1"
echo ""
echo "Then run '${BINARY_NAME} ${PROJECT_ENVIRONMENT}' once again"
echo "to open a shell and start provisioning"
echo ""

# Generate a password for the ldap admin and write it
echo "" >> ansible/group_vars/all
echo "# LDAP administration password, generated on environment creation, make" >> ansible/group_vars/all
echo "# sure to save this somewhere safe" >> ansible/group_vars/all

echo -n "ldap_admin_password: " >> ansible/group_vars/all
python -c "import random, string; print(''.join(random.SystemRandom().choice(string.letters + string.digits + string.punctuation) for _ in range(24)));" >> ansible/group_vars/all

# Same thing but for grafana
echo "" >> ansible/group_vars/all
echo "# Grafana administration password, it is only used by the ansible playbook" >> ansible/group_vars/all
echo "# to manage dashboards and configuration. To access grafana please create" >> ansible/group_vars/all
echo "# a user in LDAP instead" >> ansible/group_vars/all

echo -n "grafana_password: " >> ansible/group_vars/all
python -c "import random, string; print(''.join(random.SystemRandom().choice(string.letters + string.digits + string.punctuation) for _ in range(24)));" >> ansible/group_vars/all

# Self destruct
rm create.sh

# Exit
exit 0
