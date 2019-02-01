function Remove-ReportsFiles {
    [CmdletBinding()]
    param(
        [bool] $KeepReports,
        [Array] $ReportFiles
    )
    if (-not $KeepReports) {
        foreach ($Report in $ReportFiles) {
            if ($Report -ne '' -and (Test-Path -LiteralPath $Report)) {
                $Logger.AddInfoRecord("Removing file $Report")
                try {
                    Remove-Item -LiteralPath $Report -ErrorAction Stop
                } catch {
                    $Logger.AddErrorRecord("Error removing file: $($_.Exception.Message)")
                }
            }
        }
    }
}