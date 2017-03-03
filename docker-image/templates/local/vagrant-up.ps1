# Make sure network is set up
.\networking.ps1

# We try to find sh and ssh on the local system;
# we essentially check to see if git or cygwin is
# installed, piggyback them to run vagrant or
# run an error of neither is found
If (Test-Path "C:\Program Files\Git\bin\") {
  $env:Path += ";C:\Program Files\Git\bin\"
} ElseIf (Test-Path "C:\cygwin64\bin\") {
  $env:Path += ";C:\cygwin64\bin\"
} Else {
  Write-Error "Could not find a local ssh setup"
  Write-Error "Make sure to have at least one of the following installed on your system:"
  Write-Error "    1. git"
  Write-Error "    2. Cygwin (64 bit)"
  Exit 1
}

# Find the dawn-local virtual switch
$switch = Get-VMSwitch | Select-String "dawn-local"
$index = $switch.LineNumber

# This option is just to automate
# the virtual switch selection
sh -c "yes $index | vagrant up"
