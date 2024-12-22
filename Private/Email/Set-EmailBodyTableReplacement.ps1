function Set-EmailBodyReplacementTable {
    <#
    .SYNOPSIS
    Replaces a placeholder in the email body with an HTML table.

    .DESCRIPTION
    This function replaces a specified placeholder in the email body with an HTML table generated from the provided table data.

    .PARAMETER Body
    The original email body containing the placeholder to be replaced.

    .PARAMETER TableName
    The placeholder text to be replaced with the HTML table.

    .PARAMETER TableData
    An array of data to be converted into an HTML table.

    .EXAMPLE
    $body = "Hello, <<TablePlaceholder>>!"
    $tableName = "TablePlaceholder"
    $tableData = @("Name", "Age", "Location"), @("Alice", "30", "New York"), @("Bob", "25", "Los Angeles")
    Set-EmailBodyReplacementTable -Body $body -TableName $tableName -TableData $tableData

    This example replaces the placeholder "<<TablePlaceholder>>" in the email body with an HTML table containing the provided data.

    #>
    [CmdletBinding()]
    [alias('Set-EmailBodyTableReplacement')]
    param (
        [string] $Body,
        [string] $TableName,
        [Array] $TableData
    )
    $TableData = $TableData | ConvertTo-Html -Fragment | Out-String
    $Body = $Body -replace "<<$TableName>>", $TableData
    return $Body
}