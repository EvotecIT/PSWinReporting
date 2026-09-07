[CmdletBinding()]
param(
    [string] $RepositoryRoot
)

$ErrorActionPreference = 'Stop'
if ([string]::IsNullOrWhiteSpace($RepositoryRoot)) {
    $RepositoryRoot = Split-Path -Parent $PSScriptRoot
}
$RepositoryRoot = [System.IO.Path]::GetFullPath($RepositoryRoot)

$release = Get-Content -LiteralPath (Join-Path $RepositoryRoot 'Build\release.json') -Raw |
    ConvertFrom-Json
if ([string] $release.GitHub.TokenEnvName -ne 'GITHUB_TOKEN' -or
    -not [string]::IsNullOrWhiteSpace([string] $release.GitHub.TokenFilePath)) {
    throw 'The unified GitHub release must use GITHUB_TOKEN without a machine-specific token path.'
}
if ($null -eq $release.Tools -or $release.GitHub.Publish -ne $true) {
    throw 'The full release must include CLI tools and the unified GitHub release.'
}
if (@($release.Module.ArtifactPaths | Where-Object { $_ -like '*EventViewerX.Cli.*.nupkg' }).Count -ne 0) {
    throw 'The full release must not publish the deferred EventViewerX.Cli .NET tool package.'
}

$moduleRelease = Get-Content -LiteralPath `
    (Join-Path $RepositoryRoot 'Build\release.module.json') -Raw |
    ConvertFrom-Json
if ($null -ne $moduleRelease.Tools -or $null -ne $moduleRelease.GitHub) {
    throw 'The module release must not include CLI tools or a unified GitHub release.'
}
if ($moduleRelease.Module.IncludesPackages -ne $true -or
    [string] $moduleRelease.Module.ConfigPath -ne 'Build/module.json') {
    throw 'The module release must include the canonical EventViewerX package configuration.'
}
if (@($moduleRelease.Module.ArtifactPaths | Where-Object { $_ -like '*EventViewerX.Cli.*.nupkg' }).Count -ne 0) {
    throw 'The module release must not publish the deferred EventViewerX.Cli .NET tool package.'
}
[array] $fullModuleAssets = @($release.Module.ArtifactPaths | Sort-Object)
[array] $moduleOnlyAssets = @($moduleRelease.Module.ArtifactPaths | Sort-Object)
if (($fullModuleAssets -join "`n") -cne ($moduleOnlyAssets -join "`n")) {
    throw 'The full and module-only release profiles must use the same package/module artifact set.'
}
[array] $moduleReleaseValidations = @($moduleRelease.Validation.AfterStaging)
if ($moduleReleaseValidations.Count -ne 1 -or
    [string] $moduleReleaseValidations[0].FilePath -ne 'Test-ModuleReleaseReady.ps1') {
    throw 'The module release must validate its exact staged package and module artifacts.'
}

$projectBuild = Get-Content -LiteralPath `
    (Join-Path $RepositoryRoot 'Sources\Build\project.build.json') -Raw |
    ConvertFrom-Json
if ($null -ne $projectBuild.ExpectedVersionMap.PSObject.Properties['EventViewerX.Cli']) {
    throw 'The EventViewerX.Cli .NET tool package must remain outside the library/module release.'
}
if ([string] $projectBuild.PublishApiKeyEnvName -ne 'NUGET_API_KEY' -or
    -not [string]::IsNullOrWhiteSpace([string] $projectBuild.PublishApiKeyFilePath)) {
    throw 'NuGet publication must use NUGET_API_KEY without a machine-specific API-key path.'
}
if ([string] $projectBuild.GitHubAccessTokenEnvName -ne 'GITHUB_TOKEN' -or
    -not [string]::IsNullOrWhiteSpace([string] $projectBuild.GitHubAccessTokenFilePath)) {
    throw 'Project GitHub authentication must use GITHUB_TOKEN without a machine-specific token path.'
}

$moduleBuild = Get-Content -LiteralPath (Join-Path $RepositoryRoot 'Build\module.json') -Raw |
    ConvertFrom-Json
[array] $gallerySegments = @($moduleBuild.Segments | Where-Object {
    $_.Type -eq 'GalleryNuget' -and $_.Configuration.Enabled -eq $true
})
if ($gallerySegments.Count -ne 1) {
    throw "Expected one enabled PowerShell Gallery publication segment, found $($gallerySegments.Count)."
}
$galleryKeyPath = [string] $gallerySegments[0].Configuration.ApiKeyFilePath
if ([System.IO.Path]::IsPathRooted($galleryKeyPath) -or
    $galleryKeyPath -ne '../.secrets/PowerShellGalleryAPI.txt') {
    throw 'PowerShell Gallery publication must use the ignored repo-local .secrets key path.'
}

[array] $legacyGitHubSegments = @($moduleBuild.Segments | Where-Object {
    $_.Type -eq 'GitHubNuget'
})
if (@($legacyGitHubSegments | Where-Object {
    $_.Configuration.Enabled -eq $true -or
    -not [string]::IsNullOrWhiteSpace([string] $_.Configuration.ApiKeyFilePath)
}).Count -ne 0) {
    throw 'The legacy module GitHub lane must stay disabled and must not declare a token-file path.'
}

[pscustomobject] @{
    NuGetCredential = 'NUGET_API_KEY'
    GitHubCredential = 'GITHUB_TOKEN'
    PowerShellGalleryCredential = $galleryKeyPath
    FullReleaseIncludesCli = $true
    ModuleReleaseIncludesCli = $false
    CliNuGetPackageIncluded = $false
}
