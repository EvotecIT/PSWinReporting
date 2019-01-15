function Find-EventsTo {
    [CmdletBinding()]
    param (
        [Array] $Events,
        [alias('IgnoreWords', 'PriorityWords')] $DataSet,
        [switch] $Ignore,
        [switch] $Prioritize
    )
    if ((Get-ObjectCount -Object $DataSet) -eq 0) { return $Events }

    $EventsToReturn = foreach ($Event in $Events) {
        $Found = $false
        foreach ($Set in $DataSet.GetEnumerator()) {
            if ($Set.Value -ne '') {
                foreach ($Value in $Set.Value) {
                    $ColumnName = $Set.Name
                    if ($Event.$ColumnName -like $Value) {
                        $Found = $true
                    }
                }
            }
        }
        if ($Ignore) {
            if (-not $Found) {
                $Event
            }
        }
        if ($Prioritize) {
            if ($Found) {
                $Event
            }
        }
    }
    return $EventsToReturn
}
