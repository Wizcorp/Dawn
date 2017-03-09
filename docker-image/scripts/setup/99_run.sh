if
    [ -f "${PROJECT_ENVIRONMENT_FILES_PATH}/run.sh" ]
then
    pushd "${PROJECT_ENVIRONMENT_FILES_PATH}" &> /dev/null
    source "run.sh"
    popd &> /dev/null
fi
