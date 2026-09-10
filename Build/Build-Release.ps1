[CmdletBinding()]
param(
    [ValidateSet('Plan', 'Build', 'Publish')]
    [string] $RunMode = 'Build',

    [string] $ConfigPath = (Join-Path $PSScriptRoot 'release.json'),

    [ValidatePattern('^[0-9a-fA-F]{40}$')]
    [string] $ExpectedCommit,

    [string] $Confirmation
)

$ErrorActionPreference = 'Stop'

$repositoryRoot = [System.IO.Path]::GetFullPath(
    (Join-Path $PSScriptRoot '..'))
if ($RunMode -eq 'Publish') {
    if ([string]::IsNullOrWhiteSpace($ExpectedCommit)) {
        throw 'ExpectedCommit is required for a public release.'
    }

    [string] $actualCommit = (& git -C $repositoryRoot rev-parse HEAD).Trim()
    if ($LASTEXITCODE -ne 0 -or $actualCommit -ine $ExpectedCommit) {
        throw "Expected release commit '$ExpectedCommit', received '$actualCommit'."
    }

    [array] $checkoutChanges = & git -C $repositoryRoot status --porcelain
    if ($LASTEXITCODE -ne 0) {
        throw 'The release checkout state could not be inspected.'
    }
    if ($checkoutChanges.Count -ne 0) {
        throw "The release checkout contains changes: $($checkoutChanges -join ', ')"
    }

    [xml] $primaryProject = Get-Content -LiteralPath `
        (Join-Path $repositoryRoot 'Sources\EventViewerX\EventViewerX.csproj') -Raw
    [array] $releaseVersions = @($primaryProject.Project.PropertyGroup.VersionPrefix |
        ForEach-Object { [string] $_ } |
        Where-Object { -not [string]::IsNullOrWhiteSpace($_) } |
        Sort-Object -Unique)
    if ($releaseVersions.Count -ne 1 -or
        [string] $releaseVersions[0] -notmatch '^\d+\.\d+\.\d+$') {
        throw 'The primary EventViewerX project must declare one exact VersionPrefix for publication.'
    }

    [string] $expectedConfirmation =
        "publish:$($releaseVersions[0]):$($ExpectedCommit.ToLowerInvariant())"
    if ($Confirmation -cne $expectedConfirmation) {
        throw "Confirmation must exactly equal '$expectedConfirmation'."
    }
}

Import-Module PSPublishModule -MinimumVersion 3.0.141 -Force -ErrorAction Stop

$invokeSplat = @{
    ConfigPath    = $ConfigPath
    ModuleRunMode = if ($RunMode -eq 'Build') { 'Build' } else { 'Publish' }
}
if ($RunMode -eq 'Plan') {
    $invokeSplat.Plan = $true
}
if ($RunMode -eq 'Publish') {
    $invokeSplat.SourceRepositoryRoot = $repositoryRoot
    $invokeSplat.ExpectedSourceRevision = $ExpectedCommit
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
