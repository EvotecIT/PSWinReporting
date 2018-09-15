function Remove-ReportsFiles ($KeepReports, $AsExcel, $AsCSV, $ReportFiles) {
    if ($KeepReports -eq $false -and ($AsExcel -eq $true -or $AsCSV -eq $true)) {
        foreach ($report in $ReportFiles) {
            if (Test-Path $report) {
                Write-Color @script:WriteParameters "[i] ", "Removing file ", " $report " -Color White, White, Yellow, White, Red
                try {
                    Remove-Item $report -ErrorAction Stop
                } catch {
                    #Write-Color @Global:WriteParameters "[i] Error reported when removing file ", "$Report", ". File will be skipped..." -Color White, Red, White
                    Write-Color @script:WriteParameters "[i] Error: ", "$($_.Exception.Message)" -Color White, Red
                }
            }
        }
    }
}