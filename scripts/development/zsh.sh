#!/bin/bash -il

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_DIR="$(dirname $(dirname ${SCRIPT_DIR}))"

source "${PROJECT_DIR}/scripts/buildconfig.sh"

local_os="$(uname -s | tr '[:upper:]' '[:lower:]')"
name="$(getBuildConfig github.name)"

# Make sure everything is built
${SCRIPT_DIR}/../build-image/nix.sh
${SCRIPT_DIR}/../build-binary/nix.sh

export DEVELOPMENT_MODE="${PROJECT_DIR}"
export PATH="${PROJECT_DIR}/src/dist/${local_os}:${PATH}:${SCRIPT_DIR}/commands"

# This will be required for users using
# powerline. Powerline (or at least powerline-shell)
# uses PROMPT_COMMAND and appears to disable
if
  [ "${PROMPT}" == "" ]
then
  export PROMPT="%B%F{10}%n@%m %F{12}%~ \$%f%b "
fi

export PROMPT="%F{9}(${name}) ${PROMPT}"

exec zsh -f
