function Move-ArchivedLogs {
    [CmdletBinding()]
    param (
        [string] $ServerName,
        [string] $SourcePath,
        [string] $DestinationPath
    )
    $NewSourcePath = "\\$ServerName\$($SourcePath.Replace(':\','$\'))"
    $PathExists = Test-Path -LiteralPath $NewSourcePath
    if ($PathExists) {
        Write-Color @script:WriteParameters '[i] Moving log file from ', $NewSourcePath, ' to ', $DestinationPath -Color White, Yellow, White, Yellow
        Move-Item -Path $NewSourcePath -Destination $DestinationPath
        if (!$?) {
            Write-Color @script:WriteParameters '[i] File ', $NewSourcePath, ' couldn not be moved.' -Color White, Yellow, White
        }
    } else {
        Write-Color @script:WriteParameters '[i] Event Log Move ', $NewSourcePath, ' was skipped. No file exists on drive.' -Color White, Yellow, White, Yellow
    }
}
