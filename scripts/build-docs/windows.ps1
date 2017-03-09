$SCRIPT_DIR = Split-Path $myInvocation.MyCommand.Path
$PROJECT_DIR = split-path $SCRIPT_DIR -parent | split-path -parent

docker run `
    --rm `
    -v ${PROJECT_DIR}:/app/project `
    -v ${PROJECT_DIR}/docs:/app/source `
    -v ${PROJECT_DIR}/.docs:/app/build `
    -it stelcheck/slate:latest `
    bundle exec middleman build
