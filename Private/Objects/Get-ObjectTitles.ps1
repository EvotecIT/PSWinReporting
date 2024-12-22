function Get-ObjectTitles {
    <#
    .SYNOPSIS
    Retrieves the titles of properties from an object.

    .DESCRIPTION
    This function retrieves the titles of properties from an object and returns them in an ArrayList.

    .PARAMETER Object
    Specifies the object from which to retrieve property titles.

    .EXAMPLE
    $object = [PSCustomObject]@{
        Name = "John Doe"
        Age = 30
        City = "New York"
    }
    Get-ObjectTitles -Object $object

    Description
    -----------
    Retrieves the property titles from the $object and returns them in an ArrayList.

    #>
    [CmdletBinding()]
    param(
        $Object
    )
    $ArrayList = New-Object System.Collections.ArrayList
    Write-Verbose "Get-ObjectTitles - ObjectType $($Object.GetType())"
    foreach ($Title in $Object.PSObject.Properties) {
        Write-Verbose "Get-ObjectTitles - Value added to array: $($Title.Name)"
        $ArrayList.Add($Title.Name) | Out-Null
    }
    Write-Verbose "Get-ObjectTitles - Array size: $($ArrayList.Count)"
    return $ArrayList
}