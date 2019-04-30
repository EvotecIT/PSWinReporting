function Get-DatesDefinitions {
    [CmdletBinding()]
    param(
        [string[]] $Skip
    )
    $Times = foreach ($Key in $Script:ReportTimes.Keys) {
        if ($SkipTime -notcontains $Key) {
            $Key
        }
    }
    $Times
}