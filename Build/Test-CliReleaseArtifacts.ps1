[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidatePattern('^\d+\.\d+\.\d+(?:-[0-9A-Za-z.-]+)?$')]
    [string] $Version,

    [Parameter(Mandatory)]
    [string] $CliManifestPath,

    [string] $StagingRoot,

    [string[]] $StagedAssets,

    [switch] $RequireCliOnly
)

$ErrorActionPreference = 'Stop'
$CliManifestPath = [System.IO.Path]::GetFullPath($CliManifestPath)
if (-not (Test-Path -LiteralPath $CliManifestPath -PathType Leaf)) {
    throw "The CLI release manifest was not found: $CliManifestPath"
}

$cliManifest = Get-Content -LiteralPath $CliManifestPath -Raw | ConvertFrom-Json
$isUnifiedReleaseManifest = $null -ne $cliManifest.PSObject.Properties['assetEntries']
if ($isUnifiedReleaseManifest) {
    [array] $allEntries = @($cliManifest.assetEntries)
    [array] $cliEntries = @($allEntries | Where-Object { $_.category -eq 'Tool' })
} else {
    [array] $allEntries = @($cliManifest)
    [array] $cliEntries = @($allEntries | Where-Object {
        $_.category -eq 'Publish' -and
        $_.target -eq 'EventViewerX.Cli' -and
        -not [string]::IsNullOrWhiteSpace([string] $_.zipPath)
    })
}

if ($cliEntries.Count -ne 12) {
    throw "Expected 12 CLI runtime/style assets, found $($cliEntries.Count)."
}

$expectedRuntimes = @(
    'linux-arm64'
    'linux-x64'
    'osx-arm64'
    'osx-x64'
    'win-arm64'
    'win-x64'
)
$expectedStyles = @('FrameworkDependent', 'PortableCompat')
foreach ($runtime in $expectedRuntimes) {
    foreach ($style in $expectedStyles) {
        [array] $matches = @($cliEntries | Where-Object {
            [string] $_.Runtime -ieq $runtime -and [string] $_.Style -ieq $style
        })
        if ($matches.Count -ne 1) {
            throw "Expected one EventViewerX CLI asset for $runtime/$style, found $($matches.Count)."
        }
    }
}

if ($isUnifiedReleaseManifest) {
    if (@($cliEntries | Where-Object {
        [string] $_.Version -ne $Version -or
        [string] $_.Target -ne 'EventViewerX.Cli'
    }).Count -ne 0) {
        throw 'One or more CLI assets have an unexpected target or release version.'
    }
} elseif (@($cliEntries | Where-Object { $_.sourceDirty -ne $false }).Count -ne 0) {
    throw 'One or more CLI assets do not have clean source provenance.'
}

if ($RequireCliOnly) {
    if (-not $isUnifiedReleaseManifest) {
        throw 'A CLI-only staged release must use the unified PowerForge release manifest.'
    }
    [array] $metadataEntries = @($allEntries | Where-Object { $_.category -eq 'Metadata' })
    [array] $unexpectedEntries = @($allEntries | Where-Object {
        $_.category -notin @('Tool', 'Metadata')
    })
    if ($unexpectedEntries.Count -ne 0) {
        throw 'The CLI-only staged release contains a non-tool payload.'
    }
    if ($metadataEntries.Count -eq 0) {
        throw 'The CLI-only staged release does not contain its build evidence.'
    }
    if ([string]::IsNullOrWhiteSpace($StagingRoot)) {
        throw 'The CLI-only staged release did not provide its staging root.'
    }
    $StagingRoot = [System.IO.Path]::GetFullPath($StagingRoot).TrimEnd('\', '/')
    $stagingPrefix = $StagingRoot + [System.IO.Path]::DirectorySeparatorChar
    [array] $expectedStagedAssets = @($allEntries | ForEach-Object {
        [System.IO.Path]::GetFullPath([string] $_.StagedPath)
    } | Sort-Object -Unique)
    [array] $actualStagedAssets = @($StagedAssets | ForEach-Object {
        [System.IO.Path]::GetFullPath([string] $_)
    } | Sort-Object -Unique)
    if ($expectedStagedAssets.Count -ne $allEntries.Count -or
        $actualStagedAssets.Count -ne $allEntries.Count -or
        ($expectedStagedAssets -join "`n") -cne ($actualStagedAssets -join "`n")) {
        throw 'The CLI-only staged assets do not match the release manifest.'
    }
    foreach ($assetPath in $actualStagedAssets) {
        if (-not (Test-Path -LiteralPath $assetPath -PathType Leaf)) {
            throw "A staged CLI asset was not found: $assetPath"
        }
        if (-not $assetPath.StartsWith(
                $stagingPrefix,
                [System.StringComparison]::OrdinalIgnoreCase
            )) {
            throw "A staged CLI asset is outside the CLI staging root: $assetPath"
        }
    }
}

[pscustomobject] @{
    Version = $Version
    CliAssets = $cliEntries.Count
    EvidenceAssets = if ($RequireCliOnly) { $metadataEntries.Count } else { 0 }
    CliOnly = [bool] $RequireCliOnly
}
