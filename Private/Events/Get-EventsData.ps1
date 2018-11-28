function Get-EventsData {
    [CmdletBinding()]
    param (
        $ReportDefinitions,
        $LogName
    )
    return Find-AllEvents -ReportDefinitions $ReportDefinitions -LogNameSearch $LogName | Sort-Object
}