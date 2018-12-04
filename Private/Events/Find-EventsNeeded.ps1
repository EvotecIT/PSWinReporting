function Find-EventsNeeded {
    param (
        [Array] $Events,
        $EventsNeeded,
        [string] $EventsType = 'Security'
    )
    $EventsFound = @()
    foreach ($Event in $Events) {
        if ($Event.LogName -eq $EventsType) {
            if ($EventsNeeded -contains $Event.ID) {
                $EventsFound += $Event
            }
        }
    }
    return $EventsFound
}