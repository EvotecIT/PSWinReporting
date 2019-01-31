function Export-ToSQL {
    [CmdletBinding()]
    param (
        [System.Collections.IDictionary] $Report,
        [System.Collections.IDictionary] $ReportOptions,
        [string] $ReportName,
        [Array] $ReportTable
    )
    if ($Report.Enabled) {
        # checks if Report is enabled on global level and for that particular report
        if ($ReportOptions.Contains('AsSql') -and $ReportOptions.AsSql.Enabled -and $Report.Contains('SqlExport') -and $Report.SqlExport.EnabledGlobal) {
            # checks if global sql is enabled for particular dataset
            $Logger.AddInfoRecord("Sending $ReportName to SQL at Global level")
            $SqlQuery = Send-SqlInsert -Object $ReportTable -SqlSettings $ReportOptions.AsSql -Verbose:$ReportOptions.Debug.Verbose
            foreach ($Query in $SqlQuery) {
                $Logger.AddInfoRecord("MS SQL GLOBAL Output: $Query")
            }
        }
        if ($Report.Contains('SqlExport') -and $Report.SqlExport.Enabled) {
            # checks if local sql is enabled for dataset
            $Logger.AddInfoRecord("Sending $ReportName to SQL at Local level")
            $SqlQuery = Send-SqlInsert -Object $ReportTable -SqlSettings $Report.SqlExport -Verbose:$ReportOptions.Debug.Verbose
            foreach ($Query in $SqlQuery) {
                $Logger.AddInfoRecord("MS SQL LOCAL Output: $Query")
            }
        }
    }
}