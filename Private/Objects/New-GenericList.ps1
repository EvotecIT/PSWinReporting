function New-GenericList {
    <#
    .SYNOPSIS
    Creates a new instance of a generic list.

    .DESCRIPTION
    This function creates a new instance of a generic list based on the specified type.

    .PARAMETER Type
    Specifies the type of objects that the generic list will hold. Defaults to [System.Object].

    .EXAMPLE
    PS C:\> $list = New-GenericList -Type [int]
    Creates a new generic list that holds integers.

    .EXAMPLE
    PS C:\> $list = New-GenericList
    Creates a new generic list that holds objects.

    #>
    [CmdletBinding()]
    param(
        [Object] $Type = [System.Object]
    )
    return New-Object "System.Collections.Generic.List[$Type]"
}