function Get-EventLogSize {
    [CmdletBinding()]
    param(
        $Servers,
        $LogName = "Security"
    )
    $Verbose = ($PSCmdlet.MyInvocation.BoundParameters['Verbose'] -eq $true)
    $results = @()
    foreach ($server in $Servers) {
        try {
            $result = Get-WinEvent -ListLog $LogName -ComputerName $Server | Select-Object MaximumSizeInBytes, FileSize, IsLogFul, LastAccessTime, LastWriteTime, OldestRecordNumber, RecordCount, LogName, LogType, LogIsolation, IsEnabled, LogMode
        } catch {
            $ErrorMessage = $_.Exception.Message -replace "`n", " " -replace "`r", " "
            switch ($ErrorMessage) {
                {$_ -match 'No events were found'} {
                    Write-Color @script:WriteParameters "[i] ", "No events were found ", $Server, ': ', $ErrorMessage -Color White, White, Yellow, White, Red
                    continue
                }
                {$_ -match 'Attempted to perform an unauthorized operation'} {
                    Write-Color @script:WriteParameters "[-] ", "Unauthorized operation ", $Server, ': ', $ErrorMessage -Color White, White, Yellow, White, Red
                    exit
                }
                default {
                    Write-Color @script:WriteParameters "[-] ", "Error occured gathering events ", $Server, ': ', $ErrorMessage -Color White, White, Yellow, White, Red
                    exit
                }
            }
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
    }

    return $results | Select-Object Server, LogName, LogType, EventOldest, EventNewest, "CurrentFileSize", "MaximumFileSize", LogMode, IsEnabled
}