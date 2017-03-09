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

# Self destruct
rm create.sh

# Exit
exit 0
