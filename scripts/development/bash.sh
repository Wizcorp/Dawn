#!/bin/bash -l

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_DIR="$(dirname $(dirname ${SCRIPT_DIR}))"

local_os="$(uname -s | tr '[:upper:]' '[:lower:]')"

# Make sure everything is built
${SCRIPT_DIR}/../build/nix.sh
export DAWN_DEVELOPMENT="${PROJECT_DIR}"
export PATH="${PROJECT_DIR}/src/dist/${local_os}:${PATH}:${SCRIPT_DIR}"
export PS1="${PS1:0:${#PS1}-2}[dawn development]${PS1:${#PS1}<2?0:-2}"

exec bash
