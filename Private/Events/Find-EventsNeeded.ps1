function Find-EventsNeeded {
    param (
        [Array] $Events,
        [Array] $EventsNeeded,
        [string] $EventsType = 'Security'
    )
    $EventsFound = foreach ($Event in $Events) {
        if ($Event.LogName -eq $EventsType) {
            if ($EventsNeeded -contains $Event.ID) {
                $Event
            }
        }
    }
    return $EventsFound
}