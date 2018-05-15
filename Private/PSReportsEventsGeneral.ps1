function Get-RebootEvents($Servers, $Dates) {

    Write-Color @script:WriteParameters "[i] Running ", "Reboot Events Report (Troubleshooting Only)", " for dates from: ", "$($Dates.DateFrom)", " to: ", "$($Dates.DateTo)", "." -Color White, Green, White, Green, White, Green, White

    # -LogName "System" -Provider "User32"
    # -LogName "System" -Provider "Microsoft-Windows-WER-SystemErrorReporting" -EventID 1001, 1018
    # -LogName "System" -Provider "Microsoft-Windows-Kernel-General" -EventID 1, 12, 13
    # -LogName "System" -Provider "Microsoft-Windows-Kernel-Power" -EventID 42, 41, 109
    # -LogName "System" -Provider "Microsoft-Windows-Power-Troubleshooter" -EventID 1
    # -LogName "System" -Provider "Eventlog" -EventID 6005, 6006, 6008, 6013

    $EventIds = 1001, 1018, 1, 12, 13, 42, 41, 109, 1, 6005, 6006, 6008, 6013
    foreach ($Server in $Servers) {
        $ExecutionTime = [System.Diagnostics.Stopwatch]::StartNew()

        $Events = Get-Events -Server $Server -DateFrom $Dates.DateFrom -DateTo $Dates.DateTo -EventID $EventIds -LogType "System"

        $script:TimeToGenerateReports.Reports.IncludeDomainControllersReboots.$($server) = = Set-TimeLog -Time $ExecutionTime
    }

    Write-Color @script:WriteParameters "[i] Ending ", "Reboot Events Report (Troubleshooting Only)", " for dates from: ", "$($Dates.DateFrom)", " to: ", "$($Dates.DateTo)", "." -Color White, Green, White, Green, White, Green, White
    return $Events | Select-Object ID, Computer, TimeCreated, Message
}

function Get-EventLogClearedLogs($Servers, $Dates) {
    $EventID = 1102
    $Events = @()
    foreach ($Server in $Servers) {
        $ExecutionTime = Start-TimeLog
        $Events += Get-Events -Server $Server -DateFrom $Dates.DateFrom -DateTo $Dates.DateTo -EventID $EventID -LogType "Security" -ProviderName "Microsoft-Windows-Eventlog"
        $script:TimeToGenerateReports.Reports.IncludeClearedLogs.$($Server) = Stop-TimeLog -Time $ExecutionTime
    }
    $EventsOutput = $Events | Select-Object @{label = 'Domain Controller'; expression = { $_.Computer}} ,
    @{label = 'Action'; expression = { ($_.Message -split '\n')[0] }},
    @{label = 'Who'; expression = { "$($_.SubjectDomainName)\$($_.SubjectUserName)" }},
    @{label = 'When'; expression = { $_.Date }},
    @{label = 'Event ID'; expression = { $_.ID }},
    @{label = 'Record ID'; expression = { $_.RecordId }}

    return $EventsOutput
}