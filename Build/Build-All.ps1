param(
    [Alias('ConfigurationGateMode')]
    [ValidateSet('Manifest', 'Plan', 'Build', 'Publish')]
    [string] $RunMode = 'Build',

    [bool] $SignModule = $true,

    [ValidatePattern('^\d+\.\d+\.\d+$')]
    [string] $Version = '4.0.0',

    [ValidateSet('auto', 'net472', 'net8.0', 'net10.0')]
    [string] $ModuleFramework,

    [switch] $SkipCli,

    [switch] $SkipInstall,

    [ValidatePattern('^[0-9a-fA-F]{40}$')]
    [string] $ExpectedCommit,

    [string] $PublishConfirmation
)

$ErrorActionPreference = 'Stop'

if ($RunMode -ne 'Manifest') {
    $releaseSplat = @{
        RunMode        = $RunMode
        Version        = $Version
        SignModule     = $SignModule
        SkipCli        = $SkipCli
        SkipInstall    = $SkipInstall
    }
    if ($RunMode -eq 'Publish') {
        if (-not [string]::IsNullOrWhiteSpace($ExpectedCommit)) {
            $releaseSplat.ExpectedCommit = $ExpectedCommit
        }
        if (-not [string]::IsNullOrWhiteSpace($PublishConfirmation)) {
            $releaseSplat.Confirmation = $PublishConfirmation
        }
    }
    if ($PSBoundParameters.ContainsKey('ModuleFramework')) {
        $releaseSplat.ModuleFramework = $ModuleFramework
    }
    & (Join-Path $PSScriptRoot 'Build-Release.ps1') @releaseSplat
} else {
    $moduleBuildSplat = @{
        RunMode      = $RunMode
        SignModule   = $SignModule
        ModuleVersion = $Version
        SkipInstall  = $SkipInstall
    }
    if ($PSBoundParameters.ContainsKey('ModuleFramework')) {
        $moduleBuildSplat.Framework = $ModuleFramework
    }
    & (Join-Path $PSScriptRoot 'Build-Module.ps1') @moduleBuildSplat
}
