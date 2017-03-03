Param(
  [string]$target = "windows",
  [string]$version = "development"
)

$SCRIPT_DIR = Split-Path $myInvocation.MyCommand.Path
$PROJECT_DIR = split-path $SCRIPT_DIR -parent | split-path -parent

docker build "${PROJECT_DIR}/docker-image" --tag "dawn/dawn"
docker tag dawn/dawn dawn/dawn:${version}
docker tag dawn/dawn dawn/dawn:latest

docker run -it `
    -v "${PROJECT_DIR}:/go/src/dawn" `
    -w /go/src/dawn/src `
    myobplatform/go-glide:1.7-alpine `
    go run make.go `
        --target "${target}" `
        --version "${version}"
