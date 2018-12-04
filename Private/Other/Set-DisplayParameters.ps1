function Set-DisplayParameters($ReportOptions, $DisplayProgress = $false) {
    $Test0 = Test-Key -ConfigurationTable $ReportOptions -ConfigurationKey 'DisplayConsole' -DisplayProgress $DisplayProgress
    if ($Test0 -eq $true) {
        $Test1 = Test-Key -ConfigurationTable $ReportOptions.DisplayConsole -ConfigurationSection '' -ConfigurationKey "ShowTime" -DisplayProgress $DisplayProgress
        $Test2 = Test-Key -ConfigurationTable $ReportOptions.DisplayConsole -ConfigurationSection '' -ConfigurationKey "LogFile" -DisplayProgress $DisplayProgress
        $Test3 = Test-Key -ConfigurationTable $ReportOptions.DisplayConsole -ConfigurationSection '' -ConfigurationKey "TimeFormat" -DisplayProgress $DisplayProgress

        if ($Test1 -and $Test2 -and $Test3) { $script:WriteParameters = $ReportOptions.DisplayConsole }
    }
}