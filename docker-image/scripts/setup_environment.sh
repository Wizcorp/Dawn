#!/usr/bin/env bash
#
# Setup environment is a script which, when sourced,
# will set up environment variables and/or otherwise
# dynamically create or modify configuration files used
# by our configuration and management tools.
#
SCRIPTS_PATH="${ROOT_FOLDER}/scripts/setup"

for script in \
   $(find ${SCRIPTS_PATH} -maxdepth 1 \
     | sed "s#${SCRIPTS_PATH}##" \
     | tail -n +2 \
     | sort)
do
  source ${SCRIPTS_PATH}/${script}
done
