#!/usr/bin/env bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_DIR="${SCRIPT_DIR}/../.."

# Get version from git
version="$(git tag --points-at $(git rev-parse HEAD))"

if
    [ "${version}" == "" ]
then
    echo "Could not find version. Make sure to git tag your release!"
    exit 1
fi

if
    [ "${GITHUB_TOKEN}" == "" ]
then
    echo "The GITHUB_TOKEN environment variable must be defined so that we may do the release!"
    exit 1
fi

release_args="--user Wizcorp --repo Dawn --tag ${version}"
GITHUB_RELEASE="docker run -it -e 'GITHUB_TOKEN=${GITHUB_TOKEN}' casualjim/github-release ${release_args}"


echo "* Building"
${SCRIPT_DIR}/../build/nix.sh ${version} all > ./build.log

echo "* Pushing to GitHub (code and tags)"
git push --tags git@github.com:Wizcorp/Dawn.git

echo "* Log in to Docker Hub"
docker login

echo "* Pushing Docker image to Docker Hub"
docker push dawn/dawn:${version}
docker push dawn/dawn:latest

echo "* Creating GitHub release"
${GITHUB_RELEASE} release ${release_args} \
  --name "${version}" \
  --description "${description}"

echo "* Uploading files to GitHub release"
${GITHUB_RELEASE} upload "${release_args}" --name "dawn-darwin" --file "./src/dist/darwin/dawn"
${GITHUB_RELEASE} upload "${release_args}" --name "dawn-linux" --file "./src/dist/linux/dawn"
${GITHUB_RELEASE} upload "${release_args}" --name "dawn.exe" --file "./src/dist/windows/dawn.exe"

echo "* Release ${version} completed"
