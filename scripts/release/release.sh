#!/usr/bin/env bash

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_DIR="${SCRIPT_DIR}/../.."

source "${PROJECT_DIR}/scripts/buildconfig.sh"

binary_name="$(getBuildConfig binary.name)"
binary_version="$(getBuildConfig binary.version)"

image_name="$(getBuildConfig image.organization)/$(getBuildConfig image.name)"
image_version="$(getBuildConfig image.version)"

github_organization="$(getBuildConfig gitub.organization)"
github_name="$(getBuildConfig github.name)"
github_repo="${github_organization}/${github_name}"

if
    [ "${GITHUB_TOKEN}" == "" ]
then
    echo "The GITHUB_TOKEN environment variable must be defined so that we may do the release!"
    exit 1
fi

release_args="--user ${github_organization} --repo ${github_name} --tag ${binary_version}"
GITHUB_RELEASE="docker run -it -e 'GITHUB_TOKEN=${GITHUB_TOKEN}' casualjim/github-release ${release_args}"

echo "* Building image"
${SCRIPT_DIR}/../build-image/nix.sh > ./build.log

echo "* Building binary"
${SCRIPT_DIR}/../build-binary/nix.sh all ${binary_version}${image_version} >> ./build.log

echo "* Pushing to GitHub (code and tags)"
git tag ${version}
git push --tags git@github.com:${github_repo}.git

echo "* Log in to Docker Hub"
docker login

echo "* Pushing Docker image to Docker Hub"
docker tag ${image_name} ${image_name}:${image_version}
docker tag ${image_name} ${image_name}:latest
docker push ${image_name}:${image_version}
docker push ${image_name}:latest

echo "* Creating GitHub release"
${GITHUB_RELEASE} release ${release_args} \
  --name "${version}" \
  --description "${description}"

echo "* Uploading files to GitHub release"
${GITHUB_RELEASE} upload "${release_args}" --name "${binary_name}-darwin" --file "./src/dist/darwin/${binary_name}"
${GITHUB_RELEASE} upload "${release_args}" --name "${binary_name}-linux" --file "./src/dist/linux/${binary_name}"
${GITHUB_RELEASE} upload "${release_args}" --name "${binary_name}.exe" --file "./src/dist/windows/${binary_name}.exe"

echo "* Release ${version} completed"
