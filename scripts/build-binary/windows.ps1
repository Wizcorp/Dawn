Param(
  [string]$target = "windows",
  [string]$version = "development",
  [string]$image = "development"
)

$SCRIPT_DIR = Split-Path $myInvocation.MyCommand.Path
$PROJECT_DIR = split-path $SCRIPT_DIR -parent | split-path -parent

docker run `
    -it `
    --rm `
    -v "${PROJECT_DIR}:/go/src/cli" `
    -w /go/src/cli/src `
    myobplatform/go-glide:1.7-alpine `
    glide install

docker run `
    -it `
    --rm `
    -v "${PROJECT_DIR}:/go/src/cli" `
    -w /go/src/cli/src `
    myobplatform/go-glide:1.7-alpine `
    go run make.go `
        --target "${target}" `
        --version "${version}" `
        --image "${image}"
