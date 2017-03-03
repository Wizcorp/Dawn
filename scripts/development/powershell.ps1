$SCRIPT_DIR = Split-Path $myInvocation.MyCommand.Path
powershell -NoLogo "${SCRIPT_DIR}\..\build\windows.ps1"
powershell -NoLogo -NoProfile -NoExit -Command "Invoke-Expression '. ''${SCRIPT_DIR}\profile.ps1'''"
