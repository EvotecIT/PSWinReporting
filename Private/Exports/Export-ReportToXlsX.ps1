
function Export-ReportToXLSX {
    [CmdletBinding()]
    param(
        [bool] $Report,
        [System.Collections.IDictionary] $ReportOptions,
        [string] $ReportFilePath,
        [string] $ReportName,
        [Array] $ReportTable
    )
    if (($Report -eq $true) -and ($($ReportTable | Measure-Object).Count -gt 0)) {
        $ReportTable | ConvertTo-Excel -Path $ReportFilePath -WorkSheetname $ReportName -AutoSize -FreezeTopRow -AutoFilter
    }
}