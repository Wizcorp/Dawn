export TF_VAR_project_name="${PROJECT_NAME}"
export TF_VAR_project_environment="${PROJECT_ENVIRONMENT}"
export AWS_CREDENTIALS_FILE="/home/${SHELL_USER}/.aws_credentials"

if
    [ ! -f "${AWS_CREDENTIALS_FILE}" ]
then
   create_credentials_file=""
    while \
        [ "${create_credentials_file}" != "y" ] && [ "${create_credentials_file}" != "n" ]
    do
        echo -n "Would you like to save your AWS credentials? [y/n]: "
        read create_credentials_file
    done

    if
        [ "${create_credentials_file}" == "n" ]
    then
        touch ${AWS_CREDENTIALS_FILE}
    else
        access_key_id=""
        while \
            [ "${access_key_id}" == "" ]
        do
            echo -n "Please enter your AWS access key ID: "
            read access_key_id
        done

        secret_key=""
        while \
            [ "${secret_key}" == "" ]
        do
            echo -n "Please enter your AWS secret access key: "
            read secret_key
        done

        echo "export AWS_ACCESS_KEY_ID=\"${access_key_id}\"" >> "${AWS_CREDENTIALS_FILE}"
        echo "export AWS_SECRET_ACCESS_KEY=\"${secret_key}\"" >> "${AWS_CREDENTIALS_FILE}"
        sync
    fi
fi
echo ""

# Warn user if deploy key is not found
if
    [ ! -f /home/${SHELL_USER_HOMEDIR}/.ssh/deploy ]
then
    echo "** Warning ** private deploy key not found (/home/${SHELL_USER_HOMEDIR}/.ssh/deploy)"
    echo "** Warning ** While you may still be able to start or stop new machines"
    echo "** Warning ** using Terraform, you will not be able to provision them"
    echo "** Warning ** using Ansible. Request the private key, and put it here:"
    echo "** Warning **"
    echo "** Warning ** /home/${SHELL_USER_HOMEDIR}/.ssh/deploy"
    echo "** Warning **"
    echo ""
fi

# Warn user if credentials file is empty
if
    [ ! -s "${AWS_CREDENTIALS_FILE}" ]
then
    echo "** Warning ** You have not stored your AWS credentials"
    echo "** Warning ** Please make sure to add the following variables"
    echo "** Warning ** To your environment:"
    echo ""
    echo "    AWS_ACCESS_KEY_ID"
    echo "    AWS_SECRET_ACCESS_KEY"
    echo ""
fi

source "${AWS_CREDENTIALS_FILE}"

echo "** Note ** See terraform.tfvars for configuration options."
echo ""
