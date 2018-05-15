function Get-EventLogSize ($Servers, $LogName = "Security") {

    $results = @()
    foreach ($server in $Servers) {
        $ExecutionTime = [System.Diagnostics.Stopwatch]::StartNew()
        try {
            $result = get-WinEvent -ListLog $LogName -ComputerName $server | Select-Object MaximumSizeInBytes, FileSize, IsLogFul, LastAccessTime, LastWriteTime, OldestRecordNumber, RecordCount, LogName, LogType, LogIsolation, IsEnabled, LogMode
        } catch {
            Write-Color @script:WriteParameters "[-] ", "Event Log Error", "$($_.Exception)" -Color White, Red
            continue
        }
        $CurrentFileSize = Convert-Size -Value $($result.FileSize) -From Bytes -To GB -Precision 2 -Display
        $MaximumFilesize = Convert-Size -Value $($result.MaximumSizeInBytes) -From Bytes -To GB -Precision 2 -Display
        $EventOldest = (Get-WinEvent -MaxEvents 1 -LogName $result.LogName -Oldest -ComputerName $Server).TimeCreated
        $EventNewest = (Get-WinEvent -MaxEvents 1 -LogName $result.LogName -ComputerName $Server).TimeCreated
        Add-Member -InputObject $result -MemberType NoteProperty -Name "Server" -Value $server
        Add-Member -InputObject $result -MemberType NoteProperty -Name "CurrentFileSize" -Value $CurrentFileSize
        Add-Member -InputObject $result -MemberType NoteProperty -Name "MaximumFileSize" -Value $MaximumFilesize
        Add-Member -InputObject $result -MemberType NoteProperty -Name "EventOldest" -Value $EventOldest
        Add-Member -InputObject $result -MemberType NoteProperty -Name "EventNewest" -Value $EventNewest
        $results += $result
        $script:TimeToGenerateReports.Reports.IncludeEventLogSize.$($Server) = Set-TimeLog -Time $ExecutionTime
    }
    return $results | Select-Object Server, LogName, LogType, EventOldest, EventNewest, "CurrentFileSize", "MaximumFileSize", LogMode, IsEnabled
}