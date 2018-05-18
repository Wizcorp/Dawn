#
# This file will be installed at ~/.bash_profile everytime dawn is run and will
# override the existing one. It then is executed as part of the login process
# by bash and will load all the files in ${ROOT_FOLDER}/scripts/setup in order
# if an inventory is found, as part of this process it will source the project's
# run.sh file and finally the user's ~/.bashrc file
#

SCRIPTS_PATH="${ROOT_FOLDER}/scripts/setup"

# Link the project inventory and group vars to the ansible folder
sudo ln -sfT ${PROJECT_ENVIRONMENT_FILES_PATH}/inventory /etc/ansible/hosts
sudo ln -sf ${PROJECT_ENVIRONMENT_FILES_PATH}/ansible/group_vars /etc/ansible/group_vars

# Setup the user environment
eval "$( "${ROOT_FOLDER}/scripts/setup_environment.py" )"


# Allow the user to override what they want by running .bashrc
[[ -f ~/.bashrc ]] && . ~/.bashrc
