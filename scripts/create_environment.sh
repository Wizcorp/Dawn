#!/usr/bin/env bash
#
# create.sh Walks the user through the creation of a new environment.
# In short, it basically rsyncs a template present in the container
# to the project's volume
#

# Ask if the user wants to create an environment, and exit
# if the answer is no. Keep asking if the answer is not y or n.
create_environment=""
while \
  [ "${create_environment}" != "y" ] && [ "${create_environment}" != "n" ]
do
  echo -n "The ${DAWN_ENVIRONMENT} environment does not exist. Would you like to create it? [y/n]: "
  read create_environment
done
[ "${create_environment}" == "n" ] && exit 0

# Display a list of available templates, and
# ask the user to select one.
echo ""
echo "You have the option to set up your new environment from a template:"
echo ""

pushd /dawn/templates/ > /dev/null
declare -A templates
for template in \
   $(find ./ -type d -maxdepth 1 \
     | sed "s#./##" \
     | tail -n +2)
do
  templates[${template}]="${template}"
  description="$(cat ./${template}/description 2> /dev/null || echo "No description")"
  printf "    %-20s %s\n" "${template}" "${description}"
done
echo ""
popd > /dev/null

template="sadfdsaf"
while \
  [ "${template}" != "" ] && [ "${templates[${template}]}" == "" ]
do
  echo -n "Select one, or press Enter to skip: "
  read template
done

# Create the environment folder, and
# copy the template files to it if
# a template was selected.
mkdir -p ${DAWN_ENVIRONMENT_FILES_PATH}

if 
  [ "${template}" != "" ]
then
  pushd /dawn/templates > /dev/null
  rsync -av "./${template}/" \
    "${DAWN_ENVIRONMENT_FILES_PATH}/" &> /dev/null
  popd > /dev/null
fi

# Run the create.sh script copied over from
# the template, if present. We remove the script
# afterward since we should not need it in the project.
TEMPLATE_CREATE_SCRIPT="${DAWN_ENVIRONMENT_FILES_PATH}/create.sh"
if
  [ -f "${TEMPLATE_CREATE_SCRIPT}" ]
then
  pushd "${DAWN_ENVIRONMENT_FILES_PATH}" > /dev/null
  ./create.sh
  rm create.sh
  popd > /dev/null
fi
