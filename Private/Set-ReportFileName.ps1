function Set-ReportFileName($ReportOptions, $ReportExtension, $ReportName = "") {
    $ReportTime = $(get-date -f $ReportOptions.FilePatternDateFormat)
    if ($ReportOptions.KeepReportsPath -ne "" -and (Test-Path -LiteralPath $ReportOptions.KeepReportsPath)) {
        $Path = $ReportOptions.KeepReportsPath
    } else { 
        $Path = $env:TEMP 
    }
    $ReportPath = $Path + "\" + $ReportOptions.FilePattern
    $ReportPath = $ReportPath -replace "<currentdate>", $ReportTime
    if ($ReportName -ne "") {
        $ReportPath = $ReportPath.Replace(".<extension>", "-$ReportName.$ReportExtension")
    } else {
        $ReportPath = $ReportPath.Replace(".<extension>", ".$ReportExtension")
    }
    return $ReportPath
}