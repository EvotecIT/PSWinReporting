function Set-EmailHead($FormattingOptions) {
    $Head = "<style>" +
    "BODY{background-color:white;font-family:$($FormattingOptions.FontFamily);font-size:$($FormattingOptions.FontSize)}" +
    "TABLE{border-width: 1px;border-style: solid;border-color: black;border-collapse: collapse}" +
    "TH{border-width: 1px;padding: 3px;border-style: solid;border-color: black;background-color:`"#00297A`";font-color:white}" +
    "TD{border-width: 1px;padding-right: 2px;padding-left: 2px;padding-top: 0px;padding-bottom: 0px;border-style: solid;border-color: black;background-color:white}" +
    "H2{font-family:$($FormattingOptions.FontHeadingFamily);font-size:$($FormattingOptions.FontHeadingSize)}" +
    "P{font-family:$($FormattingOptions.FontFamily);font-size:$($FormattingOptions.FontSize)}" +
    "</style>"
    return $Head
}
function Set-EmailBody($TableData, $TableWelcomeMessage) {
    $body = "<p><i>$TableWelcomeMessage</i>"
    if ($($TableData | Measure-Object).Count -gt 0) {
        $body += $TableData | ConvertTo-Html -Fragment | Out-String
        $body = $body -replace " Added", "<font color=`"green`"><b> Added</b></font>"
        $body = $body -replace " Removed", "<font color=`"red`"><b> Removed</b></font>"
        $body = $body -replace " Deleted", "<font color=`"red`"><b> Deleted</b></font>"
        $body = $body -replace " Changed", "<font color=`"blue`"><b> Changed</b></font>"
        $body = $body -replace " Change", "<font color=`"blue`"><b> Change</b></font>"
        $body = $body -replace " Disabled", "<font color=`"red`"><b> Disabled</b></font>"
        $body = $body -replace " Enabled", "<font color=`"green`"><b> Enabled</b></font>"
        $body = $body -replace " Locked out", "<font color=`"red`"><b> Locked out</b></font>"
        $body = $body -replace " Lockouts", "<font color=`"red`"><b> Lockouts</b></font>"
        $body = $body -replace " Unlocked", "<font color=`"green`"><b> Unlocked</b></font>"
        $body = $body -replace " Reset", "<font color=`"blue`"><b> Reset</b></font>"
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
function Set-EmailReportBrading($FormattingOptions) {
    $Report = "<a style=`"text-decoration:none`" href=`"$($FormattingOptions.CompanyBranding.Link)`" class=`"clink logo-container`">" +
    #"<img width=171 height=15 src=`"$($FormattingOptions.CompanyLogo)`" border=`"0`" class=`"company-logo`" alt=`"company-logo`">" +
    "<img width=<fix> height=<fix> src=`"$($FormattingOptions.CompanyBranding.Logo)`" border=`"0`" class=`"company-logo`" alt=`"company-logo`">" +
    "</a>"
    if ($FormattingOptions.CompanyBranding.Width -ne "") {
        $report = $report -replace "width=<fix>", "width=$($FormattingOptions.CompanyBranding.Width)"
    } else {
        $report = $report -replace "width=<fix>", ""
    }
    if ($FormattingOptions.CompanyBranding.Height -ne "") {
        $report = $report -replace "height=<fix>", "height=$($FormattingOptions.CompanyBranding.Height)"
    } else {
        $report = $report -replace "height=<fix>", ""
    }
    return $Report
}
function Set-EmailReportDetails($FormattingOptions, $Dates) {
    $DateReport = get-date
    # HTML Report settings
    $Report = "<p style=`"background-color:white;font-family:$($FormattingOptions.FontFamily);font-size:$($FormattingOptions.FontSize)`">" +
    "<strong>Report Time:</strong> $DateReport <br>" +
    "<strong>Report Period:</strong> $($Dates.DateFrom) to $($Dates.DateTo) <br>" +
    "<strong>Account Executing Report :</strong> $env:userdomain\$($env:username.toupper()) on $($env:ComputerName.toUpper()) <br>" +
    "<strong>Time to generate:</strong> **TimeToGenerateDays** days, **TimeToGenerateHours** hours, **TimeToGenerateMinutes** minutes, **TimeToGenerateSeconds** seconds, **TimeToGenerateMilliseconds** milliseconds"
    "</p>"
    return $Report
}
function Set-EmailWordReplacements($Body, $Replace, $ReplaceWith, [switch] $RegEx) {
    if ($RegEx) {
        $Body = $Body -Replace $Replace, $ReplaceWith
    } else {
        $Body = $Body.Replace($Replace, $ReplaceWith)
    }
    return $Body
}

function Send-Email ([hashtable] $EmailParameters, [string] $Body = "", $Attachment = $null, [string] $Subject = "", $To = "") {
    #     $SendMail = Send-Email -EmailParameters $EmailParameters -Body $EmailBody -Attachment $Reports -Subject $TemporarySubject
    #  Preparing the Email properties
    $SmtpClient = New-Object -TypeName system.net.mail.smtpClient
    $SmtpClient.host = $EmailParameters.EmailServer

    # Adding parameters to login to server
    $SmtpClient.Port = $EmailParameters.EmailServerPort
    if ($EmailParameters.EmailServerLogin -ne "") {
        $SmtpClient.Credentials = New-Object System.Net.NetworkCredential($EmailParameters.EmailServerLogin, $EmailParameters.EmailServerPassword)
    }
    $SmtpClient.EnableSsl = $EmailParameters.EmailServerEnableSSL
    $MailMessage = New-Object -TypeName system.net.mail.mailmessage
    $MailMessage.From = $EmailParameters.EmailFrom
    if ($To -ne "") {
        foreach ($T in $To) { $MailMessage.To.add($($T)) }
    } else {
        if ($EmailParameters.Emailto -ne "") {
            foreach ($To in $EmailParameters.Emailto) { $MailMessage.To.add($($To)) }
        }
    }
    if ($EmailParameters.EmailCC -ne "") {
        foreach ($CC in $EmailParameters.EmailCC) { $MailMessage.CC.add($($CC)) }
    }
    if ($EmailParameters.EmailBCC -ne "") {
        foreach ($BCC in $EmailParameters.EmailBCC) { $MailMessage.BCC.add($($BCC)) }
    }
    $Exists = Test-Key $EmailParameters "EmailParameters" "EmailReplyTo" -DisplayProgress $false
    if ($Exists -eq $true) {
        if ($EmailParameters.EmailReplyTo -ne "") {
            $MailMessage.ReplyTo = $EmailParameters.EmailReplyTo
        }
    }
    $MailMessage.IsBodyHtml = 1
    if ($Subject -eq "") {
        $MailMessage.Subject = $EmailParameters.EmailSubject
    } else {
        $MailMessage.Subject = $Subject
    }
    $MailMessage.Body = $Body
    $MailMessage.Priority = [System.Net.Mail.MailPriority]::$($EmailParameters.EmailPriority)

    #  Encoding
    $MailMessage.BodyEncoding = [System.Text.Encoding]::$($EmailParameters.EmailEncoding)
    $MailMessage.SubjectEncoding = [System.Text.Encoding]::$($EmailParameters.EmailEncoding)

    #  Attaching file (s)
    if ($Attachment -ne $null) {
        foreach ($Attach in $Attachment) {
            if (Test-Path $Attach) {
                $File = new-object Net.Mail.Attachment($Attach)
                $MailMessage.Attachments.Add($File)
            }
        }
    }

    #  Sending the Email
    try {
        $SmtpClient.Send($MailMessage)
        #$att.Dispose();
        $MailMessage.Dispose();
        return @{
            Status = $True
            Error  = ""
        }
    } catch {
        $MailMessage.Dispose();
        return @{
            Status = $False
            Error  = $($_.Exception.Message)
        }
    }
}
function Get-HTML($text) {
    $text = $text.Split("`r")
    foreach ($t in $text) {
        Write-Host $t
    }
}