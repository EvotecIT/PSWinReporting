function Export-ToCSV {
    [CmdletBinding()]
    param (
        [bool] $Report,
        [string] $Path,
        [string] $FilePattern,
        [string] $DateFormat,
        [string] $ReportName,
        [Array] $ReportTable
    )
    if ($Report) {
        $ReportFileName = Set-ReportFile -Path $Path -FileNamePattern $FilePattern -DateFormat $DateFormat -ReportName $ReportName
        try {
            if ($ReportTable.Count -gt 0) {
                $ReportTable | Export-Csv -Encoding Unicode -LiteralPath $ReportFileName -ErrorAction Stop -Force
            }
            return $ReportFileName
        } catch {
            $ErrorMessage = $_.Exception.Message -replace "`n", " " -replace "`r", " "
            $Logger.AddErrorRecord("Error saving file $ReportFileName.")
            $Logger.AddErrorRecord("Error: $ErrorMessage")
            return ''
        }
    } else {
        return ''
    }
}