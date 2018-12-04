function Set-ReportFileName {
    param(
        [System.Collections.IDictionary] $ReportOptions,
        [string] $ReportExtension,
        [string] $ReportName = ""
    )
    $ReportTime = $(get-date -f $ReportOptions.FilePatternDateFormat)
    if ($ReportOptions.KeepReportsPath -ne "") { $Path = $ReportOptions.KeepReportsPath} else { $Path = $env:TEMP }
    $ReportPath = $Path + "\" + $ReportOptions.FilePattern
    $ReportPath = $ReportPath -replace "<currentdate>", $ReportTime
    if ($ReportName -ne "") {
        $ReportPath = $ReportPath.Replace(".<extension>", "-$ReportName.$ReportExtension")
    } else {
        $ReportPath = $ReportPath.Replace(".<extension>", ".$ReportExtension")
    }
    return $ReportPath
}