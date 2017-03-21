rm -f /home/dawn/.aws_credentials

echo ""
echo -n "Creating deploy key... "
mkdir -p /home/dawn/.ssh/
rm -f /home/dawn/.ssh/deploy*
ssh-keygen -f /home/dawn/.ssh/deploy -N "" &> /dev/null
chown -fR dawn.dawn /home/dawn/.ssh/
echo "[ DONE ]"

echo -n "Appending the deploy public key to terraform.tfvars... "
pubkey="$(cat /home/dawn/.ssh/deploy.pub)"
echo "deploy_pubkey = \"${pubkey}\"" >> terraform.tfvars
echo "[ DONE ]"

echo ""
echo "** Note ** Your deploy private key will be stored locally, outside"
echo "** Note ** of your project folder; if you need to share it, make"
echo "** Note ** sure to share it securely!"
echo "** Note ** "
echo "** Note ** /home/dawn/.ssh/deploy"
echo "** Note ** "
echo ""
