#!/usr/bin/env bash

getBuildConfig () {
    docker run \
        -i \
        --rm \
        -v ${PROJECT_DIR}:/project \
        mikefarah/yq:1.15.0 \
        yq r /project/buildconfig.yml ${@}
}
