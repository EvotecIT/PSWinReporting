function Get-NotificationParameters {
    [CmdletBinding()]
    param(
        $Notifications,
        $ActivityTitle
    )
    $Object = @{
        Uri               = ''
        ActivityImageLink = ''
        Color             = ''
    }

    foreach ($Option in $Notifications.Keys | Where-Object { $_ -ne 'Use'  }) {
        $Object.Uri = $Notifications[$Option].Uri
        ## Only for discord
        $Object.AvatarName = $Notifications[$Option].AvatarName
        $Object.AvatarImage = $Notifications[$Option].AvatarImage

        # All Slack/Discord/Teams
        $Object.ActivityImageLink = $Notifications[$Option].ActivityLinks.Default.Link
        $Object.Color = $Notifications[$Option].ActivityLinks.Default.Color
        #Write-Verbose "Before - Object.ActivityImageLink - $($Object.ActivityImageLink)"
        #Write-Verbose "Before - Object.Color - $($Object.Color)"
        foreach ($Type in $Notifications[$option].ActivityLinks.Keys | Where-Object { $_ -ne 'Default' }) {
            if ($ActivityTitle -like "*$Type*") {
                $Object.ActivityImageLink = $Notifications[$Option].ActivityLinks.$Type.Link
                $Object.Color = $Notifications[$Option].ActivityLinks.$Type.Color
                break
            }
        }
    }
    #Write-Verbose "After - Object.ActivityImageLink - $($Object.ActivityImageLink)"
    #Write-Verbose "After - Object.Color - $($Object.Color)"
    return $Object
}