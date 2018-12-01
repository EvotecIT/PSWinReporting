function Find-EventsIgnored {
    [CmdletBinding()]
    param (
        [Array] $Events,
        $IgnoreWords
    )
    if ((Get-ObjectCount -Object $IgnoreWords) -eq 0) { return $Events }

    $EventsToReturn = foreach ($Event in $Events) {
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
            $Event
        }
    }
    return $EventsToReturn
}
