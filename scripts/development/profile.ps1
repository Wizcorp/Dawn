$SCRIPT_DIR = Split-Path $myInvocation.MyCommand.Path
$PROJECT_DIR = split-path $SCRIPT_DIR -parent | split-path -parent

$env:Path += ";${PROJECT_DIR}\src\dist\windows"
$env:DEVELOPMENT_MODE = "${PROJECT_DIR}"

. "${PROJECT_DIR}\scripts\buildconfig.ps1"

$name="$(getBuildConfig github.name)"

function prompt {
    "PS [${name} development] $(Get-Location)> "
}

function rebuild {
    & "${PROJECT_DIR}\scripts\build-image\windows.ps1"
    & "${PROJECT_DIR}\scripts\build-binary\windows.ps1"
    & "${PROJECT_DIR}\scripts\build-docs\windows.ps1"
}

function rebuild-image {
    & "${PROJECT_DIR}\scripts\build-image\windows.ps1"
}

function rebuild-binary {
    & "${PROJECT_DIR}\scripts\build-binary\windows.ps1"
}

function rebuild-docs {
    & "${PROJECT_DIR}\scripts\build-docs\windows.ps1"
}

