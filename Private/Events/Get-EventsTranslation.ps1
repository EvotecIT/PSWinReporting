function Get-EventsTranslation {
    [CmdletBinding()]
    param(
        [Array] $Events,
        [System.Collections.IDictionary] $EventsDefinition  # HashTable/OrderedDictionary
    )
    if ($EventsDefinition.Filter) {
        # Filter is special, if there is just one object on the right side
        # If there are more objects filter will pick all values on the right side and display them as required
        #Filter = @{
        #    'ObjectClass' = 'groupPolicyContainer'
        #    'AttributeLDAPDisplayName' = 'cn','displayName'
        #}

        foreach ($Filter in $EventsDefinition.Filter.Keys) {
            $Value = $EventsDefinition.Filter[$Filter]
            $Events = foreach ($V in $Value) {
                $Events | Where-Object { $_.$Filter -eq $V }
            }
        }
    }
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
                    if ($EventsDefinition.Functions[$EventProperty.Name] -contains 'Remove-WhiteSpace') {
                        $EventProperty.Value = Remove-WhiteSpace -Text $EventProperty.Value
                    }
                    if ($EventsDefinition.Functions[$EventProperty.Name] -contains 'Split-OnSpace') {
                        $EventProperty.Value = $EventProperty.Value -Split ' '
                    }
                    if ($EventsDefinition.Functions[$EventProperty.Name] -contains 'Convert-UAC') {
                        $EventProperty.Value = Convert-UAC -UAC $EventProperty.Value -Separator ', '
                    }
                    if ($EventsDefinition.Functions[$EventProperty.Name] -contains 'ConvertFrom-OperationType') {
                        $EventProperty.Value = ConvertFrom-OperationType -OperationType $EventProperty.Value
                    }
                    if ($EventsDefinition.Functions[$EventProperty.Name] -contains 'Clean-IpAddress') {
                        $EventProperty.Value = if ($EventProperty.Value -match "::1") { 'localhost' } else { $EventProperty.Value }
                    }
                }
            }

            if ($null -ne $EventsDefinition.Fields -and $EventsDefinition.Fields.Contains($EventProperty.Name)) {
                # Replaces Field with new Field according to schema
                $HashTable[$EventsDefinition.Fields[$EventProperty.Name]] = $EventProperty.Value
            } else {
                # This is your standard event field, we won't be using it for display most of the time
                # May need to be totally ignored if not needed. To be decided
                # Assign value - Finally (untouched one)
                $HashTable[$EventProperty.Name] = $EventProperty.Value
            }
        }
        # This overwrites values based on parameters. It's useful for cleanup or special cases.
        if ($null -ne $EventsDefinition.Overwrite) {
            foreach ($Entry in $EventsDefinition.Overwrite.Keys) {
                $OverwriteObject = $EventsDefinition.Overwrite.$Entry
                # This allows for having multiple values in Overwrite by using additional empty spaces in definition
                $StrippedEntry = Remove-WhiteSpace -Text $Entry
                if ($OverwriteObject.Count -eq 3) {
                    #Write-Color $Entry, ' - ',  $HashTable[$Entry], ' - ', $HashTable.$Entry, ' - ', $HashTable.($OverwriteObject[0]) -Color Red
                    #Write-Color $OverwriteObject[0], ' - ', $OverwriteObject[1], ' - ', $OverwriteObject[2] -Color Yellow
                    if ($HashTable.($OverwriteObject[0]) -eq $OverwriteObject[1]) {
                        $HashTable.$StrippedEntry = $OverwriteObject[2]
                    }
                } elseif ($OverwriteObject.Count -eq 4) {
                    if ($HashTable.($OverwriteObject[0]) -eq $OverwriteObject[1]) {
                        $HashTable.$StrippedEntry = $OverwriteObject[2]
                    } else {
                        $HashTable.$StrippedEntry = $OverwriteObject[3]
                    }
                }
            }
        }
        [PsCustomObject]$HashTable
    }
    $MyValue = Find-EventsTo -Ignore -Events $MyValue -DataSet $EventsDefinition.IgnoreWords

    if ($null -eq $EventsDefinition.Fields) {
        return $MyValue | Sort-Object $EventsDefinition.SortBy
    } else {
        return $MyValue | Select-Object @($EventsDefinition.Fields.Values) | Sort-Object $EventsDefinition.SortBy
    }
}