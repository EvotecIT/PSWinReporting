[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$repositoryRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$buildModulePath = Join-Path $PSScriptRoot 'Build-Module.ps1'
$buildReleasePath = Join-Path $PSScriptRoot 'Build-Release.ps1'

$unsupportedPublishArguments = @(
    @{ PreReleaseTag = 'preview1' }
    @{ Configuration = 'Debug' }
    @{ NoDotnetBuild = $true }
    @{ StagingPath = 'Artefacts\Existing' }
    @{ ReuseStaging = $true }
    @{ IncludeProjectPackages = $false }
    @{ IncludeModulePublishing = $false }
    @{ PowerForgeUnifiedGitHubRelease = $true }
    @{ PowerForgeReleaseStage = $true }
)
foreach ($arguments in $unsupportedPublishArguments) {
    [string] $parameterName = @($arguments.Keys)[0]
    try {
        & $buildModulePath -RunMode Publish -ModuleVersion '4.0.0' `
            -SignModule:$false @arguments
        throw "Build-Module.ps1 unexpectedly accepted $parameterName for publication."
    } catch {
        if ($_.Exception.Message -notlike "*does not support:*$parameterName*") {
            throw
        }
    }
}

try {
    & $buildModulePath -RunMode Publish -ModuleVersion '4.0.0' -SignModule:$false
    throw 'Build-Module.ps1 unexpectedly accepted publication without an exact commit.'
} catch {
    if ($_.Exception.Message -notlike 'ExpectedCommit is required for a public release.*') {
        throw
    }
}

[string] $actualCommit = (& git -C $repositoryRoot rev-parse HEAD).Trim()
if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($actualCommit)) {
    throw 'The current commit could not be resolved for release-guard validation.'
}

$markerPath = Join-Path $repositoryRoot '.release-guard-untracked'
try {
    Set-Content -LiteralPath $markerPath -Value 'release guard validation'
    try {
        & $buildReleasePath -RunMode Publish -Version '4.0.0' `
            -SignModule:$false -SkipCli -ExpectedCommit $actualCommit `
            -Confirmation "publish:4.0.0:$actualCommit"
        throw 'Build-Release.ps1 unexpectedly accepted an untracked file.'
    } catch {
        if ($_.Exception.Message -notlike '*release checkout contains changes*' -or
            $_.Exception.Message -notlike '*.release-guard-untracked*') {
            throw
        }
    }
} finally {
    if (Test-Path -LiteralPath $markerPath) {
        Remove-Item -LiteralPath $markerPath -Force
    }
}

[pscustomobject] @{
    UnsupportedPublishParametersBlocked = $unsupportedPublishArguments.Count
    UnguardedModulePublishBlocked = $true
    UntrackedFileBlocked = $true
}
