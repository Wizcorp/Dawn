# Installation

## Requirements

<aside class="warning">
   Windows users will need to make sure that 
    their work drive (normally C:) is shared in Docker. See 
    [the Docker documentation](https://blogs.msdn.microsoft.com/stevelasker/2016/06/14/configuring-docker-for-windows-volumes/)
    for more details.
</aside>
<aside class="notice">
   Some templates may have additional requirements of their own.
</aside>

|  Software  | Version |
|------------|---------|
| Docker     | 1.13.0+ |

## Installing the local binary

> You will need to run this as administrator.

```shell
~/ \# curl -fsSL https://dawn.sh/install | sh
# Or, to install a specific version
~/ \# curl -fsSL https://dawn.sh/install | version=v0.0.1 sh
```

```powershell
PS C:\Users\stelcheck> Invoke-RestMethod https://dawn.sh/install-win | powershell -command -
# Or, to install a specific version
PS C:\Users\stelcheck> Invoke-WebRequest -uri https://dawn.sh/install-win -OutFile install.ps1
.\install.ps1 -version v0.0.1
```

Installing the local binary is all about running this single one-liner. You can
additionally specify which version to install at runtime, if desired; by default,
the installation process will try to find the latest version and install it.

The only file which will be downloaded is the `dawn` binary itself, so the 
install process should be quick.

## Updating the local binary

<aside class="warning">
    Before updating, make sure you do not have any container sessions currently running.
</aside>

> You will need to run this as administrator.

```shell
~/ \# dawn --update
```

```powershell
PS C:\Users\stelcheck> dawn --update
```

The local binary can self-update. It will download the same script used
for the installation and run it for you. 
