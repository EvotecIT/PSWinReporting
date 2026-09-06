[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

& (Join-Path $PSScriptRoot 'Test-ReleaseReady.ps1') -SkipCliArtifacts
