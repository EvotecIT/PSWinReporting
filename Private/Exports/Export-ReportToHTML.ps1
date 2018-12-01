function Export-ReportToHTML {
    param (
        $Report,
        $ReportTable,
        $ReportTableText,
        [switch] $Special
    )
    if ($Report -eq $true) {
        if ($special) {
            return Set-EmailBodyPreparedTable -TableData $ReportTable -TableWelcomeMessage $ReportTableText
        }
        return Set-Emailbody -TableData $ReportTable -TableWelcomeMessage $ReportTableText
    } else {
        return ''
    }
}