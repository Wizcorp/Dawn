Param(
    [string]$version = "",
    [string]$repository = "Wizcorp/Dawn"
)

$myWindowsID=[System.Security.Principal.WindowsIdentity]::GetCurrent()
$myWindowsPrincipal=new-object System.Security.Principal.WindowsPrincipal($myWindowsID)
$adminRole=[System.Security.Principal.WindowsBuiltInRole]::Administrator

If (-NOT $myWindowsPrincipal.IsInRole($adminRole)) {
    Write-Error "** You must run this command in an administrative shell. Aborting ***"
    Exit 1
}

if ($version -eq "") {
  $latestReleaseInfo = (Invoke-RestMethod "https://api.github.com/repos/${repository}/releases/latest").Trim()
  $json = $latestRelease.Content | ConvertFrom-Json
  $version = $json.tag_name
}

$src = "https://github.com/${repository}/releases/download/${version}/dawn.exe"
$dest = "C:\Windows\System32\dawn.exe"

Write-Output "* Downloading dawn (version: ${version})"
Invoke-WebRequest -uri ${src} -out ${dest}

if ($?) {
  write-output "* Install completed!"
} else {
  write-output "* Install failed"
}
