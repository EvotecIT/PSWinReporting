function Get-EventsTranslation {
    [CmdletBinding()]
    param(
        [Array] $Events,
        [System.Collections.IDictionary] $EventsDefinition,
        [Array] $EventIDs,
        [string] $EventsType
    )
    if ($EventsDefinition.Filter.Count -gt 0) {
        # Filter works by passing each event by filter.
        # When first filter is passed, next filter only works on the limited output from first filter
        # If first filter removes everything there's nothing left to deal with
        # For example if there's just one  filter that will limit 60 events to 20 events
        # Next filter is processed with only 20 events in place

        # Let's take a look at following example
        # That means (Providername -like 'Microsoft-Windows-Kernel-*' or 'ProviderName -like 'Microsoft-Windows-Kernel-*') -and (GatheredFrom -eq 'AD1')
        #$Filter = @{
        #    'ProviderName#Like' = 'Microsoft-Windows-Kernel-*', 'Event*'
        #    'GatheredFrom'      = 'AD1'
        #}

        # This for example means (ObjectClass -eq 'GroupPolicyContainer') -and (AttributeLDAPDisplayName -eq 'cn' -or AttributeLDAPDisplayName -eq 'displayName')
        #Filter = @{
        #    'ObjectClass' = 'groupPolicyContainer'
        #    'AttributeLDAPDisplayName' = 'cn','displayName'
        #}

        foreach ($Entry in $EventsDefinition.Filter.Keys) {
            $EveryFilter = $EventsDefinition.Filter[$Entry]
            $StrippedFilter = $Entry -replace '#[0-9]{1,2}', ''
            [Array] $Splitter = $StrippedFilter.Split('#')
            if ($Splitter.Count -gt 1) {
                $PropertyName = $Splitter[0]
                $Operator = $Splitter[1]
            } else {
                $PropertyName = $StrippedFilter
                $Operator = 'eq'
            }
            $Events = foreach ($V in $EveryFilter) {
                foreach ($_ in $Events) {
                    if ($Operator -eq 'eq') {
                        if ($_.$PropertyName -eq $V) {
                            $_
                        }
                    } elseif ($Operator -eq 'like') {
                        if ($_.$PropertyName -like $V) {
                            $_
                        }
                    } elseif ($Operator -eq 'ne') {
                        if ($_.$PropertyName -ne $V) {
                            $_
                        }
                    } elseif ($Operator -eq 'gt') {
                        if ($_.$PropertyName -gt $V) {
                            $_
                        }
                    } elseif ($Operator -eq 'lt') {
                        if ($_.$PropertyName -lt $V) {
                            $_
                        }
                    }

                }
            }
        }
    }
    if ($EventsDefinition.FilterOr.Count -gt 0) {
        # FilterOr works by passing each event by filter. This means if you have 5 filters
        # Each event will be verified whether it should stay or not.
        # If none matches Event is discarded

        $Events = foreach ($_ in $Events) {
            foreach ($Entry in $EventsDefinition.FilterOr.Keys) {
                $StrippedFilter = $Entry -replace '#[0-9]{1,2}', ''
                [Array] $Splitter = $StrippedFilter.Split('#')
                if ($Splitter.Count -gt 1) {
                    $PropertyName = $Splitter[0]
                    $Operator = $Splitter[1]
                } else {
                    $PropertyName = $StrippedFilter
                    $Operator = 'eq'
                }
                $Value = $EventsDefinition.FilterOr[$Entry]
                foreach ($V in $Value) {
                    if ($Operator -eq 'eq') {
                        if ($_.$PropertyName -eq $V) {
                            $_
                        }
                    } elseif ($Operator -eq 'like') {
                        if ($_.$PropertyName -like $V) {
                            $_
                        }
                    } elseif ($Operator -eq 'ne') {
                        if ($_.$PropertyName -ne $V) {
                            $_
                        }
                    } elseif ($Operator -eq 'gt') {
                        if ($_.$PropertyName -gt $V) {
                            $_
                        }
                    } elseif ($Operator -eq 'lt') {
                        if ($_.$PropertyName -lt $V) {
                            $_
                        }
                    }
                }
            }
        }
    }
    $MyValue = foreach ($Event in $Events) {
        # Filter out events that are not needed, leave only those that match EventID and EventLogName
        if (($Event.LogName -eq $EventsType) -and ($Event.ID -in $EventIDs)) {
            #Continue
        } else {
            # Skip
            continue
        }
        # $IgnoredFound = $false
        $HashTable = [ordered] @{ }
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
                [Array] $OverwriteObject = $EventsDefinition.Overwrite.$Entry
                # This allows for having multiple values in Overwrite by using #1 or #2 and so on.
                $StrippedFilter = $Entry -replace '#[0-9]{1,2}', ''
                [Array] $Splitter = $StrippedFilter.Split('#')
                if ($Splitter.Count -gt 1) {
                    $PropertyName = $Splitter[0]
                    $Operator = $Splitter[1]
                } else {
                    $PropertyName = $StrippedFilter
                    $Operator = 'eq'
                }
                if ($OverwriteObject.Count -eq 3) {
                    if ($Operator -eq 'eq') {
                        if ($HashTable[($OverwriteObject[0])] -eq $OverwriteObject[1]) {
                            $HashTable[$PropertyName] = $OverwriteObject[2]
                        }
                    } elseif ($Operator -eq 'ne') {

                    } elseif ($Operator -eq 'like') {

                    } elseif ($Operator -eq 'gt') {

                    } elseif ($Operator -eq 'lt') {

                    }
                } elseif ($OverwriteObject.Count -eq 4) {
                    if ($Operator -eq 'eq') {
                        if ($HashTable[($OverwriteObject[0])] -eq $OverwriteObject[1]) {
                            $HashTable[$PropertyName] = $OverwriteObject[2]
                        } else {
                            $HashTable[$PropertyName] = $OverwriteObject[3]
                        }
                    } elseif ($Operator -eq 'ne') {

                    } elseif ($Operator -eq 'like') {

                    } elseif ($Operator -eq 'gt') {

                    } elseif ($Operator -eq 'lt') {

                    }
                } elseif ($OverwriteObject.Couint -eq 1) {
                    $HashTable[$PropertyName] = $HashTable[($OverwriteObject[0])]
                }
            }
        }
        # This overwrites values based on parameters. It's useful for cleanup or special cases.
        # It acts similar to the one above, however it allows you to replace one value with another value from the hashtable.
        # For example replacing EventID field with RecordID -  so 5174 with 812333
        # For whatever reason you would need to do that.
        if ($null -ne $EventsDefinition.OverwriteByField) {
            foreach ($Entry in $EventsDefinition.OverwriteByField.Keys) {
                [Array] $OverwriteObject = $EventsDefinition.OverwriteByField.$Entry
                # This allows for having multiple values in Overwrite by using #1 or #2 and so on.
                $StrippedFilter = $Entry -replace '#[0-9]{1,2}', ''
                [Array] $Splitter = $StrippedFilter.Split('#')
                if ($Splitter.Count -gt 1) {
                    $PropertyName = $Splitter[0]
                    $Operator = $Splitter[1]
                } else {
                    $PropertyName = $StrippedFilter
                    $Operator = 'eq'
                }

                if ($OverwriteObject.Count -eq 3) {
                    if ($Operator -eq 'eq') {
                        if ($HashTable[($OverwriteObject[0])] -eq $OverwriteObject[1]) {
                            $HashTable[$PropertyName] = $HashTable[($OverwriteObject[2])]
                        }
                    } elseif ($Operator -eq 'ne') {
                        if ($HashTable[($OverwriteObject[0])] -ne $OverwriteObject[1]) {
                            $HashTable[$PropertyName] = $HashTable[($OverwriteObject[2])]
                        }
                    } elseif ($Operator -eq 'like') {

                    } elseif ($Operator -eq 'gt') {

                    } elseif ($Operator -eq 'lt') {

                    }
                } elseif ($OverwriteObject.Count -eq 4) {
                    if ($Operator -eq 'eq') {
                        if ($HashTable[($OverwriteObject[0])] -eq $OverwriteObject[1]) {
                            $HashTable[$PropertyName] = $HashTable[($OverwriteObject[2])]
                        } else {
                            $HashTable[$PropertyName] = $HashTable[($OverwriteObject[3])]
                        }
                    } elseif ($Operator -eq 'ne') {

                    } elseif ($Operator -eq 'like') {

                    } elseif ($Operator -eq 'gt') {

                    } elseif ($Operator -eq 'lt') {

                    }
                } elseif ($OverwriteObject.Count -eq 1) {
                    $HashTable[$PropertyName] = $HashTable[($OverwriteObject[0])]
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