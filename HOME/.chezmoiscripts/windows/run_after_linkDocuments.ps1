# Temporary solution until https://github.com/twpayne/chezmoi/issues/2273

# Exit on error
$ErrorActionPreference = "Stop"

function New-Safe-Symlink {
  [CmdletBinding()]
  param(
      [Parameter(Position=0,mandatory=$true)]
      [string] $origin,
      [Parameter(Position=1,mandatory=$true)]
      [string] $target)

  process{
    if (!(Test-Path $target)) {
      throw "Cannot link to file at `"$target`": file doesn't exist"
    }

    if (Test-Path $origin) { 
      if ((Get-Item $origin).Target -ne $target) {
        throw "Tried to link `"$origin`" to `"$target`" but a different file already exists there"
      }
    } else {
      $originParent = Split-Path -Path $origin
      If(!(test-path -PathType container $originParent)) {
        If(test-path  $originParent) {
          throw "Cannot create directory at `"$origin`": expected nothing; found file"
        }
        New-Item -ItemType Directory -Path $originParent | Out-Null
      }
      new-Item -ItemType SymbolicLink -Path $origin -Target $target | Out-Null
    }
  }
}

if (Get-Command "pwsh.exe" -ErrorAction SilentlyContinue) {
  New-Safe-Symlink (pwsh.exe -c "`$PROFILE.CurrentUserAllHosts") "$HOME\Documents\PowerShell\Profile.ps1"
}

if (Get-Command "powershell.exe" -ErrorAction SilentlyContinue) {
  New-Safe-Symlink (powershell.exe -c "`$PROFILE.CurrentUserAllHosts") "$HOME\Documents\WindowsPowerShell\Profile.ps1"
}
