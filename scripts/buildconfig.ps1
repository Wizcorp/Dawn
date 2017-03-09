function getBuildConfig() {
    return Get-Content ${PROJECT_DIR}/buildconfig.yml `
        | docker run `
            -i `
            jlordiales/jyparser `
            get -r $args
}
