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
    $values = @(
        '<QueryList><Query Id="0" Path="Security">'
        "<Select Path=`"$Type`">*[System[("
        for ($i = 0; $i -lt $Events.Count; $i++) {
            "EventID=$($Events[$i])"
            if ($i -lt $Events.Count - 1) {
                'or'
            }
        }
        $Output
        ')]]</Select></Query></QueryList>'
    )
    $FinalQuery = ([string] $Values)
    Write-Verbose $FinalQuery
    return ([string] $Values)
}
<#
<QueryList><Query Id="0" Path="Security"> <Select Path="">*[System[( EventID=115 )]]</Select></Query></QueryList>
#>

#New-EventQuery -Events '115', 116 -Verbose