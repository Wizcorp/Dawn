#
# This file will be installed at ~/.bash_profile everytime dawn is run and will
# override the existing one. It then is executed as part of the login process
# by bash and will load all the files in ${ROOT_FOLDER}/scripts/setup in order
# if an inventory is found, as part of this process it will source the project's
# run.sh file and finally the user's ~/.bashrc file
#

SCRIPTS_PATH="${ROOT_FOLDER}/scripts/setup"

if
    [ -f ./inventory ]
then
    # Run the setup scripts
    for script in \
    $(find ${SCRIPTS_PATH} -maxdepth 1 \
        | sed "s#${SCRIPTS_PATH}##" \
        | tail -n +2 \
        | sort)
    do
    source ${SCRIPTS_PATH}/${script}
    done
else
    cat <<-EOM

No inventory file was found in the project folder, either run the provisioning
tool associated with your environment (vagrant, terraform, etc...) or write your
own inventory (see the documentation for more details).

Once the inventory file exists either logout/login or source ~/.bash/profile to
load the environment variables associated with your project.

EOM
fi

# Allow the user to override what they want by running .bashrc
[[ -f ~/.bashrc ]] && . ~/.bashrc
