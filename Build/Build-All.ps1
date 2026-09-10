[CmdletBinding()]
param(
    [Alias('ConfigurationGateMode')]
    [ValidateSet('Manifest', 'Plan', 'Build', 'Publish')]
    [string] $RunMode = 'Build',

    [ValidatePattern('^[0-9a-fA-F]{40}$')]
    [string] $ExpectedCommit,

    [string] $PublishConfirmation
)

$ErrorActionPreference = 'Stop'

if ($RunMode -eq 'Manifest') {
    & (Join-Path $PSScriptRoot 'Build-Module.ps1') -RunMode Manifest
} else {
    $releaseSplat = @{
        RunMode = $RunMode
    }
    if ($RunMode -eq 'Publish') {
        if (-not [string]::IsNullOrWhiteSpace($ExpectedCommit)) {
            $releaseSplat.ExpectedCommit = $ExpectedCommit
        }
        if (-not [string]::IsNullOrWhiteSpace($PublishConfirmation)) {
            $releaseSplat.Confirmation = $PublishConfirmation
        }
    }
    & (Join-Path $PSScriptRoot 'Build-Release.ps1') @releaseSplat
}
