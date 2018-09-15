
function Export-ReportToXLSX ($Report, $ReportOptions, $ReportFilePath, $ReportName, $ReportTable) {
    if (($Report -eq $true) -and ($($ReportTable | Measure-Object).Count -gt 0)) {
        $ReportTable | ConvertTo-Excel -Path $ReportFilePath -WorkSheetname $ReportName -AutoSize -FreezeTopRow -AutoFilter
        return
    } else {
        return
    }
}