#!/bin/bash -il

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_DIR="$(dirname $(dirname ${SCRIPT_DIR}))"

local_os="$(uname -s | tr '[:upper:]' '[:lower:]')"

# Make sure everything is built
${SCRIPT_DIR}/../build/nix.sh
export DAWN_DEVELOPMENT="${PROJECT_DIR}"
export PATH="${PROJECT_DIR}/src/dist/${local_os}:${PATH}:${SCRIPT_DIR}"

# This will be required for users using
# powerline. Powerline (or at least powerline-shell)
# uses PROMPT_COMMAND and appears to disable
if
  [ "$PS1" == "" ]
then
  export PS1="\w > "
fi

export PS1="[Dawn development]${PS1}"

exec bash --noprofile --norc
