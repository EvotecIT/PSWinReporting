function Get-EventsData {
    [CmdletBinding()]
    param (
        [System.Collections.IDictionary] $ReportDefinitions,
        [string] $LogName
    )
    return Find-AllEvents -ReportDefinitions $ReportDefinitions -LogNameSearch $LogName | Sort-Object
}