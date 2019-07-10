function Get-EventsOutput {
    [CmdletBinding()]
    param(
        [System.Collections.IDictionary] $Definitions,
        [Array] $AllEvents,
        [switch] $Quiet
    )
    $Results = @{ }

    # Prepare the results based on chosen criteria
    foreach ($Report in  $Definitions.Keys | Where-Object { $_ -notcontains 'Enabled' }) {
        if ($Definitions.$Report.Enabled) {
            #$ReportNameTitle = Format-AddSpaceToSentence -Text $Report -ToLowerCase
            if (-not $Quiet) { $Logger.AddInfoRecord("Running $Report") }
            $TimeExecution = Start-TimeLog
            $Results.$Report = foreach ($SubReport in $Definitions.$Report.Keys | Where-Object { $_ -notcontains 'Enabled', 'SqlExport' }) {
                if ($Definitions.$Report.$SubReport.Enabled) {
                    if (-not $Quiet) { $Logger.AddInfoRecord("Running $Report with subsection $SubReport") }
                    [string] $EventsType = $Definitions.$Report.$SubReport.LogName
                    [Array] $EventsNeeded = $Definitions.$Report.$SubReport.Events
                   # [Array] $EventsFound = Find-EventsNeeded -Events $AllEvents -EventIDs $EventsNeeded -EventsType $EventsType
                    [Array] $EventsFound = Get-EventsTranslation -Events $AllEvents -EventsDefinition $Definitions.$Report.$SubReport -EventIDs $EventsNeeded -EventsType $EventsType
                    if (-not $Quiet) { $Logger.AddInfoRecord("Ending $Report with subsection $SubReport events found $($EventsFound.Count)") }
                    $EventsFound
                }
            }
            $ElapsedTimeReport = Stop-TimeLog -Time $TimeExecution -Option OneLiner
            if (-not $Quiet) { $Logger.AddInfoRecord("Ending $Report - Time to run $ElapsedTimeReport") }
        }
    }
    return $Results
}