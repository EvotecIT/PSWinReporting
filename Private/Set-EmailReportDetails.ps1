function Set-EmailReportDetails($FormattingParameters, $Dates, $Warnings) {
    $DateReport = get-date
    # HTML Report settings
    $Report = "<p style=`"background-color:white;font-family:$($FormattingParameters.FontFamily);font-size:$($FormattingParameters.FontSize)`">" +
    "<strong>Report Time:</strong> $DateReport <br>" +
    "<strong>Report Period:</strong> $($Dates.DateFrom) to $($Dates.DateTo) <br>" +
    "<strong>Account Executing Report :</strong> $env:userdomain\$($env:username.toupper()) on $($env:ComputerName.toUpper()) <br>" +
    "<strong>Time to generate:</strong> **TimeToGenerateDays** days, **TimeToGenerateHours** hours, **TimeToGenerateMinutes** minutes, **TimeToGenerateSeconds** seconds, **TimeToGenerateMilliseconds** milliseconds"

    if ($($Warnings | Measure-Object).Count -gt 0) {
        $Report += "<br><br><strong>Warnings:</strong>"
        foreach ($warning in $Warnings) {
            $Report += "<br> $warning"
        }
    }
    $Report += "</p>"
    return $Report
}