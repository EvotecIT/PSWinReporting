function Export-ReportToCSV {
    param (
        $Report,
        $ReportOptions,
        $Extension,
        $ReportName,
        $ReportTable
    )
    if ($Report -eq $true) {
        $ReportFilePath = Set-ReportFileName -ReportOptions $ReportOptions -ReportExtension $Extension -ReportName $ReportName
        if ($ReportTable.Count -gt 0) {
            $ReportTable | Export-Csv -Encoding Unicode -Path $ReportFilePath
        }
        return $ReportFilePath
    } else {
        return ""
    }
}