# Notify user
echo ""
echo "This container will now exit; please run the following locally:"
echo ""
echo "  cd ./dawn/${DAWN_ENVIRONMENT}"
echo "  # If you are on Windows, you will need to set up NAT networking"
echo "  .\\networking.ps1"
echo "  vagrant up"
echo "  cd  ../.."
echo ""
echo "Then run 'dawn ${DAWN_ENVIRONMENT}' once again to start provisioning"
echo ""

# Self destruct
rm create.sh

# Exit
exit 0
