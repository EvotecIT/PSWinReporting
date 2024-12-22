Function Get-ObjectEnumValues {
    <#
    .SYNOPSIS
    Retrieves the values of an enumeration type and returns them as a hashtable.

    .DESCRIPTION
    This function takes an enumeration type as input and retrieves all its values, storing them in a hashtable where the key is the name of the enum value and the value is the corresponding numeric value.

    .PARAMETER enum
    Specifies the enumeration type for which values need to be retrieved.

    .EXAMPLE
    Get-ObjectEnumValues -enum [System.DayOfWeek]
    Retrieves all values of the System.DayOfWeek enumeration and returns them as a hashtable.

    .EXAMPLE
    Get-ObjectEnumValues -enum [System.ConsoleColor]
    Retrieves all values of the System.ConsoleColor enumeration and returns them as a hashtable.

    #>
    param(
        [string]$enum
    )
    $enumValues = @{}
    [enum]::getvalues([type]$enum) |
        ForEach-Object {
        $enumValues.add($_, $_.value__)
    }
    $enumValues
}