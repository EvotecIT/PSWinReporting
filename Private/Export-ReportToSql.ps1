function Export-ReportToSQL {
    param (
        [hashtable] $Report,
        [hashtable] $ReportOptions,
        [string] $ReportName,
        $ReportTable
    )
    #Get-ObjectType -Object $Report -Verbose -VerboseOnly
    #Get-ObjectType -Object $ReportOptions -Verbose -VerboseOnly
    if ($Report.Enabled) {
        if ($ReportOptions.AsSql.Use) {
            Write-Color @script:WriteParameters -Text '[i] ', 'Sending ', $ReportName, ' to SQL at ', 'Global', ' level' -Color White, White, Yellow, White, Green, White
            $SqlQuery = Send-SqlInsert -Object $ReportTable -SqlSettings $ReportOptions.AsSql -Verbose:$ReportOptions.Debug.Verbose
            foreach ($Query in $SqlQuery) {
                Write-Color @script:WriteParameters -Text '[i] ', 'MS SQL Output: ', $Query -Color White, White, Yellow
            }
        }
        if ($Report.ExportToSql.Use) {
            Write-Color @script:WriteParameters -Text '[i] ', 'Sending ', $ReportName, ' to SQL at ', 'Local', ' level' -Color White, White, Yellow, White, Green, White
            $SqlQuery = Send-SqlInsert -Object $ReportTable -SqlSettings $Report.ExportToSql -Verbose:$ReportOptions.Debug.Verbose
            foreach ($Query in $SqlQuery) {
                Write-Color @script:WriteParameters -Text '[i] ', 'MS SQL Output: ', $Query -Color White, White, Yellow
            }
        }


    }
}