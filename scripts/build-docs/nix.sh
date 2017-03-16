#!/usr/bin/env bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_DIR="${SCRIPT_DIR}/../.."

SRC="docs"
DEST=".docs"

# We need to create the folder for the volume we mount;
# otherwise, on linux, users may run into issues with
# file permissions
mkdir -p "${DEST}"

docker run \
    --rm \
    -e HOME=/tmp \
    -u `id -u` \
    -v "${PROJECT_DIR}/${SRC}:/app/source" \
    -v "${PROJECT_DIR}/${DEST}:/app/build" \
    -it stelcheck/slate:latest \
    bundle exec middleman build ${@}
