function getBuildConfig() {
    return Get-Content ${PROJECT_DIR}/buildconfig.yml `
        | docker run `
            -i `
            --rm `
jlordiales/jyparser:allow-command-line-options-in-jq `
            get -r $args
}
