function New-SubscriptionTemplates {
    [CmdletBinding()]
    param (
        [alias('ReportDefinitions')][System.Collections.IDictionary] $Definitions,
        [alias('Servers', 'Computers')][System.Collections.IDictionary] $Target,
        [System.Collections.IDictionary] $LoggerParameters
    )
    if (-not $LoggerParameters) {
        $LoggerParameters = $Script:LoggerParameters
    }
    $Logger = Get-Logger @LoggerParameters


    [Array] $ExtendedInput = Get-ServersList -Definitions $Definitions -Target $Target
    foreach ($Entry in $ExtendedInput) {
        if ($Entry.Type -eq 'Computer') {
            $Logger.AddInfoRecord("Computer $($Entry.Server) added to scan $($Entry.LogName) log for events: $($Entry.EventID -join ', ')")
        } else {
            $Logger.AddInfoRecord("File $($Entry.Server) added to scan $($Entry.LogName) log for events: $($Entry.EventID -join ', ')")
        }
    }

    return $ExtendedInput

    return



    $Events = Get-EventsData -ReportDefinitions $Definitions -LogName 'Security'
    $Systems = Get-EventsData -ReportDefinitions $Definitions -LogName 'System'

    $Logger.AddInfoRecord("Found Security Events $($Events -join ', ')")
    $Logger.AddInfoRecord("Found System Events $($Systems -join ', ')")

    $ServersAD = Get-DC
    $Servers = Find-ServersAD -ReportDefinitions $Definitions -DC $ServersAD
    #Write-Color 'Found Servers ', ([string] $Servers) -Color White, Yellow
    $Logger.AddInfoRecord("Found Servers $($Servers -join ', ')")
    # $xmlTemplate = "$($($(Get-Module -ListAvailable PSWinReporting)[0]).ModuleBase)\Templates\Template-Collector.xml"
    $XmlTemplate = "$((get-item $PSScriptRoot).Parent.FullName)\Templates\Template-Collector.xml"
    if (Test-Path $xmlTemplate) {
        $Logger.AddInfoRecord("Found Template $xmlTemplate")
        #Write-Color 'Found Template ', $xmlTemplate -Color White, Yellow
        $ListTemplates = New-ArrayList
        if (Test-Path $xmlTemplate) {
            $Array = New-ArrayList
            $SplitArrayID = Split-Array -inArray $Events -size 22  # Support for more ID's then 22 (limitation of Get-WinEvent)
            foreach ($ID in $SplitArrayID) {
                $Query = New-EventQuery -Events $ID -Type 'Security' #-Verbose
                Add-ToArray -List $Array -Element $Query
            }
            $SplitArrayID = Split-Array -inArray $Systems -size 22  # Support for more ID's then 22 (limitation of Get-WinEvent)
            foreach ($ID in $SplitArrayID) {
                $Query = New-EventQuery -Events $ID -Type 'System' #-Verbose
                Add-ToArray -List $Array -Element $Query
            }
            $i = 0
            foreach ($Events in $Array) {
                $i++
                $SubscriptionTemplate = "$ENV:TEMP\PSWinReportingSubscription$i.xml"
                Copy-Item -Path $xmlTemplate $SubscriptionTemplate
                $Logger.AddInfoRecord("Copied template $SubscriptionTemplate")
                #Write-Color 'Copied template ', $SubscriptionTemplate -Color White, Yellow
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
        $Logger.AddInfoRecord("Template not found $xmlTemplate")
        #Write-Color 'Template not found ', $xmlTemplate -Color White, Yellow
    }
    return $ListTemplates
}