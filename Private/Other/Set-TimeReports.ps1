function Set-TimeReports {
    [CmdletBinding()]
    param(
        [System.Collections.IDictionary] $HashTable
    )
    # Get all report Names
    $Reports = @()
    foreach ($reportName in $($HashTable.GetEnumerator().Name)) {
        $Reports += $reportName
    }

    # Get Highest Count of servers
    $Count = 0
    foreach ($reportName in $reports) {
        if ($($HashTable[$reportName]).Count -ge $Count) {
            $Count = $($HashTable[$reportName]).Count
        }
    }
    $Count = $Count - 1 # Removes Total from Server Count

    $htmlStart = @"
    <table border="0" cellpadding="3" style="font-size:8pt;font-family:Segoe UI,Arial,sans-serif">
        <tr bgcolor="#009900">
            <th colspan="1">
                <font color="#ffffff">Report Names</font>
            </th>
            <th colspan="1">
                <font color="#ffffff">Total</font>
            </th>
        </tr>
"@

    foreach ($reportName in $reports) {
        $htmlStart += '<tr align="left" bgcolor="#dddddd">'
        $htmlStart += '<td>' + $reportName + '</td>'
        foreach ($ElapsedTime in $($HashTable[$reportName].GetEnumerator())) {
            $htmlStart += '<td>' + $ElapsedTime.Value + '</td>'
        }
        $htmlStart += '</tr>'
    }
    $htmlStart += '</table>'
    return $htmlStart
}