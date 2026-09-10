[CmdletBinding()]
param(
    [Alias('ConfigurationGateMode')]
    [ValidateSet('Manifest', 'Documentation', 'Plan', 'Build', 'Publish')]
    [string] $RunMode = 'Build',

    [ValidatePattern('^[0-9a-fA-F]{40}$')]
    [string] $ExpectedCommit,

    [string] $PublishConfirmation
)

$ErrorActionPreference = 'Stop'

if ($RunMode -in @('Plan', 'Build', 'Publish')) {
    $releaseSplat = @{
        RunMode    = $RunMode
        ConfigPath = Join-Path $PSScriptRoot 'release.module.json'
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
} else {
    Import-Module PSPublishModule -MinimumVersion 3.0.141 -Force -ErrorAction Stop
    Invoke-ModuleBuild `
        -ConfigPath (Join-Path $PSScriptRoot 'module.json') `
        -RunMode $RunMode
}
