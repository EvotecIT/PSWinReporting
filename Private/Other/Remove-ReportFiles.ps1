function Remove-ReportsFiles {
    [CmdletBinding()]
    param(
        [bool] $KeepReports,
        [Array] $ReportFiles
    )
    if (-not $KeepReports) {
        foreach ($Report in $ReportFiles) {
            if (Test-Path $Report) {
                $Logger.AddRecord("Removing file $Report")
                try {
                    Remove-Item $Report
                } catch {
                    $Logger.AddErrorRecord("Error removing file: $($_.Exception.Message)")
                    continue
                }
            }
        }
    }
}