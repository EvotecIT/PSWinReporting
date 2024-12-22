function Get-ObjectData {
    <#
    .SYNOPSIS
    Retrieves data from an object based on the specified title.

    .DESCRIPTION
    This function retrieves data from the specified object based on the provided title. It returns an array of values associated with the title.

    .PARAMETER Object
    The object from which data will be retrieved.

    .PARAMETER Title
    The title of the data to retrieve from the object.

    .PARAMETER DoNotAddTitles
    Switch parameter to indicate whether titles should be included in the output.

    .EXAMPLE
    Get-ObjectData -Object $myObject -Title "Name"
    Retrieves the names associated with the object $myObject.

    .EXAMPLE
    Get-ObjectData -Object $myObject -Title "Age" -DoNotAddTitles
    Retrieves the ages associated with the object $myObject without including the title.

    #>
    [CmdletBinding()]
    param(
        $Object,
        $Title,
        [switch] $DoNotAddTitles
    )
    [Array] $Values = $Object.$Title
    [Array] $ArrayList = @(
        if ($Values.Count -eq 1 -and $DoNotAddTitles -eq $false) {
            "$Title - $($Values[0])"
        } else {
            if ($DoNotAddTitles -eq $false) {
                $Title
            }
            foreach ($Value in $Values) {
                "$Value"
            }
        }
    )
    return $ArrayList
}