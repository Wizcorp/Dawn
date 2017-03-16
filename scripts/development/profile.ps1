$SCRIPT_DIR = Split-Path $myInvocation.MyCommand.Path
$PROJECT_DIR = split-path $SCRIPT_DIR -parent | split-path -parent

$env:Path += ";${PROJECT_DIR}\src\dist\windows"
$env:DAWN_DEVELOPMENT = "${PROJECT_DIR}"

function prompt {
    "PS [dawn-development] $(Get-Location)> "
}

function rebuild {
    & "${PROJECT_DIR}\scripts\build\windows.ps1"
}
