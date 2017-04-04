#!/usr/bin/env bash

getBuildConfig () {
    cat ${PROJECT_DIR}/buildconfig.yml \
        | docker run \
            -i \
            --rm \
            jlordiales/jyparser \
            get -r ${@}
}
