$SCRIPT_DIR = Split-Path $myInvocation.MyCommand.Path
powershell -NoLogo "${SCRIPT_DIR}\..\build-image\windows.ps1"
powershell -NoLogo "${SCRIPT_DIR}\..\build-binary\windows.ps1"
powershell -NoLogo -NoProfile -NoExit -Command "Invoke-Expression '. ''${SCRIPT_DIR}\profile.ps1'''"
