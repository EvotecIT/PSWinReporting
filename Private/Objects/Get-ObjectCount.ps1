function Get-ObjectCount {
    <#
    .SYNOPSIS
    Counts the number of objects passed as input.

    .DESCRIPTION
    This function calculates and returns the total count of objects passed as input. It is designed to be used in scenarios where counting the number of objects is required.

    .PARAMETER Object
    Specifies the object or objects for which the count needs to be calculated.

    .EXAMPLE
    Get-Process | Get-ObjectCount
    Returns the total count of processes currently running.

    .EXAMPLE
    $Files = Get-ChildItem -Path "C:\Files"
    $FileCount = $Files | Get-ObjectCount
    Returns the total count of files in the specified directory.

    #>
    [CmdletBinding()]
    param(
        [parameter(ValueFromPipelineByPropertyName, ValueFromPipeline)][Object]$Object
    )
    return $($Object | Measure-Object).Count
}