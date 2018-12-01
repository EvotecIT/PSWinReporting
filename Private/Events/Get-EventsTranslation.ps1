function Get-EventsTranslation {
    [CmdletBinding()]
    param(
        [Array] $Events,
        [System.Collections.IDictionary] $EventsDefinition  # HashTable/OrderedDictionary
    )
    $MyValue = foreach ($Event in $Events) {
        $IgnoredFound = $false
        $HashTable = @{}
        foreach ($EventProperty in $Event.PSObject.Properties) {

            # $EventProperty.Name is value on the left side
            # $Fields[$EventProperty.Name] is value on the right side
            # $EventProperty.Value is actual value of field

            # Check if defined field invalidates whole Event
            if ($null -ne $EventsDefinition.Ignore) {
                if ($EventsDefinition.Ignore.Contains($EventProperty.Name)) {
                    if ($EventProperty.Value -like $EventsDefinition.Ignore[$EventProperty.Name]) {
                        continue
                    }
                }
            }
            # Check if field requires functions
            if ($null -ne $EventsDefinition.Functions) {
                if ($EventsDefinition.Functions.Contains($EventProperty.Name)) {
                    if ($EventsDefinition.Functions[$EventProperty.name] -contains 'Remove-WhiteSpace') {
                        $EventProperty.Value = Remove-WhiteSpace -Text $EventProperty.Value
                    }
                    if ($EventsDefinition.Functions[$EventProperty.name] -contains 'SplitOnSpace') {
                        $EventProperty.Value = $EventProperty.Value -Split ' '
                    }
                    if ($EventsDefinition.Functions[$EventProperty.name] -contains 'Convert-UAC') {
                        $EventProperty.Value = Convert-UAC -UAC $EventProperty.Value -Separator ', '
                    }
                }
            }
            if ($EventsDefinition.Fields.Contains($EventProperty.Name)) {
                # Replaces Field with new Field according to schema
                $HashTable[$EventsDefinition.Fields[$EventProperty.Name]] = $EventProperty.Value
            } else {
                # This is your standard event field, we won't be using it for display most of the time
                # May need to be totally ignored if not needed. To be decided
                # Assign value - Finally (untouched one)
                $HashTable[$EventProperty.Name] = $EventProperty.Value
            }
        }
<#
        if ($null -ne $EventsDefinition.Overwrite) {
            if ($EventsDefinition.Overwrite.Contains($EventProperty.Name)) {
                Write-Color 'Test2' -Color Red
                $TemporaryValue = ($EventsDefinition.Overwrite[$EventProperty.Name])
                if ($TemporaryValue.Count -eq 3) {
                    Write-Color 'Test3' -Color Red
                    if ($TemporaryValue[0] -eq $EventsDefinition.Fields[$EventProperty.Name]) {
                        if ($TemporaryValue[1] -eq $EventProperty[$TemporaryValue[1]].Value) {
                            Write-Color $EventProperty[$TemporaryValue[1]].Value -Color Yellow
                        }
                    }

                }
            } else {
                Write-Color 'Test2 - eh', $EventProperty.Name -Color Green
            }
        }
#>
        [PsCustomObject]$HashTable

    }
    return $MyValue | Select-Object @($EventsDefinition.Fields.Values)
}