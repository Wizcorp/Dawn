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
    myobplatform/go-glide:1.7-alpine \
    glide install

docker run \
    -it \
    --rm \
    -v "${PROJECT_DIR}:/go/src/cli" \
    -w /go/src/cli/src \
    myobplatform/go-glide:1.7-alpine \
    go run make.go \
        --target "${target}" \
        --version "${version}" \
        --image "${image}"
