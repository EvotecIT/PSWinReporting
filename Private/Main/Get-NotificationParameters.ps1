function Get-NotificationParameters {
    [CmdletBinding()]
    param(
        [System.Collections.IDictionary] $Notifications,
        [string] $ActivityTitle,
        [string] $Priority,
        [string] $Type
    )
    $Object = @{
        Uri               = ''
        ActivityImageLink = ''
        Color             = ''
        AvatarImage       = ''
        AvatarName        = ''
    }

    if ($null -ne $Notifications.$Priority) {
        $Logger.AddInfoRecord("Service $Type is using $Priority priority Event on $ActivityTitle")
        $Option = $Priority
    } else {
        $Logger.AddInfoRecord("Service $Type is using Default priority Event on $ActivityTitle")
        $Option = 'Default'

    }
    $Object.Uri = $Notifications[$Option].Uri
    ## Only for discord
    $Object.AvatarName = $Notifications[$Option].AvatarName
    $Object.AvatarImage = $Notifications[$Option].AvatarImage

    # All Slack/Discord/Teams
    $Object.ActivityImageLink = $Notifications[$Option].ActivityLinks.Default.Link
    $Object.Color = $Notifications[$Option].ActivityLinks.Default.Color
    foreach ($Type in $Notifications[$option].ActivityLinks.Keys | Where-Object { $_ -ne 'Default' }) {
        if ($ActivityTitle -like "*$Type*") {
            $Object.ActivityImageLink = $Notifications[$Option].ActivityLinks.$Type.Link
            $Object.Color = $Notifications[$Option].ActivityLinks.$Type.Color
            break
        }
    }
    return $Object
}