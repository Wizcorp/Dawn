SHELL_USER_HOMEDIR="/home/${SHELL_USER}"

rm -f ${SHELL_USER_HOMEDIR}/.aws_credentials

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

echo ""
echo "** Note ** Your deploy private key will be stored locally, outside"
echo "** Note ** of your project folder; if you need to share it, make"
echo "** Note ** sure to share it securely!"
echo "** Note ** "
echo "** Note ** ${SHELL_USER_HOMEDIR}/.ssh/deploy"
echo "** Note ** "
echo ""
