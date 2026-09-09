[CmdletBinding()]
param(
    [ValidateSet('Plan', 'Build', 'Publish')]
    [string] $RunMode = 'Build',

    [string] $ConfigPath = (Join-Path $PSScriptRoot 'release.json')
)

$ErrorActionPreference = 'Stop'

Import-Module PSPublishModule -MinimumVersion 3.0.139 -Force -ErrorAction Stop

$invokeSplat = @{
    ConfigPath    = $ConfigPath
    ModuleRunMode = if ($RunMode -eq 'Build') { 'Build' } else { 'Publish' }
}
if ($RunMode -eq 'Plan') {
    $invokeSplat.Plan = $true
}

$result = Invoke-PowerForgeRelease @invokeSplat
if ($null -eq $result -or -not $result.Success) {
    $message = if ($null -eq $result) {
        'The unified PowerForge release returned no result.'
    } else {
        [string] $result.ErrorMessage
    }
    throw "The unified PowerForge release failed. $message"
}

$result
