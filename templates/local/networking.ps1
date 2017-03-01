# Sources:
#   https://blogs.msdn.microsoft.com/virtual_pc_guy/2010/09/23/a-self-elevating-powershell-script/
#   https://quotidian-ennui.github.io/blog/2016/08/17/vagrant-windows10-hyperv/
#   http://www.jasonhelmick.com/2010/11/06/suppressing-the-powershell-progress-bar-2/


# Disable progress bar(s)
$ProgressPreference = "SilentlyContinue"

# Get the ID and security principal of the current user account
$myWindowsID=[System.Security.Principal.WindowsIdentity]::GetCurrent()
$myWindowsPrincipal=new-object System.Security.Principal.WindowsPrincipal($myWindowsID)

# Get the security principal for the Administrator role
$adminRole=[System.Security.Principal.WindowsBuiltInRole]::Administrator

If (-NOT $myWindowsPrincipal.IsInRole($adminRole)) {
  # We are not running "as Administrator" - so relaunch as administrator

  # Create a new process object that starts PowerShell
  $newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell";

  # Specify the current script path and name as a parameter
  $newProcess.Arguments = $myInvocation.MyCommand.Definition;

  # Indicate that the process should be elevated
  $newProcess.Verb = "runas";

  # Start the new process
  [System.Diagnostics.Process]::Start($newProcess);

  # Exit from the current, unelevated, process
  break
}

# We are running "as Administrator" - so change the title and background color to indicate this
$Host.UI.RawUI.WindowTitle = $myInvocation.MyCommand.Definition + "(Elevated)"
$Host.UI.RawUI.BackgroundColor = "Blue"
$Host.UI.RawUI.ForegroundColor = "White"
clear-host

# Network switch
$res = Get-VMSwitch dawn-local -ErrorAction "SilentlyContinue"
If ($res -ne $null) {
  Write-Output "Switch dawn-local already exist"
} Else {
  Write-Host -NoNewline "Creating switch... "
  New-VMSwitch -SwitchName "dawn-local" -SwitchType Internal > $null
  Write-Output "[Done]"

  Write-Host -NoNewline "Setting local IP interface"
  New-NetIPAddress -IPAddress 172.24.0.1 -PrefixLength 16 -InterfaceAlias "vEthernet (dawn-local)" > $null
  Write-Output "[Done]"
}

# NAT
$res = Get-NetNat dawn-local-nat -ErrorAction "SilentlyContinue"
If ($res -ne $null) {
  Write-Output "NAT already exist"
} Else {
  Write-Host -NoNewline "Creating NAT..."
  New-NetNat -Name dawn-local-nat -InternalIPInterfaceAddressPrefix 172.24.0.0/16 > $null
  Write-Output "[Done]"
}

Write-Output ""
Read-Host "Done. Press any key to continue"
