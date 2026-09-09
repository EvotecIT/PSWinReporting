[CmdletBinding()]
param(
    [Alias('ConfigurationGateMode')]
    [ValidateSet('Manifest', 'Documentation', 'Plan', 'Build', 'Publish')]
    [string] $RunMode = 'Publish'
)

$ErrorActionPreference = 'Stop'

if ($RunMode -in @('Plan', 'Build', 'Publish')) {
    & (Join-Path $PSScriptRoot 'Build-Release.ps1') `
        -RunMode $RunMode `
        -ConfigPath (Join-Path $PSScriptRoot 'release.module.json')
} else {
    Import-Module PSPublishModule -MinimumVersion 3.0.139 -Force -ErrorAction Stop
    Invoke-ModuleBuild `
        -ConfigPath (Join-Path $PSScriptRoot 'module.json') `
        -RunMode $RunMode
}
