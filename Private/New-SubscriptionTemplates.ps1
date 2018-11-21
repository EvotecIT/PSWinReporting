function New-SubscriptionTemplates {
    [CmdletBinding()]
    param (
        $ReportDefinitions
    )
    $Events = Get-EventsData -ReportDefinitions $ReportDefinitions -LogName 'Security'
    $Logger.AddRecord("Found Security Events: $([string] $Events)")
    $Systems = Get-EventsData -ReportDefinitions $ReportDefinitions -LogName 'System'
    $Logger.AddRecord("Found System Events: $([string] $Systems)")

    $ServersAD = Get-DC
    $Servers = Find-ServersAD -ReportDefinitions $ReportDefinitions -DC $ServersAD
    $Logger.AddRecord("Found Servers: $([string] $Servers)")
    $XmlTemplate = Join-Path (Get-Item $PSScriptRoot).Parent.FullName 'Templates\Template-Collector.xml'
    if (Test-Path $XmlTemplate) {
        $Logger.AddRecord("Found Template $XmlTemplate")
        $ListTemplates = New-ArrayList
        if (Test-Path $XmlTemplate) {
            $Array = New-ArrayList
            $SplitArrayID = Split-Array -inArray $Events -size 22  # Support for more ID's then 22 (limitation of Get-WinEvent)
            foreach ($ID in $SplitArrayID) {
                $Query = New-EventQuery -Events $ID -Type 'Security' -Verbose
                Add-ToArray -List $Array -Element $Query
            }
            $SplitArrayID = Split-Array -inArray $Systems -size 22  # Support for more ID's then 22 (limitation of Get-WinEvent)
            foreach ($ID in $SplitArrayID) {
                $Query = New-EventQuery -Events $ID -Type 'System' -Verbose
                Add-ToArray -List $Array -Element $Query
            }
            $i = 0
            foreach ($Events in $Array) {
                $i++
                $SubscriptionTemplate = "$ENV:TEMP\PSWinReportingSubscription$i.xml"
                Copy-Item -Path $XmlTemplate $SubscriptionTemplate
                $Logger.AddRecord("Copied Template $SubscriptionTemplate")
                Add-ServersToXML -FilePath $SubscriptionTemplate -Servers $Servers

                Set-XML -FilePath $SubscriptionTemplate -Path 'Subscription' -Node 'SubscriptionId' -Value "PSWinReporting Subscription Events - $i"
                Set-XML -FilePath $SubscriptionTemplate -Path 'Subscription' -Node 'ContentFormat' -Value 'Events'
                Set-XML -FilePath $SubscriptionTemplate -Path 'Subscription' -Node 'ConfigurationMode' -Value 'Custom'
                #$Events
                Set-XML -FilePath $SubscriptionTemplate -Path 'Subscription' -Node 'Query' -Value $Events
                Add-ToArray -List $ListTemplates -Element $SubscriptionTemplate
            }

        }
    } else {
        $Logger.AddRecord("Template not found $XmlTemplate")
    }
    return $ListTemplates
}