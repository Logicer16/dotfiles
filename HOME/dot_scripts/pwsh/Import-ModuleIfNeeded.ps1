[CmdletBinding()]
Param(
  [Parameter(Mandatory)]
  [string]
  $Name
)

if (![bool](Get-Module $Name)) {
  Import-Module $Name @Args
}
