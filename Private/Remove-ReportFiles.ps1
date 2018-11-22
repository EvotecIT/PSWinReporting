function Remove-ReportsFiles ($KeepReports, $AsExcel, $AsCSV, $ReportFiles) {
    if (-not $KeepReports -and ($AsExcel -or $AsCSV)) {
        foreach ($Report in $ReportFiles) {
            if (Test-Path $report) {
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