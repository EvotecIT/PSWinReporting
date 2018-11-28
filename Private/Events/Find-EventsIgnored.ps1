function Find-EventsIgnored($Events, $IgnoreWords = '') {
    if ($IgnoreWords -eq $null) { return $Events }
    $EventsToReturn = @()
    foreach ($Event in $Events) {
        $Found = $false
        foreach ($Ignore in $IgnoreWords.GetEnumerator()) {
            if ($Ignore.Value -ne '') {
                foreach ($Value in $Ignore.Value) {
                    $ColumnName = $Ignore.Name
                    if ($Event.$ColumnName -like $Value) {
                        $Found = $true
                    }
                }
            }
        }
        if ($Found -eq $false) {
            $EventsToReturn += $Event
        }
    }
    return $EventsToReturn
}
