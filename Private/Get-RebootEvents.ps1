function Get-RebootEvents($Events, $IgnoreWords = '') {
    # -LogName "System" -Provider "User32"
    # -LogName "System" -Provider "Microsoft-Windows-WER-SystemErrorReporting" -EventID 1001, 1018
    # -LogName "System" -Provider "Microsoft-Windows-Kernel-General" -EventID 1, 12, 13
    # -LogName "System" -Provider "Microsoft-Windows-Kernel-Power" -EventID 42, 41, 109
    # -LogName "System" -Provider "Microsoft-Windows-Power-Troubleshooter" -EventID 1
    # -LogName "System" -Provider "Eventlog" -EventID 6005, 6006, 6008, 6013

    $EventsNeeded = 1001, 1018, 1, 12, 13, 42, 41, 109, 1, 6005, 6006, 6008, 6013 | Sort-Object -Unique
    $EventsFound = Find-EventsNeeded -Events $Events -EventsNeeded $EventsNeeded -EventsType 'System'
    $EventsFound = $EventsFound | Select-Object ID, Computer, TimeCreated, Message
    $EventsFound = Find-EventsIgnored -Events $EventsFound -IgnoreWords $IgnoreWords
    return $EventsFound
}