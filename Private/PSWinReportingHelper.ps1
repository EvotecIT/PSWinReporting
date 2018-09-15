function Find-EventsIgnored($Events, $IgnoreWords = '') {
    if ($IgnoreWords -eq $null) { return $Events }
    $EventsToReturn = @()
    foreach ($Event in $Events) {
        $Found = $false
        foreach ($Ignore in $IgnoreWords.GetEnumerator()) {
            if ($Ignore.Value -ne '') {
                foreach ($Value in $Ignore.Value) {
                    $ColumnName = $Ignore.Name
                    if ($Event.$ColumnName -like $Value) {
                        $Found = $true
                    }
                }
            }
        }
        if ($Found -eq $false) {
            $EventsToReturn += $Event
        }
    }
    return $EventsToReturn
}
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
function Export-ReportToXLSX ($Report, $ReportOptions, $ReportFilePath, $ReportName, $ReportTable) {
    if (($Report -eq $true) -and ($($ReportTable | Measure-Object).Count -gt 0)) {
        $ReportTable | ConvertTo-Excel -Path $ReportFilePath -WorkSheetname $ReportName -AutoSize -FreezeTopRow -AutoFilter
        return
    } else {
        return
    }
}
function Export-ReportToCSV ($Report, $ReportOptions, $Extension, $ReportName, $ReportTable) {
    if ($Report -eq $true) {
        $ReportFilePath = Set-ReportFileName -ReportOptions $ReportOptions -ReportExtension $Extension -ReportName $ReportName
        $ReportTable | Export-Csv -Encoding Unicode -Path $ReportFilePath
        return $ReportFilePath
    } else {
        return ""
    }
}
