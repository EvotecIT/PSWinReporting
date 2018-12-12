function Export-ReportToCSV {
    [CmdletBinding()]
    param (
        [bool] $Report,
        [System.Collections.IDictionary] $ReportOptions,
        [string] $Extension,
        [string] $ReportName,
        [System.Collections.IDictionary] $ReportTable
    )
    if ($Report) {
        $ReportFilePath = Set-ReportFileName -ReportOptions $ReportOptions -ReportExtension $Extension -ReportName $ReportName
        if ($ReportTable.Count -gt 0) {
            $ReportTable | Export-Csv -Encoding Unicode -Path $ReportFilePath
        }
        return $ReportFilePath
    } else {
        return ''
    }
}