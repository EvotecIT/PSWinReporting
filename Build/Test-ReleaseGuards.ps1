[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$repositoryRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$buildAllPath = Join-Path $PSScriptRoot 'Build-All.ps1'
$buildModulePath = Join-Path $PSScriptRoot 'Build-Module.ps1'
$buildReleasePath = Join-Path $PSScriptRoot 'Build-Release.ps1'

foreach ($wrapperPath in @($buildAllPath, $buildModulePath)) {
    try {
        & $wrapperPath -RunMode Publish
        throw "$(Split-Path -Leaf $wrapperPath) unexpectedly accepted an unguarded publication."
    } catch {
        if ($_.Exception.Message -notlike 'ExpectedCommit is required for a public release.*') {
            throw
        }
    }
}

[string] $actualCommit = (& git -C $repositoryRoot rev-parse HEAD).Trim()
if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($actualCommit)) {
    throw 'The current commit could not be resolved for release-guard validation.'
}

$wrongCommit = '0000000000000000000000000000000000000000'
try {
    & $buildReleasePath -RunMode Publish -ExpectedCommit $wrongCommit
    throw 'Build-Release.ps1 unexpectedly accepted the wrong commit.'
} catch {
    if ($_.Exception.Message -notlike "Expected release commit '$wrongCommit'*") {
        throw
    }
}

try {
    & $buildReleasePath -RunMode Publish -ExpectedCommit $actualCommit `
        -Confirmation "publish:4.0.0:$actualCommit:invalid"
    throw 'Build-Release.ps1 unexpectedly accepted the wrong confirmation.'
} catch {
    if ($_.Exception.Message -notlike 'Confirmation must exactly equal*') {
        throw
    }
}

$markerPath = Join-Path $repositoryRoot '.release-guard-untracked'
try {
    Set-Content -LiteralPath $markerPath -Value 'release guard validation'
    try {
        & $buildReleasePath -RunMode Publish -ExpectedCommit $actualCommit `
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
        Remove-Item -LiteralPath $markerPath
    }
}

[pscustomobject] @{
    UnguardedModulePublishBlocked = $true
    UnguardedFullPublishBlocked = $true
    WrongCommitBlocked = $true
    WrongConfirmationBlocked = $true
    UntrackedFileBlocked = $true
    PostBuildSourceStateGuardEnabled = $true
}
