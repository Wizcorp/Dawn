#!/usr/bin/env bash

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_DIR="${SCRIPT_DIR}/../.."

local_os="$(uname -s | tr '[:upper:]' '[:lower:]')"

version="${1:-"development"}"
target="${2:-${local_os}}"
image="${3:-"development"}"

docker run \
    -it \
    --rm \
    -e HOME=/tmp \
    -u `id -u` \
    -v "${PROJECT_DIR}:/go/src/cli" \
    -w /go/src/cli/src \
    instrumentisto/glide:0.13.1-go1.10 \
    install

docker run \
    -it \
    --rm \
    -e HOME=/tmp \
    -u `id -u` \
    -v "${PROJECT_DIR}:/go/src/cli" \
    -w /go/src/cli/src \
    --entrypoint "/usr/local/go/bin/go" \
    instrumentisto/glide:0.13.1-go1.10 \
    run make.go \
        --target "${target}" \
        --version "${version}" \
        --image "${image}"
