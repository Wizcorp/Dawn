SHELL_USER_HOMEDIR="/home/${SHELL_USER}"

echo ""
echo -n "Creating deploy key... "
mkdir -p ${SHELL_USER_HOMEDIR}/.ssh/
rm -f ${SHELL_USER_HOMEDIR}/.ssh/deploy*
ssh-keygen -f ${SHELL_USER_HOMEDIR}/.ssh/deploy -N "" &> /dev/null
chown -fR ${SHELL_USER}.${SHELL_USER} ${SHELL_USER_HOMEDIR}/.ssh/
echo "[ DONE ]"

echo -n "Appending the deploy public key to terraform.tfvars... "
pubkey="$(cat ${SHELL_USER_HOMEDIR}/.ssh/deploy.pub)"
echo "deploy_pubkey = \"${pubkey}\"" >> terraform.tfvars
echo "[ DONE ]"

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

echo ""
echo "** Note ** Your deploy private key will be stored locally, outside"
echo "** Note ** of your project folder; if you need to share it, make"
echo "** Note ** sure to share it securely!"
echo "** Note ** "
echo "** Note ** ${SHELL_USER_HOMEDIR}/.ssh/deploy"
echo "** Note ** "
echo "** Note ** Make sure to setup your AWS credentials for Terraform, see:"
echo "** Note ** https://www.terraform.io/docs/providers/aws/index.html#authentication"
echo ""
