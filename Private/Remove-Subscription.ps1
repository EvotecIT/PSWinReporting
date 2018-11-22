function Remove-Subscription {
	[CmdletBinding()]
	param(
		[switch] $All,
		[switch] $Own
	)
	$Subscriptions = Start-MyProgram -Program $Script:ProgramWecutil -cmdArgList 'es'
	foreach ($Subscription in $Subscriptions) {
		if ($Own -eq $true -and $Subscription -like '*PSWinReporting*') {
			Write-Color 'Deleting own providers - ', $Subscription -Color White, Green
			Start-MyProgram -Program $Script:ProgramWecutil -cmdArgList 'ds', $Subscription
		}
		if ($All -eq $true -and $Subscription -notlike '*PSWinReporting*') {
			Write-Color 'Deleting all providers - ', $Subscription -Color White, Green
			Start-MyProgram -Program $Script:ProgramWecutil -cmdArgList 'ds', $Subscription
		}

	}
}