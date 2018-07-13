#!/usr/bin/env bash

set -eE
trap "exit 0" SIGINT
trap "tailLogs" ERR

function tailLogs() {
    echo "!!! Failed !!!"
    tail -n20 build.log

    echo ""
    echo "See build.log for more details"
}

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_DIR="${SCRIPT_DIR}/../.."

source "${PROJECT_DIR}/scripts/buildconfig.sh"

binary_name="$(getBuildConfig binary.name)"
binary_version="v$(getBuildConfig binary.version)"

image_name="$(getBuildConfig image.organization)/$(getBuildConfig image.name)"
image_version="$(getBuildConfig image.version)"

github_organization="$(getBuildConfig github.organization)"
github_name="$(getBuildConfig github.name)"
github_repo="${github_organization}/${github_name}"

if
    [ "${GITHUB_TOKEN}" == "" ]
then
    echo "The GITHUB_TOKEN environment variable must be defined so that we may do the release!"
    exit 1
fi

release_args="--user ${github_organization} --repo ${github_name} --tag ${binary_version}"
GITHUB_RELEASE="docker run --rm -it -v $(pwd)/src/dist:/dist -e GITHUB_TOKEN=${GITHUB_TOKEN} casualjim/github-release"

if
    ! (git tag | grep -q "^v${binary_version}$")
then
    echo "* Building binary"
    ${SCRIPT_DIR}/../build-binary/nix.sh ${binary_version} all ${image_version} &>> ./build.log

    echo "* Pushing v${binary_version} to ${github_repo} (code and tags)"
    git tag "${binary_version}" &>> build.log
    git push --tags git@github.com:${github_repo}.git &>> build.log

    echo "* Creating GitHub release ${binary_version}"
    ${GITHUB_RELEASE} release ${release_args} --name "${binary_version}" --description "${description}" &>> build.log

    echo "* Uploading files to GitHub release"
    ${GITHUB_RELEASE} upload ${release_args} --name "${binary_name}-darwin" --file "/dist/darwin/${binary_name}" &>> build.log
    ${GITHUB_RELEASE} upload ${release_args} --name "${binary_name}-linux" --file "/dist/linux/${binary_name}" &>> build.log
    ${GITHUB_RELEASE} upload ${release_args} --name "${binary_name}.exe" --file "/dist/windows/${binary_name}.exe" &>> build.log
fi

if
    ! docker pull "${image_name}:${image_version}" &> /dev/null
then
    echo "* Building image"
    ${SCRIPT_DIR}/../build-image/nix.sh &>> ./build.log

    echo "* Log in to Docker Hub"
    docker login

    echo "* Pushing Docker images to Docker Hub (version ${image_version})"
    docker tag ${image_name} ${image_name}:${image_version} &>> build.log
    docker tag ${image_name} ${image_name}:latest &>> build.log
    docker push ${image_name}:${image_version} &>> build.log
    docker push ${image_name}:latest &>> build.log
fi

echo "* Release ${binary_version} (docker image version ${image_version}) completed"
