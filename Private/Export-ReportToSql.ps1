function Export-ReportToSQL {
    param (
        [System.Collections.IDictionary] $Report,
        [System.Collections.IDictionary] $ReportOptions,
        [string] $ReportName,
        [Array] $ReportTable
    )
    #Get-ObjectType -Object $Report -Verbose -VerboseOnly
    #Get-ObjectType -Object $ReportOptions -Verbose -VerboseOnly
    if ($Report.Enabled) {
        # checks if Report is enabled
        if ($ReportOptions.AsSql.Use) {
            # checks if global sql is enabled
            if ($Report.EnabledSqlGlobal) {
                # checks if global sql is enabled for particular dataset
                Write-Color @script:WriteParameters -Text '[i] ', 'Sending ', $ReportName, ' to SQL at ', 'Global', ' level' -Color White, White, Yellow, White, Green, White
                $SqlQuery = Send-SqlInsert -Object $ReportTable -SqlSettings $ReportOptions.AsSql -Verbose:$ReportOptions.Debug.Verbose
                foreach ($Query in $SqlQuery) {
                    Write-Color @script:WriteParameters -Text '[i] ', 'MS SQL Output: ', $Query -Color White, White, Yellow
                }
            }
        }
        if ($Report.ExportToSql.Use) {
            # checks if local sql is enabled for dataset
            Write-Color @script:WriteParameters -Text '[i] ', 'Sending ', $ReportName, ' to SQL at ', 'Local', ' level' -Color White, White, Yellow, White, Green, White
            $SqlQuery = Send-SqlInsert -Object $ReportTable -SqlSettings $Report.ExportToSql -Verbose:$ReportOptions.Debug.Verbose
            foreach ($Query in $SqlQuery) {
                Write-Color @script:WriteParameters -Text '[i] ', 'MS SQL Output: ', $Query -Color White, White, Yellow
            }
        }
    }
}