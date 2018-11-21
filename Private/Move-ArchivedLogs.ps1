function Move-ArchivedLogs {
    [CmdletBinding()]
    param (
        [string] $ServerName,
        [string] $SourcePath,
        [string] $DestinationPath
    )
    $NewSourcePath = "\\$ServerName\$($SourcePath.Replace(':\','$\'))"
    if (Test-Path $NewSourcePath) {
        $Logger.AddRecord("Moving log file from $NewSourcePath to $DestinationPath")
        try {
            Move-Item -Path $NewSourcePath -Destination $DestinationPath
        } catch {
            $Logger.AddErrorRecord("File $NewSourcePath couldn not be moved: $($_.Exception.Message)")
        }
    } else {
        $Logger.AddRecord("Event Log Move $NewSourcePath was skipped. No file exists on drive")
    }
}
