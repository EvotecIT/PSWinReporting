function Set-EmailHead($FormattingOptions) {
    $head = @"
<style>
    BODY {
        background-color: white;
        font-family: $($FormattingOptions.FontFamily);
        font-size: $($FormattingOptions.FontSize);
    }

    TABLE {
        border-width: 1px;
        border-style: solid;
        border-color: black;
        border-collapse: collapse;
        font-family: $($FormattingOptions.FontTableHeadingFamily);
        font-size: $($FormattingOptions.FontTableHeadingSize);
    }

    TH {
        border-width: 1px;
        padding: 3px;
        border-style: solid;
        border-color: black;
        background-color: #00297A;
        color: white;
        font-family: $($FormattingOptions.FontTableHeadingFamily);
        font-size: $($FormattingOptions.FontTableHeadingSize);
    }

    TD {
        border-width: 1px;
        padding-right: 2px;
        padding-left: 2px;
        padding-top: 0px;
        padding-bottom: 0px;
        border-style: solid;
        border-color: black;
        background-color: white;
        font-family: $($FormattingOptions.FontTableDataFamily);
        font-size: $($FormattingOptions.FontTableDataSize);
    }

    H2 {
        font-family: $($FormattingOptions.FontHeadingFamily);
        font-size: $($FormattingOptions.FontHeadingSize);
    }

    P {
        font-family: $($FormattingOptions.FontFamily);
        font-size: $($FormattingOptions.FontSize);
    }
</style>
"@
    return $Head
}

function Set-EmailFormatting ($Template, $FormattingParameters, $ConfigurationParameters) {
    $Body = $Template
    foreach ($style in $FormattingParameters.Styles.GetEnumerator()) {
        foreach ($value in $style.Value) {
            if ($value -eq "") { continue }
            Write-Color @WriteParameters -Text "[i] Preparing template ", "adding", " HTML ", "$($style.Name)", " tag for ", "$value", ' tags...' -Color White, Yellow, White, Yellow, White, Yellow -NoNewLine
            $Body = $Body.Replace($value, "<$($style.Name)>$value</$($style.Name)>")
            Write-Color -Text "Done" -Color "Green"
        }
    }

    foreach ($color in $FormattingParameters.Colors.GetEnumerator()) {
        foreach ($value in $color.Value) {
            if ($value -eq "") { continue }
            Write-Color @WriteParameters -Text "[i] Preparing template ", "adding", " HTML ", "$($color.Name)", " tag for ", "$value", ' tags...' -Color White, Yellow, White, $($color.Name), White, Yellow -NoNewLine
            $Body = $Body.Replace($value, "<span style=color:$($color.Name)>$value</span>")
            Write-Color -Text "Done" -Color "Green"
        }
    }
    foreach ($links in $FormattingParameters.Links.GetEnumerator()) {
        foreach ($link in $links.Value) {
            #write-host $link.Text
            #write-host $link.Link
            if ($link.Link -like "*@*") {
                Write-Color @WriteParameters -Text "[i] Preparing template ", "adding", " EMAIL ", "Links for", " $($links.Key)..." -Color White, Yellow, White, White, Yellow, White -NoNewLine
                $Body = $Body -replace "<<$($links.Key)>>", "<span style=color:$($link.Color)><a href='mailto:$($link.Link)?subject=$($Link.Subject)'>$($Link.Text)</a></span>"
            } else {
                Write-Color @WriteParameters -Text "[i] Preparing template ", "adding", " HTML ", "Links for", " $($links.Key)..." -Color White, Yellow, White, White, Yellow, White -NoNewLine
                $Body = $Body -replace "<<$($links.Key)>>", "<span style=color:$($link.Color)><a href='$($link.Link)'>$($Link.Text)</a></span>"
            }
            Write-Color -Text "Done" -Color "Green"
        }

    }

    if ($ConfigurationParameters.Debug.DisplayTemplateHTML -eq $true) { Get-HTML($Body) }
    return $Body
}
function Set-EmailBody($TableData, $TableWelcomeMessage) {
    $body = "<p><i>$TableWelcomeMessage</i>"
    if ($($TableData | Measure-Object).Count -gt 0) {
        $body += $TableData | ConvertTo-Html -Fragment | Out-String
        $body += "</p>"
    } else {
        $body += "<br><i>No changes happend during that period.</i></p>"
    }
    return $body
}
function Set-EmailBodyPreparedTable ($TableData, $TableWelcomeMessage) {
    $body = "<p><i>$TableWelcomeMessage</i>"
    $body += $TableData
    return $body
}
function Set-EmailReportBrading($FormattingParameters) {
    $Report = "<a style=`"text-decoration:none`" href=`"$($FormattingParameters.CompanyBranding.Link)`" class=`"clink logo-container`">" +
    #"<img width=171 height=15 src=`"$($FormattingParameters.CompanyLogo)`" border=`"0`" class=`"company-logo`" alt=`"company-logo`">" +
    "<img width=<fix> height=<fix> src=`"$($FormattingParameters.CompanyBranding.Logo)`" border=`"0`" class=`"company-logo`" alt=`"company-logo`">" +
    "</a>"
    if ($FormattingParameters.CompanyBranding.Width -ne "") {
        $report = $report -replace "width=<fix>", "width=$($FormattingParameters.CompanyBranding.Width)"
    } else {
        $report = $report -replace "width=<fix>", ""
    }
    if ($FormattingParameters.CompanyBranding.Height -ne "") {
        $report = $report -replace "height=<fix>", "height=$($FormattingParameters.CompanyBranding.Height)"
    } else {
        $report = $report -replace "height=<fix>", ""
    }
    return $Report
}

function Set-EmailReportDetails($FormattingParameters, $Dates, $Warnings) {
    $DateReport = get-date
    # HTML Report settings
    $Report = "<p style=`"background-color:white;font-family:$($FormattingParameters.FontFamily);font-size:$($FormattingParameters.FontSize)`">" +
    "<strong>Report Time:</strong> $($DateReport.ToString()) <br>" +
    "<strong>Report Period:</strong> $($Dates.DateFrom.ToString()) to $($Dates.DateTo.ToString()) <br>" +
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