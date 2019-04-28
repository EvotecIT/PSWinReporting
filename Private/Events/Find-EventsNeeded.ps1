function Find-EventsNeeded {
    [CmdletBinding()]
    param (
        [Array] $Events,
        [alias('EventsNeeded')][Array] $EventIDs,
        [string] $EventsType = 'Security'
    )
    $EventsFound = foreach ($Event in $Events) {
        if ($Event.LogName -eq $EventsType) {
            if ($EventIDs -contains $Event.ID) {
                $Event
            }
        }
    }
    return $EventsFound
}