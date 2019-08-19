function New-EventQuery {
    [CmdletBinding()]
    param (
        [string[]]$Events,
        [string] $Type
    )
    <#
        <![CDATA[
        <QueryList>
        <Query Id="0" Path="Security">
        <Select Path="Security">*[System[(EventID=122 or EventID=212 or EventID=323)]]</Select>
        </Query>
        </QueryList>
                ]]>
    #>
    Write-Verbose "New-EventQuery - Events Count: $($Events.Count)"
    $values = New-ArrayList
    Add-ToArray -List $Values -Element '<QueryList><Query Id="0" Path="Security">'
    Add-ToArray -List $Values -Element "<Select Path=`"$Type`">*[System[("
    foreach ($E in $Events) {
        Add-ToArray -List $Values -Element "EventID=$E"
        Add-ToArray -List $Values -Element "or"
    }
    Remove-FromArray -List $values -LastElement
    Add-ToArray -List $Values -Element ')]]</Select></Query></QueryList>'
    $FinalQuery = ([string] $Values)
    Write-Verbose $FinalQuery
    return ([string] $Values)
}