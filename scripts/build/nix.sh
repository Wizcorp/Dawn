#!/usr/bin/env bash

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_DIR="${SCRIPT_DIR}/../.."

local_os="$(uname -s | tr '[:upper:]' '[:lower:]')"
version="${1:-"development"}"
target="${2:-${local_os}}"

docker build "${PROJECT_DIR}/docker-image" --tag "dawn/dawn"
docker tag dawn/dawn dawn/dawn:${version}
docker tag dawn/dawn dawn/dawn:latest

docker run -it \
    -e HOME=/tmp \
    -u `id -u` \
    -v "${PROJECT_DIR}:/go/src/dawn" \
    -w /go/src/dawn/src \
    myobplatform/go-glide:1.7-alpine \
    glide install

docker run -it \
    -v "${PROJECT_DIR}:/go/src/dawn" \
    -w /go/src/dawn/src \
    myobplatform/go-glide:1.7-alpine \
    go run make.go \
        --target "${target}" \
        --version "${version}"
