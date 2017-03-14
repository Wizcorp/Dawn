#!/usr/bin/env bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_DIR="${SCRIPT_DIR}/../.."

docker run \
    --rm \
    -e HOME=/tmp \
    -u `id -u` \
    -v ${PROJECT_DIR}/docs:/app/source \
    -v ${PROJECT_DIR}/.docs:/app/build \
    -it stelcheck/slate:latest \
    bundle exec middleman build ${@}
