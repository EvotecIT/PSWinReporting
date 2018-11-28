function Get-EventsTranslation {
    [CmdletBinding()]
    param(
        [Array] $Events,
        [System.Collections.IDictionary] $Fields
    )
    $MyValue = foreach ($Object in $Events) {
        $HashTable = @{}
        foreach ($Property in $Object.PSObject.Properties) {
            if ($Fields.Contains($Property.Name)) {
                $HashTable[$Fields[$Property.name]] = $Property.Value
            } else {
                $HashTable[$Property.Name] = $Property.Value
            }
        }
        [PsCustomObject]$HashTable
    }
    return $MyValue | Select-Object @($Fields.Values)
}