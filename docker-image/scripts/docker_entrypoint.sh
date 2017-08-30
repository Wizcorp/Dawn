#!/usr/bin/env bash
#
# The entrypoint script is what docker will use
# to set the environment before it is used. In this case,
# we:
#
#   1. Ensure that all required environments are present
#   2. That the project contains a configuration folder and configuration file
#   3. Optionally invite the user to create an environment folder
#      if it does not exist
#   4. Set up additional environment variables and create some configuration
#      files dynamically
#   5. Run the requested command, or open a shell if no command were given
#

set -e

# The project name is mostly used for informational purposes,
# but users may want to use this value to determine how
# their tools (Ansible, Terraform, etc) should run.
if
  [ "${PROJECT_NAME}" == "" ]
then
  echo "The PROJECT_NAME environment variable is not set; quitting."
  exit 1
fi

# We need to know which environment files to use;
# If the PROJECT_ENVIRONMENT shell environment variable
# is not set, there is nothing else we can do.
if
  [ "${PROJECT_ENVIRONMENT}" == "" ]
then
  echo "The PROJECT_ENVIRONMENT environment variable is not set; quitting."
  exit 1
fi

# Go to the scripts folder
pushd ./scripts/ > /dev/null

# Store the command we have received, and create
# a variable holding the path to the environment files
# in the project
export COMMAND="${@}"
export PROJECT_ENVIRONMENT_FILES_PATH="${PROJECT_FILES_PATH}/${PROJECT_ENVIRONMENT}"

# We make sure that the base directory structure is present,
# and that a configuration file is indeed present.
if
  [ ! -f "${PROJECT_CONFIG_FILE_PATH}" ]
then
  echo "Your project does not appear to have been initialized;"
  echo "There should be a ./${CONFIG_FOLDER} folder at the top-level of your project,"
  echo "and a ./${CONFIG_FOLDER}/${CONFIG_FILENAME} file needs to be present."
  exit 1
fi

# If the environment folder does not exist,
# we invite the user to create it
if
  [ ! -d "${PROJECT_ENVIRONMENT_FILES_PATH}" ]
then
  source ./create_environment.sh
fi

popd > /dev/null

# We finally downgrade the user and run the
# command. The reason for this is twofold:
#
#    1. Avoid unintentional changes to files put on the container.
#    2. (Windows) file permissions for ALL mounted files
#       is 0755; this means that running as root in the container
#       and trying to ssh to a remote server using an ssh key on the
#       mounted file system will result in "bad permission" error.
#
# Note that create.sh and run.sh do run as root; only the user's
# shell is downgraded to the shell user.
#
# Ref: https://github.com/docker/docker/issues/27685#issuecomment-256648694
#
pushd ${PROJECT_ENVIRONMENT_FILES_PATH} > /dev/null

# We install the latest bash profile in the user home so that each user gets the
# same behaviour
cp "${ROOT_FOLDER}/scripts/user_bash_profile.sh" "/home/${SHELL_USER}/.bash_profile"

# Some scripts might pass complex arguments that need to be safely escaped before
# being passed to bash -c, example is gitlab passing 'sh -c "if true; then foo; fi"'
# that will fail when passed directly, thankfully printf on bash supports the %q format
# sequence that allows converting an argument to a safe string to be used as shell
# input
#
# Ref: https://stackoverflow.com/questions/34271519/passing-arguments-to-bash-c-with-spaces
#
printf -v SAFE_COMMAND '%q ' "${@}"
sudo -H -E -u ${SHELL_USER} bash --login -c "$SAFE_COMMAND"
popd > /dev/null
