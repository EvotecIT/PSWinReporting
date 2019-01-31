function Export-ReportToSQL {
    [CmdletBinding()]
    param (
        [System.Collections.IDictionary] $Report,
        [System.Collections.IDictionary] $ReportOptions,
        [string] $ReportName,
        [Array] $ReportTable
    )
    if ($Report.Enabled) {
        # checks if Report is enabled
        if ($ReportOptions.Contains('AsSql') -and $ReportOptions.AsSql.Use) {
            # checks if global sql is enabled
            if ($Report.Contains('EnabledSqlGlobal') -and $Report.EnabledSqlGlobal) {
                # checks if global sql is enabled for particular dataset
                $Logger.AddInfoRecord("Sending $ReportName to SQL at Global level")
                $SqlQuery = Send-SqlInsert -Object $ReportTable -SqlSettings $ReportOptions.AsSql -Verbose:$ReportOptions.Debug.Verbose
                foreach ($Query in $SqlQuery) {
                    $Logger.AddInfoRecord("MS SQL Output: $Query")
                }
            }
        }
        if ($Report.Contains('ExportToSql') -and $Report.ExportToSql.Use) {
            # checks if local sql is enabled for dataset
            $Logger.AddInfoRecord("Sending $ReportName to SQL at Local level")
            $SqlQuery = Send-SqlInsert -Object $ReportTable -SqlSettings $Report.ExportToSql -Verbose:$ReportOptions.Debug.Verbose
            foreach ($Query in $SqlQuery) {
                $Logger.AddInfoRecord("MS SQL Output: $Query")
            }
        }
    }
}