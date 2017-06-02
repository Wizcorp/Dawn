echo -n "Generating passwords for LDAP and Grafana..."
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
echo "[ DONE ]"

# Notify user
echo ""
echo "You will need to write a custom inventory, a basic one has been created"
echo "in the current directory for you to edit, make sure to have SSH keys or"
echo "credentials available. You will also most likely want to edit the ansible"
echo "playbook at ansible/playbook.yml to add firewall rules and any custom"
echo "software to your servers."
echo ""
