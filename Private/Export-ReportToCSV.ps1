function Export-ReportToCSV ($Report, $ReportOptions, $Extension, $ReportName, $ReportTable) {
    if ($Report -eq $true) {
        $ReportFilePath = Set-ReportFileName -ReportOptions $ReportOptions -ReportExtension $Extension -ReportName $ReportName
        $ReportTable | Export-Csv -Encoding Unicode -Path $ReportFilePath
        return $ReportFilePath
    } else {
        return ""
    }
}