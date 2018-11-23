function Get-EventLogSize {
	[CmdletBinding()]
	param(
		$Servers,
		$LogName = "Security"
	)
	# $Verbose = ($PSCmdlet.MyInvocation.BoundParameters['Verbose'] -eq $true)
	$results = @()
	foreach ($Server in $Servers) {
		$result = @{
			Server  = $Server
			LogName = $LogName
		}
		try {
			$EventsInfo = Get-WinEvent -ListLog $LogName -ComputerName $Server
			$result.LogType = $EventsInfo.LogType
			$result.LogMode = $EventsInfo.LogMode
			$result.IsEnabled = $EventsInfo.IsEnabled
			$result.CurrentFileSize = Convert-Size -Value $EventsInfo.FileSize -From Bytes -To GB -Precision 2 -Display
			$result.MaximumFilesize = Convert-Size -Value $EventsInfo.MaximumSizeInBytes -From Bytes -To GB -Precision 2 -Display
			$result.EventOldest = (Get-WinEvent -MaxEvents 1 -LogName $LogName -Oldest -ComputerName $Server).TimeCreated
			$result.EventNewest = (Get-WinEvent -MaxEvents 1 -LogName $LogName -ComputerName $Server).TimeCreated
		} catch {
			$ErrorMessage = $_.Exception.Message -replace "`n", " " -replace "`r", " "
			switch ($ErrorMessage) {
				{$_ -match 'No events were found'} {
					$Logger.AddInfoRecord("No events were found on the $Server")
				}
				{$_ -match 'Attempted to perform an unauthorized operation'} {
					$Logger.AddInfoRecord("Unauthorized operation $Server")
				}
				default {
					$Logger.AddErrorRecord("Error occured gathering events on the $Server`: $Exception")
				}
			}
		}
		$results += [PSCustomObject]$result | Select-Object Server, LogName, LogType, EventOldest, EventNewest, "CurrentFileSize", "MaximumFileSize", LogMode, IsEnabled
	}
	return $results
}