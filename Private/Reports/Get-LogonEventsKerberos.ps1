function Get-LogonEventsKerberos {
    param(
        [Array] $Events,
        $IgnoreWords = ''
    )
    $EventsType = $Script:ReportDefinitions.ReportsAD.EventBased.UserLogonKerberos.LogName
    $EventsNeeded = $Script:ReportDefinitions.ReportsAD.EventBased.UserLogonKerberos.Events
    $EventsFound = Find-EventsNeeded -Events $Events -EventsNeeded $EventsNeeded -EventsType $EventsType
    $EventsFound = Get-EventsTranslation -Events $EventsFound -EventsDefinition $Script:ReportDefinitions.ReportsAD.EventBased.UserLogonKerberos
    return Find-EventsIgnored -Events $EventsFound -IgnoreWords $IgnoreWords | Sort-Object $Script:ReportDefinitions.ReportsAD.EventBased.UserLogonKerberos.SortBy

    <#
    $EventsType = 'Security'
    $EventsNeeded = 4768
    $EventsFound = Find-EventsNeeded -Events $Events -EventsNeeded $EventsNeeded -EventsType $EventsType
    $EventsFound = $EventsFound | Select-Object @{label = 'Domain Controller'; expression = { $_.Computer}} ,
    @{label = 'Action'; expression = { (($_.Message -split '\n')[0]).Trim() }},
    @{label = 'Computer/User Affected'; expression = { "$($_.TargetDomainName)\$($_.TargetUserName)" }},
    @{label = 'IpAddress'; expression = { if ($_.IpAddress -match "::1" ) { "localhost" }   else {     $_.IpAddress       }     }},
    @{label = 'Port'; expression = { $_.IpPort }},


    @{label = 'TicketOptions'; expression = { $_.TicketOptions }},
    @{label = 'Status'; expression = { $_.Status }},
    @{label = 'TicketEncryptionType'; expression = { $_.TicketEncryptionType }},
    @{label = 'PreAuthType'; expression = { $_.PreAuthType }},

    @{label = 'When'; expression = { $_.Date }},
    @{label = 'Event ID'; expression = { $_.ID }},
    @{label = 'Record ID'; expression = { $_.RecordId }},
    @{label = 'Gathered From'; expression = { $_.GatheredFrom }},
    @{label = 'Gathered LogName'; expression = { $_.GatheredLogName }} | Sort-Object When
    $EventsFound = Find-EventsIgnored -Events $EventsFound -IgnoreWords $IgnoreWords
    return $EventsFound
    #>
}