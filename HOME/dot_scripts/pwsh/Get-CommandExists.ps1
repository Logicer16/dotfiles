[CmdletBinding()]
Param(
  [Parameter(Position = 0, Mandatory)]
  [string[]]
  $cmdName
)
  
return [bool](Get-Command $cmdName -errorAction SilentlyContinue)
