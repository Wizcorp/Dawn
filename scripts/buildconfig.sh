#!/usr/bin/env bash

getBuildConfig () {
    cat ${PROJECT_DIR}/buildconfig.yml \
        | docker run \
            -i \
            jlordiales/jyparser \
            get -r ${@}
}
