function Get-EventLogSize {
    [CmdletBinding()]
    param(
        [Array] $Servers,
        [string] $LogName = "Security"
    )
    [Array] $results = foreach ($server in $Servers) {
        try {
            $result = Get-WinEvent -ListLog $LogName -ComputerName $server -ErrorAction Stop | Select-Object MaximumSizeInBytes, FileSize, IsLogFul, LastAccessTime, LastWriteTime, OldestRecordNumber, RecordCount, LogName, LogType, LogIsolation, IsEnabled, LogMode
        } catch {
            $ErrorMessage = $_.Exception.Message -replace "`n", " " -replace "`r", " "
            Write-Color @script:WriteParameters "[-] ", "Event Log Error on ", $Server, ': ', $ErrorMessage -Color White, White, Yellow, White, Red
            continue
        }
        $CurrentFileSize = Convert-Size -Value $($result.FileSize) -From Bytes -To GB -Precision 2 -Display
        $MaximumFilesize = Convert-Size -Value $($result.MaximumSizeInBytes) -From Bytes -To GB -Precision 2 -Display
        try {
            $EventOldest = (Get-WinEvent -MaxEvents 1 -LogName $result.LogName -Oldest -ComputerName $Server -ErrorAction Stop).TimeCreated
        } catch {
            $ErrorMessage = $_.Exception.Message -replace "`n", " " -replace "`r", " "
            Write-Color @script:WriteParameters "[-] ", "Couldn't get single event from ", $Server, ': ', "from log ", $result.LogName, " (oldest). Error message:", $ErrorMessage -Color White, White, Yellow, White, Red
        }
        try {
            $ErrorMessage = $_.Exception.Message -replace "`n", " " -replace "`r", " "
            $EventNewest = (Get-WinEvent -MaxEvents 1 -LogName $result.LogName -ComputerName $Server -ErrorAction Stop).TimeCreated
        } catch {
            Write-Color @script:WriteParameters "[-] ", "Couldn't get single event from ", $Server, ': ', "from log ", $result.LogName, " (newest). Error message:", $ErrorMessage -Color White, White, Yellow, White, Red
        }
        Add-Member -InputObject $result -MemberType NoteProperty -Name "Server" -Value $server
        Add-Member -InputObject $result -MemberType NoteProperty -Name "CurrentFileSize" -Value $CurrentFileSize
        Add-Member -InputObject $result -MemberType NoteProperty -Name "MaximumFileSize" -Value $MaximumFilesize
        Add-Member -InputObject $result -MemberType NoteProperty -Name "EventOldest" -Value $EventOldest
        Add-Member -InputObject $result -MemberType NoteProperty -Name "EventNewest" -Value $EventNewest
        $result
    }
    $results | Select-Object Server, LogName, LogType, EventOldest, EventNewest, "CurrentFileSize", "MaximumFileSize", LogMode, IsEnabled
}