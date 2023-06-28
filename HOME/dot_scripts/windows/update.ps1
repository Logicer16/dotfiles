function Get-CommandExists {
  Param(
    [Parameter(Position=0, Mandatory)]
    [string[]]
    $cmdName
  )
  
  Get-Command $cmdName -errorAction SilentlyContinue
}

# Self-Elevate
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
  $title    = 'Your terminal is not currently elevated'
  $question = 'Would you like to elevate to run the script?'
  $choices  = '&Yes', '&No'

  $decision = $Host.UI.PromptForChoice($title, $question, $choices, 0)
  if ($decision -eq 0) {

    if (Get-CommandExists pwsh.exe) {
      $pwsh = "pwsh.exe"
    } elseif (Get-CommandExists powershell.exe) {
      $pwsh = "powershell.exe"
    } else {
      Throw "I don't how you're running this because I cant seem to find powershell installed."
    }

    # Relaunch as an elevated process:
    if (Get-CommandExists wt.exe) {
      Start-Process -Verb RunAs wt.exe ('{0} {1} {2}' -f $pwsh,"-NoExit -File",('"{0}"' -f $MyInvocation.MyCommand.Path))
    } else {
      Start-Process $pwsh "-File",('"{0}"' -f $MyInvocation.MyCommand.Path) -Verb RunAs
    }
    exit
  } else {
    $elevated = $false
  }
} else {
  $elevated = $true
}

#! Doesn't work idk
# wsl (possibly async)
# $distros = wsl.exe --list -q
# foreach ($distro in $distros.split()) {
#   $distro = $distro -replace "`0", "" # Useless 
#   if ([string]::IsNullOrWhitespace($distro)) {continue}

#   $command = ("FILE={0} && [[ -f `"`$FILE`" ]] && {0} && zsh || bash" -f "~/.scripts/update") # If the update script exists, zsh exists

#   # exit
#   $wsl = "wsl.exe"

#   if (Get-CommandExists wt.exe) {
#     Write-Host wt.exe ("$wsl -d $distro -e bash -l -c -- $command")
#     wt.exe ("$wsl -d $distro -e bash -l -c -- $command")
#   } else {
#     wsl.exe -d $distro -e bash -l -c -- $command #? IDK
#   }
# }

# exit

# Window General
winget upgrade --all

# PowerShell Modules
Update-Module

# Chezmoi
chezmoi update

# Windows Update
# Requires elevation
if ($elevated) {
  Import-Module PSWindowsUpdate
  Install-WindowsUpdate -AcceptAll
}
