
# This function goes thru an object such as Get-Aduser and scans every object returned getting all properties
# This basically makes sure that all properties are known at run time of Export to SQL, Excel or Word

<#
$Test = Get-Process

Get-ObjectProperties -Object $Test
#>
function Get-ObjectProperties {
    <#
    .SYNOPSIS
    Retrieves all properties of an object and allows for adding custom properties.

    .DESCRIPTION
    This function retrieves all properties of an object provided as input. It also allows for adding custom properties to the list. The function can be useful for ensuring that all properties are known at runtime when exporting to SQL, Excel, or Word.

    .PARAMETER Object
    Specifies the object for which properties need to be retrieved.

    .PARAMETER AddProperties
    Specifies an array of custom properties to be added to the list.

    .PARAMETER Sort
    Indicates whether the properties should be sorted.

    .PARAMETER RequireUnique
    Specifies whether the list of properties should be unique.

    .EXAMPLE
    $Test = Get-Process
    Get-ObjectProperties -Object $Test

    Description
    -----------
    Retrieves all properties of the Get-Process object.

    .EXAMPLE
    $Test = Get-Process
    Get-ObjectProperties -Object $Test -AddProperties 'CustomProperty1', 'CustomProperty2' -Sort -RequireUnique $false

    Description
    -----------
    Retrieves all properties of the Get-Process object and adds custom properties 'CustomProperty1' and 'CustomProperty2' to the list. The properties are sorted and duplicates are allowed.

    #>
    [CmdletBinding()]
    param (
        [System.Collections.ICollection] $Object,
        [string[]] $AddProperties, # provides ability to add some custom properties
        [switch] $Sort,
        [bool] $RequireUnique = $true
    )
    $Properties = @(
        foreach ($O in $Object) {
            $ObjectProperties = $O.PSObject.Properties.Name
            $ObjectProperties
            # foreach ($Property in $ObjectProperties) {
            #     $Property
            # }
        }
        foreach ($Property in $AddProperties) {
            #Add-ToArrayAdvanced -List $Properties -Element $Property -SkipNull -RequireUnique
            $Property
        }
    )
    if ($Sort) {
        return $Properties | Sort-Object -Unique:$RequireUnique
    } else {
        return $Properties | Select-Object -Unique:$RequireUnique
    }
}