#!/usr/bin/env bash

set -e

local_os="$(uname -s | tr '[:upper:]' '[:lower:]')"

if
    [ "${repository}" == "" ]
then
    repository="Wizcorp/Dawn"
fi

if
    [ "${version}" == "" ]
then
    version="$(curl -s https://api.github.com/repos/${repository}/releases/latest \
        | grep tag_name \
        | sed 's/  "tag_name": "\(.*\)",/\1/')"
fi

cd /usr/bin
echo "* Downloading dawn (version: ${version})"

if
    sudo curl -s https://github.com/${repository}/releases/download/${version}/dawn-${local_os} > dawn
then
    echo "* Setting permission on dawn"
    sudo chmod 755 dawn
    echo "* Install completed!"
else
    echo "* Install failed"
    exit 1
fi
