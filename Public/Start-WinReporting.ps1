function Start-WinReporting {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)][System.Collections.IDictionary]$Times,
        [Parameter(Mandatory = $true)][alias('ReportOptions')][System.Collections.IDictionary] $Options,
        [Parameter(Mandatory = $true)][alias('ReportDefinitions')][System.Collections.IDictionary] $Definitions,
        [Parameter(Mandatory = $true)][alias('Servers', 'Computers')][System.Collections.IDictionary] $Target
    )
    # Logger Setup
    if ($Options.Logging) {
        $LoggerParameters = $Options.Logging
    } else {
        $LoggerParameters = $Script:LoggerParameters
    }
    $Logger = Get-Logger @LoggerParameters
    # Test Configuration
    #TODO


    # Test Modules
    #TODO

    # Run report
    $Dates = Get-ChoosenDates -ReportTimes $Times
    foreach ($Date in $Dates) {
        $Logger.AddInfoRecord("Starting to build a report for dates $($Date.DateFrom) to $($Date.DateTo)")
        Start-ReportSpecial `
            -Dates $Date `
            -Options $Options `
            -Definitions $Definitions `
            -Target $Target
    }
}