[CmdletBinding()]
param(
    [ValidatePattern('^\d+\.\d+\.\d+(?:-[0-9A-Za-z.-]+)?$')]
    [string] $Version,

    [string] $CliManifestPath,

    [switch] $SkipCliArtifacts
)

$ErrorActionPreference = 'Stop'
$repositoryRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
& (Join-Path $PSScriptRoot 'Test-ReleaseConfiguration.ps1') `
    -RepositoryRoot $repositoryRoot | Out-Null
$context = $null
if (-not [string]::IsNullOrWhiteSpace($env:POWERFORGE_CONTEXT) -and
    (Test-Path -LiteralPath $env:POWERFORGE_CONTEXT -PathType Leaf)) {
    $context = Get-Content -LiteralPath $env:POWERFORGE_CONTEXT -Raw |
        ConvertFrom-Json
}

$expectedCliStagingRoot = [System.IO.Path]::GetFullPath(
    (Join-Path $repositoryRoot 'Artefacts\UploadReady\Cli')
).TrimEnd('\', '/')
$isCliOnly = $false
if ($null -ne $context -and
    -not [string]::IsNullOrWhiteSpace([string] $context.StagingRoot)) {
    $actualStagingRoot = [System.IO.Path]::GetFullPath(
        [string] $context.StagingRoot
    ).TrimEnd('\', '/')
    $isCliOnly = $actualStagingRoot -ieq $expectedCliStagingRoot
}

$resolvedVersion = $Version
if ([string]::IsNullOrWhiteSpace($resolvedVersion) -and $isCliOnly) {
    if ([string]::IsNullOrWhiteSpace([string] $context.ReleaseManifestPath)) {
        throw 'The CLI-only staged release did not provide a release manifest.'
    }
    $cliReleaseManifest = Get-Content -LiteralPath `
        ([string] $context.ReleaseManifestPath) -Raw | ConvertFrom-Json
    [array] $cliVersions = @($cliReleaseManifest.assetEntries |
        Where-Object { $_.category -eq 'Tool' } |
        ForEach-Object { [string] $_.Version } |
        Where-Object { -not [string]::IsNullOrWhiteSpace($_) } |
        Sort-Object -Unique)
    if ($cliVersions.Count -ne 1) {
        throw "Expected one CLI release version, found $($cliVersions.Count)."
    }
    $resolvedVersion = [string] $cliVersions[0]
}
if ([string]::IsNullOrWhiteSpace($resolvedVersion) -and $null -ne $context) {
    $resolvedVersion = [string] $context.ResolvedVersion
}
if ($resolvedVersion -notmatch '^\d+\.\d+\.\d+(?:-[0-9A-Za-z.-]+)?$') {
    throw 'The release version could not be resolved.'
}
$Version = $resolvedVersion

if ($isCliOnly) {
    & (Join-Path $PSScriptRoot 'Test-CliReleaseArtifacts.ps1') `
        -Version $Version `
        -CliManifestPath ([string] $context.ReleaseManifestPath) `
        -StagingRoot ([string] $context.StagingRoot) `
        -StagedAssets @($context.StagedAssets) `
        -RequireCliOnly
    return
}

$moduleRoot = $null
$packageRoot = $null
$moduleValidationRoot = $null
if ($null -ne $context) {
    if (-not $SkipCliArtifacts -and
        [string]::IsNullOrWhiteSpace($CliManifestPath) -and
        -not [string]::IsNullOrWhiteSpace([string] $context.ReleaseManifestPath)) {
        $CliManifestPath = [string] $context.ReleaseManifestPath
    }

    [array] $modulePackages = @($context.StagedAssets | Where-Object {
        [System.IO.Path]::GetFileName([string] $_) -ieq "PSEventViewer.v$Version.zip"
    })
    if ($modulePackages.Count -ne 1) {
        throw "Expected one staged PSEventViewer $Version archive, found $($modulePackages.Count)."
    }

    [array] $eventViewerPackages = @($context.StagedAssets | Where-Object {
        [System.IO.Path]::GetFileName([string] $_) -ieq "EventViewerX.$Version.nupkg"
    })
    if ($eventViewerPackages.Count -ne 1) {
        throw "Expected one staged EventViewerX $Version package, found $($eventViewerPackages.Count)."
    }
    $packageRoot = Split-Path -Parent ([string] $eventViewerPackages[0])

    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $validationRoot = Join-Path $repositoryRoot 'Artefacts\Validation'
    $moduleValidationRoot = Join-Path $validationRoot `
        "StagedModule-$([guid]::NewGuid().ToString('N'))"
    New-Item -ItemType Directory -Path $moduleValidationRoot -Force | Out-Null
    try {
        [System.IO.Compression.ZipFile]::ExtractToDirectory(
            [string] $modulePackages[0],
            $moduleValidationRoot
        )
    } catch {
        Remove-Item -LiteralPath $moduleValidationRoot -Recurse -Force
        throw
    }
    $moduleRoot = Join-Path $moduleValidationRoot 'PSEventViewer'
}

try {
    if (-not [string]::IsNullOrWhiteSpace($packageRoot)) {
        [array] $expectedPackageNames = @(
            'EventViewerX',
            'EventViewerX.Detection',
            'EventViewerX.Evtx',
            'EventViewerX.Reporting',
            'EventViewerX.Storage'
        )
        foreach ($packageName in $expectedPackageNames) {
            $packagePath = Join-Path $packageRoot "$packageName.$Version.nupkg"
            if (-not (Test-Path -LiteralPath $packagePath -PathType Leaf)) {
                throw "Expected staged package was not found: $packagePath"
            }

            [array] $verificationOutput = & dotnet nuget verify `
                --all `
                --certificate-fingerprint 'D13C03BFEEC0CBF7FD0E0E7FFAF3F3D2076E62B1AF64665E806917B9191CFFDE' `
                $packagePath 2>&1
            if ($LASTEXITCODE -ne 0) {
                $verificationDetails = ($verificationOutput | Out-String).Trim()
                throw "NuGet signature verification failed for $packageName $Version.`n$verificationDetails"
            }
            if (@($verificationOutput | Where-Object {
                [string] $_ -match '^\s*Signature type:\s*Author\s*$'
            }).Count -eq 0) {
                $verificationDetails = ($verificationOutput | Out-String).Trim()
                throw "NuGet author signature evidence was not found for $packageName $Version.`n$verificationDetails"
            }
        }
    }

    $moduleRuntimeSplat = @{}
    if (-not [string]::IsNullOrWhiteSpace($moduleRoot)) {
        $moduleRuntimeSplat.ModulePath = $moduleRoot
    }
    & (Join-Path $PSScriptRoot 'Test-ModuleRuntime.ps1') @moduleRuntimeSplat

    $architectureSplat = @{ RepositoryRoot = $repositoryRoot }
    if (-not [string]::IsNullOrWhiteSpace($packageRoot)) {
        $architectureSplat.PackageRoot = $packageRoot
    }
    if (-not [string]::IsNullOrWhiteSpace($moduleRoot)) {
        $architectureSplat.ModuleRoot = $moduleRoot
    }
    if (-not [string]::IsNullOrWhiteSpace($CliManifestPath)) {
        $architectureSplat.CliManifestPath = $CliManifestPath
    }
    if ($SkipCliArtifacts) {
        $architectureSplat.SkipCliArtifacts = $true
    }
    & (Join-Path $PSScriptRoot 'Test-ReleaseArchitecture.ps1') @architectureSplat
} finally {
    if (-not [string]::IsNullOrWhiteSpace($moduleValidationRoot) -and
        (Test-Path -LiteralPath $moduleValidationRoot)) {
        Remove-Item -LiteralPath $moduleValidationRoot -Recurse -Force
    }
}
