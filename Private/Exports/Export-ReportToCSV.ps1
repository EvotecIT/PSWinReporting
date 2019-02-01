function Export-ReportToCSV {
    [CmdletBinding()]
    param (
        [bool] $Report,
        [System.Collections.IDictionary] $ReportOptions,
        [string] $Extension,
        [string] $ReportName,
        [Array] $ReportTable
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