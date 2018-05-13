<#
    .SYNOPSIS
    This PowerShell script can generate report according to your defined parameters and monitor for changes that happen on users and groups in Active Directory.
    .DESCRIPTION
    This PowerShell script can generate report according to your defined parameters and monitor for changes that happen on users and groups in Active Directory.

    It can tell you:
    - When and who changed the group membership of any group within your Active Directory Domain
    - When and who changed the user data including Password, UserPrincipalName, SamAccountName, and so on…
    - When and who changed passwords
    - When and who locked out account and where did it happen
    .NOTES
    Version:        0.9
    Author:         Przemyslaw Klys <przemyslaw.klys at evotec.pl>
    Creation Date:  23.03.2018
    Modifcation Date: 12.05.2018

    TODO:
    - DirectoryPattern                = $true # adds to reports path Hourly \ Monthly \ Quarterly \ Custom ("C:\Support\Reports\Hourly")
    - Fixes for reports

    Newest version of the script is always available at: https://evotec.xyz/hub/scripts/get-eventslibrary-ps1/

    Additonal notes for self for using it later
    Users https://www.ultimatewindowssecurity.com/securitylog/book/page.aspx?spid=chapter8#UAM
    4720: A user account was created                                    https://www.ultimatewindowssecurity.com/securitylog/encyclopedia/event.aspx?eventID=4720
    4722: A user account was enabled                                    https://www.ultimatewindowssecurity.com/securitylog/encyclopedia/event.aspx?eventid=4722
    4725: A user account was disabled                                   https://www.ultimatewindowssecurity.com/securitylog/encyclopedia/event.aspx?eventID=4725
    4726: A user account was deleted                                    https://www.ultimatewindowssecurity.com/securitylog/encyclopedia/event.aspx?eventID=4726
    4738: A user account was changed                                    https://www.ultimatewindowssecurity.com/securitylog/encyclopedia/event.aspx?eventID=4738
    4740: A user account was locked out.                                https://www.ultimatewindowssecurity.com/securitylog/encyclopedia/event.aspx?eventid=4740
    4767: A user account was unlocked.                                  https://www.ultimatewindowssecurity.com/securitylog/encyclopedia/event.aspx?eventid=4767
    4781: The name of an account was changed                            https://www.ultimatewindowssecurity.com/securitylog/encyclopedia/event.aspx?eventid=4781
    4723: An attempt was made to change an account's password           https://www.ultimatewindowssecurity.com/securitylog/encyclopedia/event.aspx?eventID=4723
    4724: An attempt was made to reset an accounts password             https://www.ultimatewindowssecurity.com/securitylog/encyclopedia/event.aspx?eventID=4724

    .EXAMPLE
    Examples of usage can be found at https://evotec.xyz/monitoring-active-directory-changes-on-users-and-groups-with-powershell
#>
Set-StrictMode -Version Latest

# Default value / overwritten if set in config
$script:WriteParameters = @{
    ShowTime = $true
    LogFile = ""
    TimeFormat = "yyyy-MM-dd HH:mm:ss"
}
$script:TimeToGenerateReports = [ordered]@{
    Reports = @{
        IncludeDomainControllers = @{
            Total = $null
        }
        IncludeGroupEvents = @{
            Total = $null
        }
        IncludeGroupCreateDelete = @{
            Total = $null
        }
        IncludeUserEvents = @{
            Total = $null
        }
        IncludeUserStatuses = @{
            Total = $null
        }
        IncludeUserLockouts = @{
            Total = $null
        }
        IncludeDomainControllersReboots = @{
            Total = $null
        }
        IncludeLogonEvents = @{
            Total = $null
        }
        IncludeGroupPolicyChanges = @{
            Total = $null
        }
        IncludeClearedLogs = @{
            Total = $null
        }
        IncludeEventLogSize = @{
            Total = $null
        }
    }
}

Function Get-ModulesAvailability ([string]$Name) {
    if (-not(Get-Module -name $name)) {
        if (Get-Module -ListAvailable | Where-Object { $_.name -eq $name }) {
            try {
                Import-Module -Name $name
                return $true
            } catch {
                return $false
            }
        } else { return $false } #module not available
    } else { return $true } #module already loaded
}
function Test-Key ($ConfigurationTable, $ConfigurationSection = "", $ConfigurationKey, $DisplayProgress = $false) {
    if ($ConfigurationTable -eq $null) { return $false }
    try {
        $value = $ConfigurationTable.ContainsKey($ConfigurationKey)
    } catch {
        $value = $false
    }
    if ($value -eq $true) {
        if ($DisplayProgress -eq $true) {
            Write-Color @script:WriteParameters -Text "[i] ", "Parameter in configuration of ", "$ConfigurationSection.$ConfigurationKey", " exists." -Color White, White, Green, White
        }
        return $true
    } else {
        if ($DisplayProgress -eq $true) {
            Write-Color @script:WriteParameters -Text "[i] ", "Parameter in configuration of ", "$ConfigurationSection.$ConfigurationKey", " doesn't exist." -Color White, White, Red, White
        }
        return $false
    }
}
function Test-Configuration ($EmailParameters, $ReportOptions, $FormattingParameters) {
    Write-Warning "[i] Testing for configuration consistency. This is to make sure the script can be safely executed..."
    if ($EmailParameters -eq $null -or $ReportOptions -eq $null -or $FormattingParameters -eq $null) {
        Write-Warning "[i] There is not enough parameters passed to the Start-Reporting. Make sure there are 4 parameter groups (hashtables). Check documentation - you would be better to just start from scratch!"
        Exit
    }
    Write-Color @script:WriteParameters -Text "[t] ", "Testing for missing parameters in configuration...", "Keep tight!" -Color White, White, Yellow
    $ConfigurationFormatting = @()
    $ConfigurationReport = @()
    $ConfigurationEmail = @()

    #region EmailParameters

    $ConfigurationEmail += Test-Key $EmailParameters "EmailParameters" "EmailFrom" -DisplayProgress $true
    $ConfigurationEmail += Test-Key $EmailParameters "EmailParameters" "EmailTo" -DisplayProgress $true
    $ConfigurationEmail += Test-Key $EmailParameters "EmailParameters" "EmailCC" -DisplayProgress $true
    $ConfigurationEmail += Test-Key $EmailParameters "EmailParameters" "EmailBCC" -DisplayProgress $true
    $ConfigurationEmail += Test-Key $EmailParameters "EmailParameters" "EmailServer" -DisplayProgress $true
    $ConfigurationEmail += Test-Key $EmailParameters "EmailParameters" "EmailServerPassword" -DisplayProgress $true
    $ConfigurationEmail += Test-Key $EmailParameters "EmailParameters" "EmailServerPort" -DisplayProgress $true
    $ConfigurationEmail += Test-Key $EmailParameters "EmailParameters" "EmailServerLogin" -DisplayProgress $true
    $ConfigurationEmail += Test-Key $EmailParameters "EmailParameters" "EmailServerEnableSSL" -DisplayProgress $true
    $ConfigurationEmail += Test-Key $EmailParameters "EmailParameters" "EmailEncoding" -DisplayProgress $true
    $ConfigurationEmail += Test-Key $EmailParameters "EmailParameters" "EmailSubject" -DisplayProgress $true
    $ConfigurationEmail += Test-Key $EmailParameters "EmailParameters" "EmailPriority" -DisplayProgress $true
    $ConfigurationEmail += Test-Key $EmailParameters "EmailParameters" "EmailReplyTo" -DisplayProgress $true
    #endregion EmailParameters
    #region FormattingParameters
    #  Write-Color @Global:WriteParameters -Text "[t] ", "Testing for missing parameters in configuration of ", "FormattingParameters", "..." -Color White, White, Yellow
    $ConfigurationFormatting += Test-Key $FormattingParameters "FormattingParameters" "CompanyBranding" -DisplayProgress $true
    if ($ConfigurationFormatting[ - 1] -eq $true) {
        $ConfigurationFormatting += Test-Key $FormattingParameters.CompanyBranding "FormattingParameters.CompanyBranding" "Logo" -DisplayProgress $true
        $ConfigurationFormatting += Test-Key $FormattingParameters.CompanyBranding "FormattingParameters.CompanyBranding" "Width" -DisplayProgress $true
        $ConfigurationFormatting += Test-Key $FormattingParameters.CompanyBranding "FormattingParameters.CompanyBranding" "Height" -DisplayProgress $true
        $ConfigurationFormatting += Test-Key $FormattingParameters.CompanyBranding "FormattingParameters.CompanyBranding" "Link" -DisplayProgress $true
    }
    $ConfigurationFormatting += Test-Key $FormattingParameters "FormattingParameters" "FontFamily" -DisplayProgress $true
    $ConfigurationFormatting += Test-Key $FormattingParameters "FormattingParameters" "FontSize" -DisplayProgress $true
    $ConfigurationFormatting += Test-Key $FormattingParameters "FormattingParameters" "FontHeadingFamily" -DisplayProgress $true
    $ConfigurationFormatting += Test-Key $FormattingParameters "FormattingParameters" "FontHeadingSize" -DisplayProgress $true
    #endregion FormattingParameters
    #region ReportOptions Reports
    $ConfigurationReport += Test-Key $ReportOptions "ReportOptions" "OnlyPrimaryDC" -DisplayProgress $true

    $ConfigurationReport += Test-Key $ReportOptions "ReportOptions" "IncludeDomainControllers" -DisplayProgress $true
    $ConfigurationReport += Test-Key $ReportOptions "ReportOptions" "IncludeClearedLogs"    -DisplayProgress $true
    $ConfigurationReport += Test-Key $ReportOptions "ReportOptions" "IncludeGroupEvents" -DisplayProgress $true
    $ConfigurationReport += Test-Key $ReportOptions "ReportOptions" "IncludeUserEvents" -DisplayProgress $true
    $ConfigurationReport += Test-Key $ReportOptions "ReportOptions" "IncludeUserStatuses" -DisplayProgress $true
    $ConfigurationReport += Test-Key $ReportOptions "ReportOptions" "IncludeUserLockouts" -DisplayProgress $true
    $ConfigurationReport += Test-Key $ReportOptions "ReportOptions" "IncludeDomainControllersReboots" -DisplayProgress $true
    $ConfigurationReport += Test-Key $ReportOptions "ReportOptions" "IncludeLogonEvents" -DisplayProgress $true
    $ConfigurationReport += Test-Key $ReportOptions "ReportOptions" "IncludeGroupPolicyChanges" -DisplayProgress $true
    $ConfigurationReport += Test-Key $ReportOptions "ReportOptions" "IncludeGroupCreateDelete" -DisplayProgress $true
    $ConfigurationReport += Test-Key $ReportOptions "ReportOptions" "IncludeTimeToGenerate" -DisplayProgress $true

    $ConfigurationReport += Test-Key $ReportOptions "ReportOptions" "IncludeEventLogSize" -DisplayProgress $true
    if ($ConfigurationReport[ - 1] -eq $true) {
        $ConfigurationReport += Test-Key $ReportOptions.IncludeEventLogSize "ReportOptions.IncludeEventLogSize" "Use" -DisplayProgress $true
        $ConfigurationReport += Test-Key $ReportOptions.IncludeEventLogSize "ReportOptions.IncludeEventLogSize" "Logs" -DisplayProgress $true
        $ConfigurationReport += Test-Key $ReportOptions.IncludeEventLogSize "ReportOptions.IncludeEventLogSize" "SortBy" -DisplayProgress $true
    }
    #endregion ReportOptions Reports

    #region ReportOptions Per Hour
    $ConfigurationReport += Test-Key $ReportOptions "ReportOptions" "ReportPastHour" -DisplayProgress $true
    $ConfigurationReport += Test-Key $ReportOptions "ReportOptions" "ReportCurrentHour" -DisplayProgress $true
    #endregion ReportOptions Per Hour
    #region ReportOptions Per Day
    $ConfigurationReport += Test-Key $ReportOptions "ReportOptions" "ReportPastDay" -DisplayProgress $true
    $ConfigurationReport += Test-Key $ReportOptions "ReportOptions" "ReportCurrentDay" -DisplayProgress $true
    $ConfigurationReport += Test-Key $ReportOptions "ReportOptions" "ReportOnDay" -DisplayProgress $true
    if ($ConfigurationReport[ - 1] -eq $true) {
        $ConfigurationReport += Test-Key $ReportOptions.ReportOnDay "ReportOptions.ReportOnDay" "Use" -DisplayProgress $true
        $ConfigurationReport += Test-Key $ReportOptions.ReportOnDay "ReportOptions.ReportOnDay" "Days" -DisplayProgress $true
    }
    #region ReportOptions Per Month
    $ConfigurationReport += Test-Key $ReportOptions "ReportOptions" "ReportPastMonth" -DisplayProgress $true
    if ($ConfigurationReport[ - 1] -eq $true) {
        $ConfigurationReport += Test-Key $ReportOptions.ReportPastMonth "ReportOptions.ReportPastMonth" "Use" -DisplayProgress $true
        $ConfigurationReport += Test-Key $ReportOptions.ReportPastMonth "ReportOptions.ReportPastMonth" "Force" -DisplayProgress $true
    }
    $ConfigurationReport += Test-Key $ReportOptions "ReportOptions" "ReportCurrentMonth" -DisplayProgress $true
    #endregion ReportOptions Per Month
    #region ReportOptions Per Quarter

    $ConfigurationReport += Test-Key $ReportOptions "ReportOptions" "ReportPastQuarter" -DisplayProgress $true
    if ($ConfigurationReport[ - 1] -eq $true) {
        $ConfigurationReport += Test-Key $ReportOptions.ReportPastQuarter "ReportOptions.ReportPastQuarter" "Use" -DisplayProgress $true
        $ConfigurationReport += Test-Key $ReportOptions.ReportPastQuarter "ReportOptions.ReportPastQuarter" "Force" -DisplayProgress $true
    }
    $ConfigurationReport += Test-Key $ReportOptions "ReportOptions" "ReportCurrentQuarter" -DisplayProgress $true
    #endregion ReportOptions Per Quarter
    #region ReportOptions Custom Dates
    $ConfigurationReport += Test-Key $ReportOptions "ReportOptions" "ReportCurrentDayMinusDayX" -DisplayProgress $true
    if ($ConfigurationReport[ - 1] -eq $true) {
        $ConfigurationReport += Test-Key $ReportOptions.ReportCurrentDayMinusDayX "ReportOptions.ReportCurrentDayMinusDayX" "Use" -DisplayProgress $true
        $ConfigurationReport += Test-Key $ReportOptions.ReportCurrentDayMinusDayX "ReportOptions.ReportCurrentDayMinusDayX" "Days" -DisplayProgress $true
    }
    $ConfigurationReport += Test-Key $ReportOptions "ReportOptions" "ReportCurrentDayMinuxDaysX" -DisplayProgress $true
    if ($ConfigurationReport[ - 1] -eq $true) {
        $ConfigurationReport += Test-Key $ReportOptions.ReportCurrentDayMinuxDaysX "ReportOptions.ReportCurrentDayMinuxDaysX" "Use" -DisplayProgress $true
        $ConfigurationReport += Test-Key $ReportOptions.ReportCurrentDayMinuxDaysX "ReportOptions.ReportCurrentDayMinuxDaysX" "Days" -DisplayProgress $true
    }
    $ConfigurationReport += Test-Key $ReportOptions "ReportOptions" "ReportCustomDate" -DisplayProgress $true
    if ($ConfigurationReport[ - 1] -eq $true) {
        $ConfigurationReport += Test-Key $ReportOptions.ReportCustomDate "ReportOptions.ReportCustomDate" "Use" -DisplayProgress $true
        $ConfigurationReport += Test-Key $ReportOptions.ReportCustomDate "ReportOptions.ReportCustomDate" "DateFrom" -DisplayProgress $true
        $ConfigurationReport += Test-Key $ReportOptions.ReportCustomDate "ReportOptions.ReportCustomDate" "DateTo" -DisplayProgress $true
    }
    #endregion ReportOptions Custom Dates

    #region ReportOptions Options
    $ConfigurationReport += Test-Key $ReportOptions "ReportOptions" "AsExcel" -DisplayProgress $true
    $ConfigurationReport += Test-Key $ReportOptions "ReportOptions" "AsCSV" -DisplayProgress $true
    $ConfigurationReport += Test-Key $ReportOptions "ReportOptions" "AsHTML" -DisplayProgress $true
    $ConfigurationReport += Test-Key $ReportOptions "ReportOptions" "SendMail" -DisplayProgress $true
    $ConfigurationReport += Test-Key $ReportOptions "ReportOptions" "KeepReportsPath" -DisplayProgress $true
    $ConfigurationReport += Test-Key $ReportOptions "ReportOptions" "FilePattern" -DisplayProgress $true
    $ConfigurationReport += Test-Key $ReportOptions "ReportOptions" "FilePatternDateFormat" -DisplayProgress $true
    #endregion ReportOptions Options
    if ($ConfigurationFormatting -notcontains $false -and $ConfigurationReport -notcontains $false -and $ConfigurationEmail -notcontains $false) {
        return $true
    } else {
        return $false
    }
}
Function Test-Prerequisite ([hashtable] $EmailParameters, [hashtable] $ReportOptions, [hashtable]  $FormattingParameters) {
    $Configuration = Test-Configuration $EmailParameters $ReportOptions $FormattingParameters
    if (-not $Configuration) {
        Write-Color @script:WriteParameters "[i] ", "There are parameters missing in configuration file. Can't continue running...", "Terminated!" -Color White, Yellow, Red
        Exit
    }

    Write-Color @script:WriteParameters "[i] ", "Testing for prerequisite availability..." -Color White, Yellow
    $ImportPSEventViewer = Get-ModulesAvailability -Name "PSEventViewer"
    If ($ImportPSEventViewer -eq $true) {
        Write-Color @script:WriteParameters  "[+] ", "PSEventViewer", " module imported. Continuing..." -Color White, Green, White
    } else {
        Write-Color @script:WriteParameters  "[-] ", "PSEventViewer", " module not found." -Color White, Red, White
    }

    $ImportPSADReporting = Get-ModulesAvailability -Name "PSADReporting"
    If ($ImportPSADReporting -eq $true) {
        Write-Color @script:WriteParameters  "[+] ", "PSADReporting", " module imported. Continuing..." -Color White, Green, White
    } else {
        Write-Color @script:WriteParameters  "[-] ", "PSADReporting", " module not found." -Color White, Red, White
    }

    $ImportExcel = Get-ModulesAvailability -Name "ImportExcel"
    if ($ImportExcel -eq $true) {
        Write-Color @script:WriteParameters  "[+] ", "ImportExcel", " module imported. Continuing..." -Color White, Green, White
    } else {
        Write-Color @script:WriteParameters  "[-] ", "ImportExcel", " module not found." -Color White, Red, White
        if ($ReportOptions.AsExcel -eq $true) {
            Write-Color @script:WriteParameters  "[-] ", "ImportExcel ", "module is not installed. Disable ", "AsExcel", " under ", "ReportOptions", " option before rerunning this script." -Color White, Red, White, Yellow, White, Yellow, White
            Write-Color @script:WriteParameters  "[-] ", "Alternatively run ", "Install-Module -Name ImportExcel", " before re-running this script. It's quite useful module!" -Color White, White, Yellow, White
            Write-Color @script:WriteParameters  "[-] ", "If ", "Install-Module", " is not there as well (", "poor you - running older system are you?", ") you need to download PackageManagement PowerShell Modules." -Color White, White, Yellow, White, Yellow, White
            Write-Color @script:WriteParameters  "[-] ", "It can be found at ", "https://www.microsoft.com/en-us/download/details.aspx?id=51451", ". After download, install and re-run Install-Module again." -Color White, White, Yellow, White
        }
    }
    $ImportActiveDirectory = Get-ModulesAvailability -Name "ActiveDirectory"
    if ($ImportActiveDirectory -eq $true) {
        Write-Color @script:WriteParameters  "[+] ", "ActiveDirectory", " module imported. Continuing..." -Color White, Green, White
    } else {
        Write-Color @script:WriteParameters  "[-] ", "ActiveDirectory", " module not found." -Color White, Red, White
        Write-Color @script:WriteParameters  "[-] ", "ActiveDirectory", " module is ", "critical", " for operation of this script." -Color White, Red, White, Red, White
        Write-Color @script:WriteParameters  "[-] ", "Please make sure it's available on the machine before running this script" -Color White, Red
    }
    try {
        $TestActiveDirectory = get-addomain
        $AdIsAvailable = $true
    } catch {
        if ($_.Exception -match "Unable to find a default server with Active Directory Web Services running.") {
            Write-Color @script:WriteParameters "[-] ", "Active Directory", " not found. Please run this script with access to ", "Domain Controllers." -Color White, Red, White, Red
        }
        Write-Color @script:WriteParameters "[-] ", "Error: $($_.Exception.Message)" -Color White, Red
        $AdIsAvailable = $false
    }

    if ($ImportPSEventViewer -eq $true -and $ImportPSADReporting -eq $true -and $ImportActiveDirectory -eq $true -and (($ReportOptions.AsExcel -eq $true -and $ImportExcel -eq $true) -or $ReportOptions.AsExcel -eq $false) -and $AdIsAvailable -eq $true) {
        return #$true
    } else {
        Exit
        #return $false
    }
}
Function Convert-UAC ([int]$UAC) {
    $PropertyFlags = @(s
        "SCRIPT",
        "ACCOUNTDISABLE",
        "RESERVED",
        "HOMEDIR_REQUIRED",
        "LOCKOUT",
        "PASSWD_NOTREQD",
        "PASSWD_CANT_CHANGE",
        "ENCRYPTED_TEXT_PWD_ALLOWED",
        "TEMP_DUPLICATE_ACCOUNT",
        "NORMAL_ACCOUNT",
        "RESERVED",
        "INTERDOMAIN_TRUST_ACCOUNT",
        "WORKSTATION_TRUST_ACCOUNT",
        "SERVER_TRUST_ACCOUNT",
        "RESERVED",
        "RESERVED",
        "DONT_EXPIRE_PASSWORD",
        "MNS_LOGON_ACCOUNT",
        "SMARTCARD_REQUIRED",
        "TRUSTED_FOR_DELEGATION",
        "NOT_DELEGATED",
        "USE_DES_KEY_ONLY",
        "DONT_REQ_PREAUTH",
        "PASSWORD_EXPIRED",
        "TRUSTED_TO_AUTH_FOR_DELEGATION",
        "RESERVED",
        "PARTIAL_SECRETS_ACCOUNT"
        "RESERVED"
        "RESERVED"
        "RESERVED"
        "RESERVED"
        "RESERVED"
    )
    #Possibility 1: One property per line (commented because I use the second one)
    #1..($PropertyFlags.Length) | Where-Object {$UAC -bAnd [math]::Pow(2,$_)} | ForEach-Object {$PropertyFlags[$_]}

    #Possibility 2: One line for all properties (suits my script better)
    $Attributes = ""
    1..($PropertyFlags.Length) | Where-Object {$UAC -bAnd [math]::Pow(2, $_)} | ForEach-Object {If ($Attributes.Length -EQ 0) {$Attributes = $PropertyFlags[$_]} Else {$Attributes = $Attributes + ", " + $PropertyFlags[$_]}}
    Return $Attributes
}
Function ConvertTo-FlatObject {
    <#
      .SYNOPSIS
        Flatten an object to simplify discovery of data

      .DESCRIPTION
        Flatten an object.  This function will take an object, and flatten the properties using their full path into a single object with one layer of properties.

        You can use this to flatten XML, JSON, and other arbitrary objects.

        This can simplify initial exploration and discovery of data returned by APIs, interfaces, and other technologies.

        NOTE:
            Use tools like Get-Member, Select-Object, and Show-Object to further explore objects.
            This function does not handle certain data types well.  It was original designed to expand XML and JSON.

      .PARAMETER InputObject
        Object to flatten

      .PARAMETER Exclude
        Exclude any nodes in this list.  Accepts wildcards.

        Example:
            -Exclude price, title

      .PARAMETER ExcludeDefault
        Exclude default properties for sub objects.  True by default.

        This simplifies views of many objects (e.g. XML) but may exclude data for others (e.g. if flattening a process, ProcessThread properties will be excluded)

      .PARAMETER Include
        Include only leaves in this list.  Accepts wildcards.

        Example:
            -Include Author, Title

      .PARAMETER Value
        Include only leaves with values like these arguments.  Accepts wildcards.

      .PARAMETER MaxDepth
        Stop recursion at this depth.

      .INPUTS
        Any object

      .OUTPUTS
        System.Management.Automation.PSCustomObject

      .EXAMPLE

        #Pull unanswered PowerShell questions from StackExchange, Flatten the data to date a feel for the schema
        Invoke-RestMethod "https://api.stackexchange.com/2.0/questions/unanswered?order=desc&sort=activity&tagged=powershell&pagesize=10&site=stackoverflow" |
            ConvertTo-FlatObject -Include Title, Link, View_Count

            $object.items[0].owner.link : http://stackoverflow.com/users/1946412/julealgon
            $object.items[0].view_count : 7
            $object.items[0].link       : http://stackoverflow.com/questions/26910789/is-it-possible-to-reuse-a-param-block-across-multiple-functions
            $object.items[0].title      : Is it possible to reuse a &#39;param&#39; block across multiple functions?
            $object.items[1].owner.link : http://stackoverflow.com/users/4248278/nitin-tyagi
            $object.items[1].view_count : 8
            $object.items[1].link       : http://stackoverflow.com/questions/26909879/use-powershell-to-retreive-activated-features-for-sharepoint-2010
            $object.items[1].title      : Use powershell to retreive Activated features for sharepoint 2010
            ...

      .EXAMPLE

        #Set up some XML to work with
        $object = [xml]'
            <catalog>
               <book id="bk101">
                  <author>Gambardella, Matthew</author>
                  <title>XML Developers Guide</title>
                  <genre>Computer</genre>
                  <price>44.95</price>
               </book>
               <book id="bk102">
                  <author>Ralls, Kim</author>
                  <title>Midnight Rain</title>
                  <genre>Fantasy</genre>
                  <price>5.95</price>
               </book>
            </catalog>'

        #Call the flatten command against this XML
            ConvertTo-FlatObject $object -Include Author, Title, Price

            #Result is a flattened object with the full path to the node, using $object as the root.
            #Only leaf properties we specified are included (author,title,price)

                $object.catalog.book[0].author : Gambardella, Matthew
                $object.catalog.book[0].title  : XML Developers Guide
                $object.catalog.book[0].price  : 44.95
                $object.catalog.book[1].author : Ralls, Kim
                $object.catalog.book[1].title  : Midnight Rain
                $object.catalog.book[1].price  : 5.95

        #Invoking the property names should return their data if the orginal object is in $object:
            $object.catalog.book[1].price
                5.95

            $object.catalog.book[0].title
                XML Developers Guide

      .EXAMPLE

        #Set up some XML to work with
            [xml]'<catalog>
               <book id="bk101">
                  <author>Gambardella, Matthew</author>
                  <title>XML Developers Guide</title>
                  <genre>Computer</genre>
                  <price>44.95</price>
               </book>
               <book id="bk102">
                  <author>Ralls, Kim</author>
                  <title>Midnight Rain</title>
                  <genre>Fantasy</genre>
                  <price>5.95</price>
               </book>
            </catalog>' |
                ConvertTo-FlatObject -exclude price, title, id

        Result is a flattened object with the full path to the node, using XML as the root.  Price and title are excluded.

            $Object.catalog                : catalog
            $Object.catalog.book           : {book, book}
            $object.catalog.book[0].author : Gambardella, Matthew
            $object.catalog.book[0].genre  : Computer
            $object.catalog.book[1].author : Ralls, Kim
            $object.catalog.book[1].genre  : Fantasy

      .EXAMPLE
        #Set up some XML to work with
            [xml]'<catalog>
               <book id="bk101">
                  <author>Gambardella, Matthew</author>
                  <title>XML Developers Guide</title>
                  <genre>Computer</genre>
                  <price>44.95</price>
               </book>
               <book id="bk102">
                  <author>Ralls, Kim</author>
                  <title>Midnight Rain</title>
                  <genre>Fantasy</genre>
                  <price>5.95</price>
               </book>
            </catalog>' |
                ConvertTo-FlatObject -Value XML*, Fantasy

        Result is a flattened object filtered by leaves that matched XML* or Fantasy

            $Object.catalog.book[0].title : XML Developers Guide
            $Object.catalog.book[1].genre : Fantasy

      .EXAMPLE
        #Get a single process with all props, flatten this object.  Don't exclude default properties
        Get-Process | select -first 1 -skip 10 -Property * | ConvertTo-FlatObject -ExcludeDefault $false

        #NOTE - There will likely be bugs for certain complex objects like this.
                For example, $Object.StartInfo.Verbs.SyncRoot.SyncRoot... will loop until we hit MaxDepth. (Note: SyncRoot is now addressed individually)

      .NOTES
        I have trouble with algorithms.  If you have a better way to handle this, please let me know!

      .FUNCTIONALITY
        General Command
    #>
    [cmdletbinding()]
    param(

        [parameter( Mandatory = $True,
            ValueFromPipeline = $True)]
        [PSObject[]]$InputObject,
        [string[]]$Exclude = "",
        [bool]$ExcludeDefault = $True,
        [string[]]$Include = $null,
        [string[]]$Value = $null,
        [int]$MaxDepth = 10
    )
    Begin {
        #region FUNCTIONS

        #Before adding a property, verify that it matches a Like comparison to strings in $Include...
        Function IsIn-Include {
            param($prop)
            if (-not $Include) {$True}
            else {
                foreach ($Inc in $Include) {
                    if ($Prop -like $Inc) {
                        $True
                    }
                }
            }
        }

        #Before adding a value, verify that it matches a Like comparison to strings in $Value...
        Function IsIn-Value {
            param($val)
            if (-not $Value) {$True}
            else {
                foreach ($string in $Value) {
                    if ($val -like $string) {
                        $True
                    }
                }
            }
        }

        Function Get-Exclude {
            [cmdletbinding()]
            param($obj)

            #Exclude default props if specified, and anything the user specified.  Thanks to Jaykul for the hint on [type]!
            if ($ExcludeDefault) {
                Try {
                    $DefaultTypeProps = @( $obj.gettype().GetProperties() | Select-Object -ExpandProperty Name -ErrorAction Stop )
                    if ($DefaultTypeProps.count -gt 0) {
                        Write-Verbose "Excluding default properties for $($obj.gettype().Fullname):`n$($DefaultTypeProps | Out-String)"
                    }
                } Catch {
                    Write-Verbose "Failed to extract properties from $($obj.gettype().Fullname): $_"
                    $DefaultTypeProps = @()
                }
            }

            @( $Exclude + $DefaultTypeProps ) | Select-Object -Unique
        }

        #Function to recurse the Object, add properties to object
        Function Recurse-Object {
            [cmdletbinding()]
            param(
                $Object,
                [string[]]$path = '$Object',
                [psobject]$Output,
                $depth = 0
            )

            # Handle initial call
            Write-Verbose "Working in path $Path at depth $depth"
            Write-Debug "Recurse Object called with PSBoundParameters:`n$($PSBoundParameters | Out-String)"
            $Depth++

            #Exclude default props if specified, and anything the user specified.
            $ExcludeProps = @( Get-Exclude $object )

            #Get the children we care about, and their names
            $Children = $object.psobject.properties | Where-Object {$ExcludeProps -notcontains $_.Name }
            Write-Debug "Working on properties:`n$($Children | Select-Object -ExpandProperty Name | Out-String)"

            #Loop through the children properties.
            foreach ($Child in @($Children)) {
                $ChildName = $Child.Name
                $ChildValue = $Child.Value

                Write-Debug "Working on property $ChildName with value $($ChildValue | Out-String)"
                # Handle special characters...
                if ($ChildName -match '[^a-zA-Z0-9_]') {
                    $FriendlyChildName = "{$ChildName}"
                } else {
                    $FriendlyChildName = $ChildName
                }

                #Add the property.
                if ((IsIn-Include $ChildName) -and (IsIn-Value $ChildValue) -and $Depth -le $MaxDepth) {
                    $ThisPath = @( $Path + $FriendlyChildName ) -join "."
                    $Output | Add-Member -MemberType NoteProperty -Name $ThisPath -Value $ChildValue
                    Write-Verbose "Adding member '$ThisPath'"
                }

                #Handle null...
                if ($ChildValue -eq $null) {
                    Write-Verbose "Skipping NULL $ChildName"
                    continue
                }

                #Handle evil looping.  Will likely need to expand this.  Any thoughts on a better approach?
                if (
                    (
                        $ChildValue.GetType() -eq $Object.GetType() -and
                        $ChildValue -is [datetime]
                    ) -or
                    (
                        $ChildName -eq "SyncRoot" -and
                        -not $ChildValue
                    )
                ) {
                    Write-Verbose "Skipping $ChildName with type $($ChildValue.GetType().fullname)"
                    continue
                }

                #Check for arrays
                $IsArray = @($ChildValue).count -gt 1
                $count = 0

                #Set up the path to this node and the data...
                $CurrentPath = @( $Path + $FriendlyChildName ) -join "."

                #Exclude default props if specified, and anything the user specified.
                $ExcludeProps = @( Get-Exclude $ChildValue )

                #Get the children's children we care about, and their names.  Also look for signs of a hashtable like type
                $ChildrensChildren = $ChildValue.psobject.properties | Where-Object {$ExcludeProps -notcontains $_.Name }

                $HashKeys = if ($ChildValue.Keys -notlike $null -and $ChildValue.Values) {
                    $ChildValue.Keys
                } else {
                    $null
                }
                Write-Debug "Found children's children $($ChildrensChildren | Select-Object -ExpandProperty Name | Out-String)"
                #>
                #If we aren't at max depth or a leaf...
                if (
                    (@($ChildrensChildren).count -ne 0 -or $HashKeys) -and
                    $Depth -lt $MaxDepth
                ) {
                    #This handles hashtables.  But it won't recurse...
                    if ($HashKeys) {
                        Write-Verbose "Working on hashtable $CurrentPath"
                        foreach ($key in $HashKeys) {
                            Write-Verbose "Adding value from hashtable $CurrentPath['$key']"
                            $Output | Add-Member -MemberType NoteProperty -name "$CurrentPath['$key']" -value $ChildValue["$key"]
                            $Output = Recurse-Object -Object $ChildValue["$key"] -Path "$CurrentPath['$key']" -Output $Output -depth $depth
                        }
                    }
                    #Sub children?  Recurse!
                    else {
                        if ($IsArray) {
                            foreach ($item in @($ChildValue)) {
                                Write-Verbose "Recursing through array node '$CurrentPath'"
                                $Output = Recurse-Object -Object $item -Path "$CurrentPath[$count]" -Output $Output -depth $depth
                                $Count++
                            }
                        } else {
                            Write-Verbose "Recursing through node '$CurrentPath'"
                            $Output = Recurse-Object -Object $ChildValue -Path $CurrentPath -Output $Output -depth $depth
                        }
                    }
                }
            }

            $Output
        }

        #endregion FUNCTIONS
    }
    Process {
        Foreach ($Object in $InputObject) {
            #Flatten the XML and write it to the pipeline
            Recurse-Object -Object $Object -Output $( New-Object -TypeName PSObject )
        }
    }
}
function ConvertFrom-SID ($Sid) {
    $KnownSIDs = @{
        'S-1-0' = 'Null Authority'
        'S-1-0-0' = 'Nobody'
        'S-1-1' = 'World Authority'
        'S-1-1-0' = 'Everyone'
        'S-1-2' = 'Local Authority'
        'S-1-2-0' = 'Local'
        'S-1-2-1' = 'Console Logon'
        'S-1-3' = 'Creator Authority'
        'S-1-3-0' = 'Creator Owner'
        'S-1-3-1' = 'Creator Group'
        'S-1-3-2' = 'Creator Owner Server'
        'S-1-3-3' = 'Creator Group Server'
        'S-1-3-4' = 'Owner Rights'
        'S-1-5-80-0' = 'All Services'
        'S-1-4' = 'Non-unique Authority'
        'S-1-5' = 'NT Authority'
        'S-1-5-1' = 'Dialup'
        'S-1-5-2' = 'Network'
        'S-1-5-3' = 'Batch'
        'S-1-5-4' = 'Interactive'
        'S-1-5-6' = 'Service'
        'S-1-5-7' = 'Anonymous'
        'S-1-5-8' = 'Proxy'
        'S-1-5-9' = 'Enterprise Domain Controllers'
        'S-1-5-10' = 'Principal Self'
        'S-1-5-11' = 'Authenticated Users'
        'S-1-5-12' = 'Restricted Code'
        'S-1-5-13' = 'Terminal Server Users'
        'S-1-5-14' = 'Remote Interactive Logon'
        'S-1-5-15' = 'This Organization'
        'S-1-5-17' = 'This Organization'
        'S-1-5-18' = 'Local System'
        'S-1-5-19' = 'NT Authority'
        'S-1-5-20' = 'NT Authority'
        'S-1-5-32-544' = 'Administrators'
        'S-1-5-32-545' = 'Users'
        'S-1-5-32-546' = 'Guests'
        'S-1-5-32-547' = 'Power Users'
        'S-1-5-32-548' = 'Account Operators'
        'S-1-5-32-549' = 'Server Operators'
        'S-1-5-32-550' = 'Print Operators'
        'S-1-5-32-551' = 'Backup Operators'
        'S-1-5-32-552' = 'Replicators'
        'S-1-5-64-10' = 'NTLM Authentication'
        'S-1-5-64-14' = 'SChannel Authentication'
        'S-1-5-64-21' = 'Digest Authority'
        'S-1-5-80' = 'NT Service'
        'S-1-5-83-0' = 'NT VIRTUAL MACHINE\Virtual Machines'
        'S-1-16-0' = 'Untrusted Mandatory Level'
        'S-1-16-4096' = 'Low Mandatory Level'
        'S-1-16-8192' = 'Medium Mandatory Level'
        'S-1-16-8448' = 'Medium Plus Mandatory Level'
        'S-1-16-12288' = 'High Mandatory Level'
        'S-1-16-16384' = 'System Mandatory Level'
        'S-1-16-20480' = 'Protected Process Mandatory Level'
        'S-1-16-28672' = 'Secure Process Mandatory Level'
        'S-1-5-32-554' = 'BUILTIN\Pre-Windows 2000 Compatible Access'
        'S-1-5-32-555' = 'BUILTIN\Remote Desktop Users'
        'S-1-5-32-556' = 'BUILTIN\Network Configuration Operators'
        'S-1-5-32-557' = 'BUILTIN\Incoming Forest Trust Builders'
        'S-1-5-32-558' = 'BUILTIN\Performance Monitor Users'
        'S-1-5-32-559' = 'BUILTIN\Performance Log Users'
        'S-1-5-32-560' = 'BUILTIN\Windows Authorization Access Group'
        'S-1-5-32-561' = 'BUILTIN\Terminal Server License Servers'
        'S-1-5-32-562' = 'BUILTIN\Distributed COM Users'
        'S-1-5-32-569' = 'BUILTIN\Cryptographic Operators'
        'S-1-5-32-573' = 'BUILTIN\Event Log Readers'
        'S-1-5-32-574' = 'BUILTIN\Certificate Service DCOM Access'
        'S-1-5-32-575' = 'BUILTIN\RDS Remote Access Servers'
        'S-1-5-32-576' = 'BUILTIN\RDS Endpoint Servers'
        'S-1-5-32-577' = 'BUILTIN\RDS Management Servers'
        'S-1-5-32-578' = 'BUILTIN\Hyper-V Administrators'
        'S-1-5-32-579' = 'BUILTIN\Access Control Assistance Operators'
        'S-1-5-32-580' = 'BUILTIN\Remote Management Users'
    }
    foreach ($id in $sid) {
        if ($name = $KnownSIDs[$id]) { }
        else {
            #Try to translate the SID to an account
            Try {
                $objSID = New-Object System.Security.Principal.SecurityIdentifier($id)
                $name = ( $objSID.Translate([System.Security.Principal.NTAccount]) ).Value
            } Catch {
                $name = $sid # returns sid if unable to name
            }
        }
        return @{ SID = $id
            Name = $name
        }

    }

}

function Set-TimeLog([System.Diagnostics.Stopwatch] $Time) {
    $TimeToExecute = "$($ExecutionTime.Elapsed.Days) days, $($Time.Elapsed.Hours) hours, $($Time.Elapsed.Minutes) minutes, $($Time.Elapsed.Seconds) seconds, $($Time.Elapsed.Milliseconds) milliseconds"
    $Time.Stop()
    return $TimeToExecute
}

function Get-EventLogClearedLogs($Servers, $Dates) {

    $EventID = 1102
    $Events = @()
    foreach ($Server in $Servers) {
        $ExecutionTime = [System.Diagnostics.Stopwatch]::StartNew()
        $Events += Get-Events -Server $Server -DateFrom $Dates.DateFrom -DateTo $Dates.DateTo -EventID $EventID -LogType "Security" -ProviderName "Microsoft-Windows-Eventlog"
        $script:TimeToGenerateReports.Reports.IncludeClearedLogs.$($Server) = Set-TimeLog -Time $ExecutionTime
    }
    $EventsOutput = $Events | Select-Object @{label = 'Domain Controller'; expression = { $_.Computer}} ,
    @{label = 'Action'; expression = { ($_.Message -split '\n')[0] }},
    @{label = 'Who'; expression = { "$($_.SubjectDomainName)\$($_.SubjectUserName)" }},
    @{label = 'When'; expression = { $_.Date }},
    @{label = 'Event ID'; expression = { $_.ID }},
    @{label = 'Record ID'; expression = { $_.RecordId }}

    return $EventsOutput
}
function Get-GroupPolicyChanges ($Servers, $Dates) {
    $EventID = 5136, 5137, 5141
    # 5136 Group Policy changes, value changes, links, unlinks.
    # 5137 Group Policy creations.
    # 5141 Group Policy deletions.
    $GroupMembershipChanges = @()

    Write-Color @script:WriteParameters "[i] Running ", "Group Policy Changes Report", " for dates from: ", "$($Dates.DateFrom)", " to: ", "$($Dates.DateTo)", "." -Color White, Green, White, Green, White, Green, White
    foreach ($Server in $Servers) {
        $ExecutionTime = [System.Diagnostics.Stopwatch]::StartNew()

        $GroupMembershipChanges += Get-Events -Server $Server -DateFrom $Dates.DateFrom -DateTo $Dates.DateTo -EventID $EventID -LogName 'Security'

        $script:TimeToGenerateReports.Reports.IncludeGroupPolicyChanges.$($server) = Set-TimeLog -Time $ExecutionTime
    }
    $GroupMembershipChangesOutput = $GroupMembershipChanges
    <#
      $GroupMembershipChangesOutput = $GroupMembershipChanges | Select-Object @{label = 'Domain Controller'; expression = { $_.Computer}} ,
      @{label = 'Action'; expression = { ($_.Message -split '\n')[0] }},
      @{label = 'Group Name'; expression = { $_.TargetUserName }},
      @{label = 'Member Name'; expression = {$_.MemberName -replace '^CN=|,.*$' }},
      @{label = 'Who'; expression = { "$($_.SubjectDomainName)\$($_.SubjectUserName)" }},
      @{label = 'When'; expression = { $_.Date }},
      @{label = 'Event ID'; expression = { $_.ID }},
      @{label = 'Record ID'; expression = { $_.RecordId }}

      #$GroupMembershipChangesOutput = $GroupMembershipChangesOutput | Sort-Object When
    #>
    Write-Color @script:WriteParameters "[i] Ending ", "Group Policy Changes Report", " for dates from: ", "$($Dates.DateFrom)", " to: ", "$($Dates.DateTo)", "." -Color White, Green, White, Green, White, Green, White
    return $GroupMembershipChangesOutput
}
function Get-LogonEvents($Servers, $Dates) {

    Write-Color @script:WriteParameters "[i] Running ", "Logon Events Report", " for dates from: ", "$($Dates.DateFrom)", " to: ", "$($Dates.DateTo)", "." -Color White, Green, White, Green, White, Green, White

    # 4624: An account was successfully logged on
    # 4634: An account was logged off
    # 4647: User initiated logoff
    # 4672: Special privileges assigned to new logon                     https://www.ultimatewindowssecurity.com/securitylog/encyclopedia/event.aspx?eventid=4672


    $EventIDs = 4624 #, 4364, 4647, 4672
    $Events = @()
    foreach ($Server in $Servers) {
        $ExecutionTime = [System.Diagnostics.Stopwatch]::StartNew()

        $Events += Get-Events -Server $Server -DateFrom $Dates.DateFrom -DateTo $Dates.DateTo -EventID $EventIDs -ReportOptions $ReportOptions -LogType "Security"

        $script:TimeToGenerateReports.Reports.IncludeLogonEvents.$($server) = Set-TimeLog -Time $ExecutionTime
    }
    Write-Color @script:WriteParameters "[i] Ending ", "Logon Events Report", " for dates from: ", "$($Dates.DateFrom)", " to: ", "$($Dates.DateTo)", "." -Color White, Green, White, Green, White, Green, White
    return $Events
}
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
function Get-GroupCreateDelete($Servers, $Dates) {

    # 4727: A security-enabled global group was created                   https://www.ultimatewindowssecurity.com/securitylog/encyclopedia/event.aspx?eventID=4727
    # 4730: A security-enabled global group was deleted                   https://www.ultimatewindowssecurity.com/securitylog/encyclopedia/event.aspx?eventID=4730

    # 4731: A security-enabled local group was created                    https://www.ultimatewindowssecurity.com/securitylog/encyclopedia/event.aspx?eventID=4731
    # 4734: A security-enabled local group was deleted                    https://www.ultimatewindowssecurity.com/securitylog/encyclopedia/event.aspx?eventID=4734

    # 4759: A security-disabled universal group was created               https://www.ultimatewindowssecurity.com/securitylog/encyclopedia/event.aspx?eventID=4759
    # 4760: A security-disabled universal group was changed               https://www.ultimatewindowssecurity.com/securitylog/encyclopedia/event.aspx?eventID=4760

    # 4754: A security-enabled universal group was created.              https://www.ultimatewindowssecurity.com/securitylog/encyclopedia/event.aspx?eventID=4754
    # 4758: A security-enabled universal group was deleted                https://www.ultimatewindowssecurity.com/securitylog/encyclopedia/event.aspx?eventID=4756
    Write-Color @script:WriteParameters "[i] Running ", "Group Create/Delete Report", " for dates from: ", "$($Dates.DateFrom)", " to: ", "$($Dates.DateTo)", "." -Color White, Green, White, Green, White, Green, White
    $GroupMembershipChangesEventID = 4727, 4730, 4731, 4734, 4759, 4760, 4754, 4758
    foreach ($Server in $Servers) {
        $ExecutionTime = [System.Diagnostics.Stopwatch]::StartNew()
        $GroupMembershipChanges = Get-Events -Server $Server -DateFrom $Dates.DateFrom -DateTo $Dates.DateTo -EventID $GroupMembershipChangesEventID -LogName 'Security'

        $script:TimeToGenerateReports.Reports.IncludeGroupCreateDelete.$($server) = Set-TimeLog -Time $ExecutionTime
    }
    $GroupMembershipChangesOutput = $GroupMembershipChanges | Select-Object @{label = 'Domain Controller'; expression = { $_.Computer}} ,
    @{label = 'Action'; expression = { ($_.Message -split '\n')[0] }},
    @{label = 'Group Name'; expression = { $_.TargetUserName }},
    @{label = 'Member Name'; expression = {$_.MemberName -replace '^CN=|,.*$' }},
    @{label = 'Who'; expression = { "$($_.SubjectDomainName)\$($_.SubjectUserName)" }},
    @{label = 'When'; expression = { $_.Date }},
    @{label = 'Event ID'; expression = { $_.ID }},
    @{label = 'Record ID'; expression = { $_.RecordId }}
    $GroupMembershipChangesOutput = $GroupMembershipChangesOutput | Sort-Object When
    Write-Color @script:WriteParameters "[i] Ending ", "Group Create/Delete Report", " for dates from: ", "$($Dates.DateFrom)", " to: ", "$($Dates.DateTo)", "." -Color White, Green, White, Green, White, Green, White
    return $GroupMembershipChangesOutput
}
function Get-GroupMembershipChanges($Servers, $Dates) {

    # Events processed
    # 4728: A member was added to a security-enabled global group -       https://www.ultimatewindowssecurity.com/securitylog/encyclopedia/event.aspx?eventID=4728
    # 4729: A member was removed from a security-enabled global group     https://www.ultimatewindowssecurity.com/securitylog/encyclopedia/event.aspx?eventID=4729
    # 4732: A member was added to a security-enabled local group -  -     https://www.ultimatewindowssecurity.com/securitylog/encyclopedia/event.aspx?eventID=4732
    # 4733: A member was removed from a security-enabled local group -    https://www.ultimatewindowssecurity.com/securitylog/encyclopedia/event.aspx?eventID=4733
    # 4756: A member was added to a security-enabled universal group      https://www.ultimatewindowssecurity.com/securitylog/encyclopedia/event.aspx?eventID=4756
    # 4757: A member was removed from a security-enabled universal group  https://www.ultimatewindowssecurity.com/securitylog/encyclopedia/event.aspx?eventID=4757
    # 4761: A member was added to a security-disabled universal group     https://www.ultimatewindowssecurity.com/securitylog/encyclopedia/event.aspx?eventID=4761
    # 4762: A member was removed from a security-disabled universal group https://www.ultimatewindowssecurity.com/securitylog/encyclopedia/event.aspx?eventID=4762

    Write-Color @script:WriteParameters "[i] Running ", "Group Membership Changes Report", " for dates from: ", "$($Dates.DateFrom)", " to: ", "$($Dates.DateTo)", "." -Color White, Green, White, Green, White, Green, White
    $GroupMembershipChangesEventID = 4728, 4729, 4732, 4733, 4756, 4757, 4761, 4762
    $GroupMembershipChanges = @()
    foreach ($Server in $Servers) {
        $ExecutionTime = [System.Diagnostics.Stopwatch]::StartNew()
        $GroupMembershipChanges += Get-Events -Server $Server -DateFrom $Dates.DateFrom -DateTo $Dates.DateTo -EventID $GroupMembershipChangesEventID -LogName 'Security'

        $script:TimeToGenerateReports.Reports.IncludeGroupEvents.$($server) = Set-TimeLog -Time $ExecutionTime
    }
    $GroupMembershipChangesOutput = $GroupMembershipChanges | Select-Object @{label = 'Domain Controller'; expression = { $_.Computer}} ,
    @{label = 'Action'; expression = { ($_.Message -split '\n')[0] }},
    @{label = 'Group Name'; expression = { $_.TargetUserName }},
    @{label = 'Member Name'; expression = {$_.MemberName -replace '^CN=|,.*$' }},
    @{label = 'Who'; expression = { "$($_.SubjectDomainName)\$($_.SubjectUserName)" }},
    @{label = 'When'; expression = { $_.Date }},
    @{label = 'Event ID'; expression = { $_.ID }},
    @{label = 'Record ID'; expression = { $_.RecordId }}
    $GroupMembershipChangesOutput = $GroupMembershipChangesOutput | Sort-Object When
    Write-Color @script:WriteParameters "[i] Ending ", "Group Membership Changes Report", " for dates from: ", "$($Dates.DateFrom)", " to: ", "$($Dates.DateTo)", "." -Color White, Green, White, Green, White, Green, White
    return $GroupMembershipChangesOutput
}
function Get-UserStatuses($Servers, $Dates) {

    Write-Color @script:WriteParameters "[i] Running ", "User Statues Report", " for dates from: ", "$($Dates.DateFrom)", " to: ", "$($Dates.DateTo)", "." -Color White, Green, White, Green, White, Green, White
    $UserChangesID = 4722, 4725, 4767, 4723, 4724, 4726
    $UserChanges = @()
    foreach ($Server in $Servers) {
        $ExecutionTime = [System.Diagnostics.Stopwatch]::StartNew()

        $UserChanges += Get-Events -Server $Server -DateFrom $Dates.DateFrom -DateTo $Dates.DateTo -EventID $UserChangesID -LogName 'Security'

        $script:TimeToGenerateReports.Reports.IncludeUserStatuses.$($server) = Set-TimeLog -Time $ExecutionTime
    }
    $UserChangesOutput = $UserChanges | Select-Object @{label = 'Domain Controller'; expression = { $_.Computer}} ,
    @{label = 'Action'; expression = { ($_.Message -split '\n')[0] }},
    @{label = 'User Affected'; expression = { "$($_.TargetDomainName)\$($_.TargetUserName)" }},
    @{label = 'Who'; expression = { "$($_.SubjectDomainName)\$($_.SubjectUserName)" }},
    @{label = 'When'; expression = { $_.Date }},
    @{label = 'Event ID'; expression = { $_.ID }},
    @{label = 'Record ID'; expression = { $_.RecordId }}
    $UserChangesOutput = $UserChangesOutput | Sort-Object Whacen
    Write-Color @script:WriteParameters "[i] Ending ", "User Statues Report", " for dates from: ", "$($Dates.DateFrom)", " to: ", "$($Dates.DateTo)", "." -Color White, Green, White, Green, White, Green, White
    return $UserChangesOutput
}
function Get-UserLockouts($Servers, $Dates) {

    Write-Color @script:WriteParameters "[i] Running ", "User Lockouts Report", " for dates from: ", "$($Dates.DateFrom)", " to: ", "$($Dates.DateTo)", "." -Color White, Green, White, Green, White, Green, White
    $UserChangesID = 4740
    $UserChanges = @()
    foreach ($server in $servers) {
        $ExecutionTime = [System.Diagnostics.Stopwatch]::StartNew()

        $UserChanges += Get-Events -Computer $Server -DateFrom $Dates.DateFrom -DateTo $Dates.DateTo -EventID $UserChangesID -LogName 'Security'

        $script:TimeToGenerateReports.Reports.IncludeUserLockouts.$($server) = Set-TimeLog -Time $ExecutionTime
    }
    $UserChangesOutput = $UserChanges | Select-Object @{label = 'Domain Controller'; expression = { $_.Computer}} ,
    @{label = 'Action'; expression = { ($_.Message -split '\n')[0] }},
    @{label = 'Computer Lockout On'; expression = { "$($_.TargetDomainName)" }},
    @{label = 'User Affected'; expression = { "$($_.TargetUserName)" }},
    @{label = 'Reported By'; expression = { "$($_.SubjectDomainName)\$($_.SubjectUserName)" }},
    @{label = 'When'; expression = { ($_.Date) }},
    @{label = 'Event ID'; expression = { $_.ID }},
    @{label = 'Record ID'; expression = { $_.RecordId }}
    $UserChangesOutput = $UserChangesOutput | Sort-Object When
    Write-Color @script:WriteParameters "[i] Ending ", "User Lockouts Report", " for dates from: ", "$($Dates.DateFrom)", " to: ", "$($Dates.DateTo)", "." -Color White, Green, White, Green, White, Green, White
    return $UserChangesOutput

}
function Get-UserChanges($Servers, $Dates) {

    Write-Color @script:WriteParameters "[i] Running ", "User Changes Report", " for dates from: ", "$($Dates.DateFrom)", " to: ", "$($Dates.DateTo)", "." -Color White, Green, White, Green, White, Green, White
    $userChangesCleanedUp = @()
    $UserChangesID = 4720, 4738
    $UserChanges = @()
    foreach ($server in $servers) {
        $ExecutionTime = [System.Diagnostics.Stopwatch]::StartNew()
        $UserChanges += Get-Events -Computer $Server -DateFrom $($Dates.DateFrom) -DateTo $($Dates.DateTo) -EventID $UserChangesID -LogName 'Security'

        $script:TimeToGenerateReports.Reports.IncludeUserEvents.$($server) = Set-TimeLog -Time $ExecutionTime
    }
    # Cleanup Anonymous LOGON (usually related to password events)
    # https://social.technet.microsoft.com/Forums/en-US/5b2a93f7-7101-43c1-ab53-3a51b2e05693/eventid-4738-user-account-was-changed-by-anonymous?forum=winserverDS
    #$userChanges

    foreach ($u in $UserChanges) {
        if ($u.SubjectUserName -eq "ANONYMOUS LOGON") { }
        else { $userChangesCleanedUp += $u }
    }
    $UserChangesOutput = $userChangesCleanedUp | Select-Object @{label = 'Domain Controller'; expression = { $_.Computer}} ,
    @{label = 'Action'; expression = { ($_.Message -split '\n')[0] }},
    @{label = 'User Affected'; expression = { "$($_.TargetDomainName)\$($_.TargetUserName)" }},
    @{label = 'SamAccountName'; expression = { $_.SamAccountName }},
    @{label = 'Display Name'; expression = { $_.DisplayName }},
    @{label = 'UserPrincipalName'; expression = { $_.UserPrincipalName }},
    @{label = 'Home Directory'; expression = { $_.HomeDirectory }},
    @{label = 'Home Path'; expression = { $_.HomePath }},
    @{label = 'Script Path'; expression = { $_.ScriptPath }},
    @{label = 'Profile Path'; expression = { $_.ProfilePath }},
    @{label = 'User Workstations'; expression = { $_.UserWorkstations }},
    @{label = 'Password Last Set'; expression = { $_.PasswordLastSet }},
    @{label = 'Account Expires'; expression = { $_.AccountExpires }},
    @{label = 'Primary Group Id'; expression = { $_.PrimaryGroupId }},
    @{label = 'Allowed To Delegate To'; expression = { $_.AllowedToDelegateTo }},
    @{label = 'Old Uac Value'; expression = { Convert-UAC $_.OldUacValue }},
    @{label = 'New Uac Value'; expression = { Convert-UAC $_.NewUacValue }},
    @{label = 'User Account Control'; expression = {
            foreach ($u in $_.UserAccountControl) {
                Convert-UAC ($u -replace "%%", "")
            }
        }
    },
    @{label = 'User Parameters'; expression = { $_.UserParameters }},
    @{label = 'Sid History'; expression = { $_.SidHistory }},
    @{label = 'Logon Hours'; expression = { $_.LogonHours }},
    @{label = 'Who'; expression = { "$($_.SubjectDomainName)\$($_.SubjectUserName)" }},
    @{label = 'When'; expression = { $_.Date }},
    @{label = 'Event ID'; expression = { $_.ID }},
    @{label = 'Record ID'; expression = { $_.RecordId }}
    $UserChangesOutput = $UserChangesOutput | Sort-Object When
    Write-Color @script:WriteParameters "[i] Ending ", "User Changes Report", " for dates from: ", "$($Dates.DateFrom)", " to: ", "$($Dates.DateTo)", "." -Color White, Green, White, Green, White, Green, White
    return $UserChangesOutput
}
function Send-Email ([hashtable] $EmailParameters, [string] $Body = "", $Attachment = $null, [string] $Subject = "", $To = "") {
    #     $SendMail = Send-Email -EmailParameters $EmailParameters -Body $EmailBody -Attachment $Reports -Subject $TemporarySubject
    #  Preparing the Email properties
    $SmtpClient = New-Object -TypeName system.net.mail.smtpClient
    $SmtpClient.host = $EmailParameters.EmailServer

    # Adding parameters to login to server
    $SmtpClient.Port = $EmailParameters.EmailServerPort
    if ($EmailParameters.EmailServerLogin -ne "") {
        $SmtpClient.Credentials = New-Object System.Net.NetworkCredential($EmailParameters.EmailServerLogin, $EmailParameters.EmailServerPassword)
    }
    $SmtpClient.EnableSsl = $EmailParameters.EmailServerEnableSSL
    $MailMessage = New-Object -TypeName system.net.mail.mailmessage
    $MailMessage.From = $EmailParameters.EmailFrom
    if ($To -ne "") {
        foreach ($T in $To) { $MailMessage.To.add($($T)) }
    } else {
        if ($EmailParameters.Emailto -ne "") {
            foreach ($To in $EmailParameters.Emailto) { $MailMessage.To.add($($To)) }
        }
    }
    if ($EmailParameters.EmailCC -ne "") {
        foreach ($CC in $EmailParameters.EmailCC) { $MailMessage.CC.add($($CC)) }
    }
    if ($EmailParameters.EmailBCC -ne "") {
        foreach ($BCC in $EmailParameters.EmailBCC) { $MailMessage.BCC.add($($BCC)) }
    }
    $Exists = Test-Key $EmailParameters "EmailParameters" "EmailReplyTo" -DisplayProgress $false
    if ($Exists -eq $true) {
        if ($EmailParameters.EmailReplyTo -ne "") {
            $MailMessage.ReplyTo = $EmailParameters.EmailReplyTo
        }
    }
    $MailMessage.IsBodyHtml = 1
    if ($Subject -eq "") {
        $MailMessage.Subject = $EmailParameters.EmailSubject
    } else {
        $MailMessage.Subject = $Subject
    }
    $MailMessage.Body = $Body
    $MailMessage.Priority = [System.Net.Mail.MailPriority]::$($EmailParameters.EmailPriority)

    #  Encoding
    $MailMessage.BodyEncoding = [System.Text.Encoding]::$($EmailParameters.EmailEncoding)
    $MailMessage.SubjectEncoding = [System.Text.Encoding]::$($EmailParameters.EmailEncoding)

    #  Attaching file (s)
    if ($Attachment -ne $null) {
        foreach ($Attach in $Attachment) {
            if (Test-Path $Attach) {
                $File = new-object Net.Mail.Attachment($Attach)
                $MailMessage.Attachments.Add($File)
            }
        }
    }

    #  Sending the Email
    try {
        $SmtpClient.Send($MailMessage)
        #$att.Dispose();
        $MailMessage.Dispose();
        return @{
            Status = $True
            Error = ""
        }
    } catch {
        $MailMessage.Dispose();
        return @{
            Status = $False
            Error = $($_.Exception.Message)
        }
    }

}
function Find-DatesQuarterLast ([bool] $Force) {
    #https://blogs.technet.microsoft.com/dsheehan/2017/09/21/use-powershell-to-determine-the-first-day-of-the-current-calendar-quarter/
    $Today = (Get-Date).AddDays(-90)
    $Yesterday = ((Get-Date).AddDays(-1))
    $Quarter = [Math]::Ceiling($Today.Month / 3)
    $LastDay = [DateTime]::DaysInMonth([Int]$Today.Year.ToString(), [Int]($Quarter * 3))
    $StartDate = (get-date -Year $Today.Year -Month ($Quarter * 3 - 2) -Day 1).Date
    $EndDate = (get-date -Year $Today.Year -Month ($Quarter * 3) -Day $LastDay).Date.AddDays(1).AddTicks(-1)

    if ($Force -eq $true -or $Yesterday.Date -eq $EndDate.Date) {
        $DateParameters = @{
            DateFrom = $StartDate
            DateTo = $EndDate
        }
        return $DateParameters
    } else {
        return $null
    }
}
function Find-DatesQuarterCurrent ([bool] $Force) {
    $Today = (Get-Date)
    $Quarter = [Math]::Ceiling($Today.Month / 3)
    $LastDay = [DateTime]::DaysInMonth([Int]$Today.Year.ToString(), [Int]($Quarter * 3))
    $StartDate = (get-date -Year $Today.Year -Month ($Quarter * 3 - 2) -Day 1).Date
    $EndDate = (get-date -Year $Today.Year -Month ($Quarter * 3) -Day $LastDay).Date.AddDays(1).AddTicks(-1)
    $DateParameters = @{
        DateFrom = $StartDate
        DateTo = $EndDate
    }
    return $DateParameters
}
function Find-DatesMonthPast ([bool] $Force) {
    $DateToday = (Get-Date).Date
    $DateMonthFirstDay = (GET-DATE -Day 1).Date
    $DateMonthPreviousFirstDay = $DateMonthFirstDay.AddMonths(-1)

    if ($Force -eq $true -or $DateToday -eq $DateMonthFirstDay) {
        $DateParameters = @{
            DateFrom = $DateMonthPreviousFirstDay
            DateTo = $DateMonthFirstDay
        }
        return $DateParameters
    } else {
        return $null
    }
}
function Find-DatesMonthCurrent () {
    $DateMonthFirstDay = (GET-DATE -Day 1).Date
    $DateMonthLastDay = GET-DATE $DateMonthFirstDay.AddMonths(1).AddSeconds(-1)

    $DateParameters = @{
        DateFrom = $DateMonthFirstDay
        DateTo = $DateMonthLastDay
    }
    return $DateParameters
}
function Find-DatesDayPrevious () {
    $DateToday = (GET-DATE).Date
    $DateYesterday = $DateToday.AddDays(-1)

    $DateParameters = @{
        DateFrom = $DateYesterday
        DateTo = $dateToday
    }
    return $DateParameters
}
function Find-DatesDayToday () {
    $DateToday = (GET-DATE).Date
    $DateTodayEnd = $DateToday.AddDays(1).AddSeconds(-1)

    $DateParameters = @{
        DateFrom = $DateToday
        DateTo = $DateTodayEnd
    }
    return $DateParameters
}
function Find-DatesPastHour () {
    $DateTodayEnd = Get-Date -Minute 0 -Second 0 -Millisecond 0
    $DateTodayStart = $DateTodayEnd.AddHours(-1)

    $DateParameters = @{
        DateFrom = $DateTodayStart
        DateTo = $DateTodayEnd
    }
    return $DateParameters
}
function Find-DatesCurrentHour () {
    $DateTodayStart = (Get-Date -Minute 0 -Second 0 -Millisecond 0)
    $DateTodayEnd = $DateTodayStart.AddHours(1)

    $DateParameters = @{
        DateFrom = $DateTodayStart
        DateTo = $DateTodayEnd
    }
    return $DateParameters
}
function Find-DatesCurrentDayMinusDayX ($days) {
    $DateTodayStart = (Get-Date -Hour 0 -Minute 0 -Second 0 -Millisecond 0).AddDays( - $Days)
    $DateTodayEnd = (Get-Date -Hour 0 -Minute 0 -Second 0 -Millisecond 0).AddDays(1).AddDays( - $Days).AddMilliseconds(-1)

    $DateParameters = @{
        DateFrom = $DateTodayStart
        DateTo = $DateTodayEnd
    }
    return $DateParameters
}
function Find-DatesCurrentDayMinuxDaysX ($days) {
    $DateTodayStart = (Get-Date -Hour 0 -Minute 0 -Second 0 -Millisecond 0).AddDays( - $Days)
    $DateTodayEnd = (Get-Date -Hour 0 -Minute 0 -Second 0 -Millisecond 0).AddDays(1).AddMilliseconds(-1)

    $DateParameters = @{
        DateFrom = $DateTodayStart
        DateTo = $DateTodayEnd
    }
    return $DateParameters
}
function Find-DatesPastWeek($DayName) {
    $DateTodayStart = Get-Date -Hour 0 -Minute 0 -Second 0 -Millisecond 0
    if ($DateTodayStart.DayOfWeek -ne $DayName) {
        return $null
    }
    $DateTodayEnd = (Get-Date -Hour 0 -Minute 0 -Second 0 -Millisecond 0).AddDays(-7)
    $DateParameters = @{
        DateFrom = $DateTodayEnd
        DateTo = $DateTodayStart
    }
    return $DateParameters

}
function Set-ReportFileName($ReportOptions, $ReportExtension, $ReportName = "") {
    $ReportTime = $(get-date -f $ReportOptions.FilePatternDateFormat)
    if ($ReportOptions.KeepReportsPath -ne "") { $Path = $ReportOptions.KeepReportsPath} else { $Path = $env:TEMP }
    $ReportPath = $Path + "\" + $ReportOptions.FilePattern
    $ReportPath = $ReportPath -replace "<currentdate>", $ReportTime
    if ($ReportName -ne "") {
        $ReportPath = $ReportPath.Replace(".<extension>", "-$ReportName.$ReportExtension")
    } else {
        $ReportPath = $ReportPath.Replace(".<extension>", ".$ReportExtension")
    }
    return $ReportPath
}
function Convert-Size {
    # Original - https://techibee.com/powershell/convert-from-any-to-any-bytes-kb-mb-gb-tb-using-powershell/2376
    #
    # Changelog - Modified 30.03.2018 - przemyslaw.klys at evotec.pl
    # - Added $Display Switch
    [cmdletbinding()]
    param(
        [validateset("Bytes", "KB", "MB", "GB", "TB")]
        [string]$From,
        [validateset("Bytes", "KB", "MB", "GB", "TB")]
        [string]$To,
        [Parameter(Mandatory = $true)]
        [double]$Value,
        [int]$Precision = 4,
        [switch]$Display
    )
    switch ($From) {
        "Bytes" {$value = $Value }
        "KB" {$value = $Value * 1024 }
        "MB" {$value = $Value * 1024 * 1024}
        "GB" {$value = $Value * 1024 * 1024 * 1024}
        "TB" {$value = $Value * 1024 * 1024 * 1024 * 1024}
    }

    switch ($To) {
        "Bytes" {return $value}
        "KB" {$Value = $Value / 1KB}
        "MB" {$Value = $Value / 1MB}
        "GB" {$Value = $Value / 1GB}
        "TB" {$Value = $Value / 1TB}

    }
    if ($Display) {
        return "$([Math]::Round($value,$Precision,[MidPointRounding]::AwayFromZero)) $To"
    } else {
        return [Math]::Round($value, $Precision, [MidPointRounding]::AwayFromZero)
    }

}
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
function Set-EmailHead($FormattingOptions) {
    $Head = "<style>" +
    "BODY{background-color:white;font-family:$($FormattingOptions.FontFamily);font-size:$($FormattingOptions.FontSize)}" +
    "TABLE{border-width: 1px;border-style: solid;border-color: black;border-collapse: collapse}" +
    "TH{border-width: 1px;padding: 3px;border-style: solid;border-color: black;background-color:`"#00297A`";font-color:white}" +
    "TD{border-width: 1px;padding-right: 2px;padding-left: 2px;padding-top: 0px;padding-bottom: 0px;border-style: solid;border-color: black;background-color:white}" +
    "H2{font-family:$($FormattingOptions.FontHeadingFamily);font-size:$($FormattingOptions.FontHeadingSize)}" +
    "P{font-family:$($FormattingOptions.FontFamily);font-size:$($FormattingOptions.FontSize)}" +
    "</style>"
    return $Head
}
function Set-EmailBody($TableData, $TableWelcomeMessage) {
    $body = "<p><i>$TableWelcomeMessage</i>"
    if ($($TableData | Measure-Object).Count -gt 0) {
        $body += $TableData | ConvertTo-Html -Fragment | Out-String
        $body = $body -replace " Added", "<font color=`"green`"><b> Added</b></font>"
        $body = $body -replace " Removed", "<font color=`"red`"><b> Removed</b></font>"
        $body = $body -replace " Deleted", "<font color=`"red`"><b> Deleted</b></font>"
        $body = $body -replace " Changed", "<font color=`"blue`"><b> Changed</b></font>"
        $body = $body -replace " Change", "<font color=`"blue`"><b> Change</b></font>"
        $body = $body -replace " Disabled", "<font color=`"red`"><b> Disabled</b></font>"
        $body = $body -replace " Enabled", "<font color=`"green`"><b> Enabled</b></font>"
        $body = $body -replace " Locked out", "<font color=`"red`"><b> Locked out</b></font>"
        $body = $body -replace " Lockouts", "<font color=`"red`"><b> Lockouts</b></font>"
        $body = $body -replace " Unlocked", "<font color=`"green`"><b> Unlocked</b></font>"
        $body = $body -replace " Reset", "<font color=`"blue`"><b> Reset</b></font>"
        $body += "</p>"
    } else {
        $body += "<br><i>No changes happend during that period.</i></p>"
    }
    return $body
}
function Set-EmailBodyPreparedTable ($TableData, $TableWelcomeMessage) {
    $body = "<p><i>$TableWelcomeMessage</i>"
    $body += $TableData
    return $body
}
function Set-EmailReportBrading($FormattingOptions) {
    $Report = "<a style=`"text-decoration:none`" href=`"$($FormattingOptions.CompanyBranding.Link)`" class=`"clink logo-container`">" +
    #"<img width=171 height=15 src=`"$($FormattingOptions.CompanyLogo)`" border=`"0`" class=`"company-logo`" alt=`"company-logo`">" +
    "<img width=<fix> height=<fix> src=`"$($FormattingOptions.CompanyBranding.Logo)`" border=`"0`" class=`"company-logo`" alt=`"company-logo`">" +
    "</a>"
    if ($FormattingOptions.CompanyBranding.Width -ne "") {
        $report = $report -replace "width=<fix>", "width=$($FormattingOptions.CompanyBranding.Width)"
    } else {
        $report = $report -replace "width=<fix>", ""
    }
    if ($FormattingOptions.CompanyBranding.Height -ne "") {
        $report = $report -replace "height=<fix>", "height=$($FormattingOptions.CompanyBranding.Height)"
    } else {
        $report = $report -replace "height=<fix>", ""
    }
    return $Report
}
function Set-EmailReportDetails($FormattingOptions, $Dates) {
    $DateReport = get-date
    # HTML Report settings
    $Report = "<p style=`"background-color:white;font-family:$($FormattingOptions.FontFamily);font-size:$($FormattingOptions.FontSize)`">" +
    "<strong>Report Time:</strong> $DateReport <br>" +
    "<strong>Report Period:</strong> $($Dates.DateFrom) to $($Dates.DateTo) <br>" +
    "<strong>Account Executing Report :</strong> $env:userdomain\$($env:username.toupper()) on $($env:ComputerName.toUpper()) <br>" +
    "<strong>Time to generate:</strong> **TimeToGenerateDays** days, **TimeToGenerateHours** hours, **TimeToGenerateMinutes** minutes, **TimeToGenerateSeconds** seconds, **TimeToGenerateMilliseconds** milliseconds"
    "</p>"
    return $Report
}
function Set-EmailWordReplacements($Body, $Replace, $ReplaceWith, [switch] $RegEx) {
    if ($RegEx) {
        $Body = $Body -Replace $Replace, $ReplaceWith
    } else {
        $Body = $Body.Replace($Replace, $ReplaceWith)
    }
    return $Body
}
function Get-HTML($text) {
    $text = $text.Split("`r")
    foreach ($t in $text) {
        Write-Host $t
    }
}
function Set-TimeReports ($HashTable) {
    # Get all report Names
    $Reports = @()
    foreach ($reportName in $($HashTable.GetEnumerator().Name)) {
        $Reports += $reportName
    }

    # Get Highest Count of servers
    $Count = 0
    foreach ($reportName in $reports) {
        if ($($HashTable[$reportName]).Count -ge $Count) {
            $Count = $($HashTable[$reportName]).Count
        }
    }
    $Count = $Count - 1 # Removes Total from Server Count

    $htmlStart = @"
    <table border="0" cellpadding="3" style="font-size:8pt;font-family:Segoe UI,Arial,sans-serif">
        <tr bgcolor="#009900">
            <th colspan="1">
                <font color="#ffffff">Report Names</font>
            </th>
            <th colspan="1">
                <font color="#ffffff">Total</font>
            </th>
            <th colspan="$Count">
                <font color="#ffffff">Servers</font>
            </th>
        </tr>
"@

    $htmlStart += '<tr bgcolor="#00CC00">'
    $htmlStart += '<th></th>'
    $htmlStart += '<th></th>'

    #$HashTable.GetEnumerator()
    foreach ($reportName in $reports) {
        if ($($HashTable[$reportName]).Count -eq $($Count + 1)) {
            foreach ($server in $($HashTable[$reportName].GetEnumerator().Name)) {
                if ($server -ne 'Total') {
                    $htmlStart += '<th>' + $server + '</th>'
                }
            }
            break;
        }
    }
    $htmlStart += '</tr>'

    #
    foreach ($reportName in $reports) {
        $htmlStart += '<tr align="left" bgcolor="#dddddd">'

        $htmlStart += '<td>' + $reportName + '</td>'

        foreach ($ElapsedTime in $($HashTable[$reportName].GetEnumerator())) {

            # Write-Color -Text $($ElapsedTime.Value) -Color Red
            $htmlStart += '<td>' + $($ElapsedTime.Value) + '</td>'
        }
        $htmlStart += '</tr>'
    }

    $htmlStart += '</table>'


    return $htmlStart
}

function Get-DomainControllers($Servers) {
    foreach ($server in $servers) {
        $ExecTime = [System.Diagnostics.Stopwatch]::StartNew() # Timer Start
        if ($server.OperatingSystem -like "*2003*" -or $server.OperatingSystem -like "*2000*") {
            #Add-Member -InputObject $server -MemberType NoteProperty -Name "Supported" -Value "No"
            $server.Supported = "No"
        } else {
            #Add-Member -InputObject $server -MemberType NoteProperty -Name "Supported" -Value "Yes"
            $server.Supported = "Yes"
        }

        $TimeReport = "$($ExecTime.Elapsed.Days) days, $($ExecTime.Elapsed.Hours) hours, $($ExecTime.Elapsed.Minutes) minutes, $($ExecTime.Elapsed.Seconds) seconds, $($ExecTime.Elapsed.Milliseconds) milliseconds"
        $script:TimeToGenerateReports.Reports.IncludeDomainControllers.$($server.HostName) = $TimeReport
        $ExecTime.Stop()
    }
    $ServersTable = $Servers
    return $ServersTable
}

function Start-Report([hashtable] $Dates, [hashtable] $EmailParameters, [hashtable] $ReportOptions, [hashtable] $FormattingOptions, $Servers) {
    $time = [System.Diagnostics.Stopwatch]::StartNew() # Timer Start
    # Declare variables
    $EventLogTable = @()
    $GroupsEventsTable = @()
    $UsersEventsTable = @()
    $UsersEventsStatusesTable = @()
    $UsersLockoutsTable = @()
    $LogonEvents = @()
    $RebootEventsTable = @()
    $TableGroupPolicyChanges = @()
    $TableEventLogClearedLogs = @()
    $ServersTable = @()
    $GroupCreateDeleteTable = @()
    $TableExecutionTimes = ''

    # Prepare email body
    $EmailBody = Set-EmailHead  -FormattingOptions $FormattingOptions
    $EmailBody += Set-EmailReportBrading -FormattingOptions $FormattingOptions
    $EmailBody += Set-EmailReportDetails -FormattingOptions $FormattingOptions -Dates $Dates

    # Load all events if required
    if ($ReportOptions.IncludeDomainControllers -eq $true) {
        $ExecutionTime = [System.Diagnostics.Stopwatch]::StartNew() # Timer Start

        $ServersTable = Get-DomainControllers -Servers $Servers

        $script:TimeToGenerateReports.Reports.IncludeDomainControllers.Total = Set-TimeLog -Time $ExecutionTime
    }
    $Servers = $Servers | Where-Object { $_.OperatingSystem -notlike "*2003*" -and $_.OperatingSystem -notlike "*2000*" }
    $Servers = $Servers.Hostname

    If ($ReportOptions.IncludeClearedLogs -eq $true) {
        $ExecutionTime = [System.Diagnostics.Stopwatch]::StartNew() # Timer Start
        Write-Color @script:WriteParameters "[i] Running ", "Who Cleared Logs Report", " for dates from: ", "$($Dates.DateFrom)", " to: ", "$($Dates.DateTo)", "." -Color White, Green, White, Green, White, Green, White
        $TableEventLogClearedLogs = Get-EventLogClearedLogs -Servers $Servers -Dates $Dates
        Write-Color @script:WriteParameters "[i] Ending ", "Who Cleared Logs Report", " for dates from: ", "$($Dates.DateFrom)", " to: ", "$($Dates.DateTo)", "." -Color White, Green, White, Green, White, Green, White
        $script:TimeToGenerateReports.Reports.IncludeClearedLogs.Total = Set-TimeLog -Time $ExecutionTime
    }
    If ($ReportOptions.IncludeEventLogSize.Use -eq $true) {
        $ExecutionTime = [System.Diagnostics.Stopwatch]::StartNew() # Timer St
        foreach ($LogName in $ReportOptions.IncludeEventLogSize.Logs) {
            Write-Color @script:WriteParameters "[i] Running ", "Event Log Size Report", " for event log ", "$LogName" -Color White, Green, White, Yellow
            $EventLogTable = Get-EventLogSize -Servers $Servers -LogName $LogName
            Write-Color @script:WriteParameters "[i] Ending ", "Event Log Size Report", " for event log ", "$LogName" -Color White, Green, White, Yellow
        }
        if ($ReportOptions.IncludeEventLogSize.SortBy -ne "") { $EventLogTable = $EventLogTable | Sort-Object $ReportOptions.IncludeEventLogSize.SortBy }
        $script:TimeToGenerateReports.Reports.IncludeEventLogSize.Total = Set-TimeLog -Time $ExecutionTime
    }
    if ($ReportOptions.IncludeGroupEvents -eq $true) {
        $ExecutionTime = [System.Diagnostics.Stopwatch]::StartNew() # Timer St
        $GroupsEventsTable = Get-GroupMembershipChanges -Servers $Servers -Dates $Dates
        $script:TimeToGenerateReports.Reports.IncludeGroupEvents.Total = Set-TimeLog -Time $ExecutionTime
    }
    if ($ReportOptions.IncludeUserEvents -eq $true) {
        $ExecutionTime = [System.Diagnostics.Stopwatch]::StartNew() # Timer
        $UsersEventsTable = Get-UserChanges -Servers $Servers -Dates $Dates
        $script:TimeToGenerateReports.Reports.IncludeUserEvents.Total = Set-TimeLog -Time $ExecutionTime
    }
    if ($ReportOptions.IncludeUserStatuses -eq $true) {
        $ExecutionTime = [System.Diagnostics.Stopwatch]::StartNew() # Timer
        $UsersEventsStatusesTable = Get-UserStatuses -Servers $Servers -Dates $Dates
        $script:TimeToGenerateReports.Reports.IncludeUserStatuses.Total = Set-TimeLog -Time $ExecutionTime
    }
    If ($ReportOptions.IncludeUserLockouts -eq $true) {
        $ExecutionTime = [System.Diagnostics.Stopwatch]::StartNew() # Timer
        $UsersLockoutsTable = Get-UserLockouts -Servers $Servers -Dates $Dates
        $script:TimeToGenerateReports.Reports.IncludeUserLockouts.Total = Set-TimeLog -Time $ExecutionTime
    }
    if ($ReportOptions.IncludeLogonEvents -eq $true) {
        $ExecutionTime = [System.Diagnostics.Stopwatch]::StartNew() # Timer
        $LogonEvents = Get-LogonEvents -Servers $Servers -Dates $Dates
        $script:TimeToGenerateReports.Reports.IncludeLogonEvents.Total = Set-TimeLog -Time $ExecutionTime
    }
    if ($ReportOptions.IncludeGroupCreateDelete -eq $true) {
        $ExecutionTime = [System.Diagnostics.Stopwatch]::StartNew() # Timer
        $GroupCreateDeleteTable = Get-GroupCreateDelete -Servers $Servers -Dates $Dates
        $script:TimeToGenerateReports.Reports.IncludeGroupCreateDelete.Total = Set-TimeLog -Time $ExecutionTime
    }
    if ($ReportOptions.IncludeDomainControllersReboots -eq $true) {
        $ExecutionTime = [System.Diagnostics.Stopwatch]::StartNew() # Timer
        $RebootEventsTable = Get-RebootEvents -Servers $Servers -Dates $Dates
        $script:TimeToGenerateReports.Reports.IncludeDomainControllersReboots.Total = Set-TimeLog -Time $ExecutionTime
    }
    if ($ReportOptions.IncludeGroupPolicyChanges -eq $true) {
        $ExecutionTime = [System.Diagnostics.Stopwatch]::StartNew() # Timer
        $TableGroupPolicyChanges = Get-GroupPolicyChanges -Servers $Servers -Dates $Dates
        $script:TimeToGenerateReports.Reports.IncludeGroupPolicyChanges.Total = Set-TimeLog -Time $ExecutionTime
    }
    if ($ReportOptions.IncludeTimeToGenerate -eq $true) {
        $TableExecutionTimes = Set-TimeReports -HashTable $script:TimeToGenerateReports.Reports
    }
    # prepare body with HTML
    if ($ReportOptions.AsHTML) {
        if ($ReportOptions.IncludeTimeToGenerate -eq $true) {
            #$EmailBody += Set-EmailBody -TableData $TableExecutionTimes -TableWelcomeMessage "Following report shows execution times"
            $EmailBody += Set-EmailBodyPreparedTable -TableData $TableExecutionTimes -TableWelcomeMessage "Following report shows execution times"
        }
        if ($ReportOptions.IncludeDomainControllers -eq $true) {
            $EmailBody += Set-Emailbody -TableData $ServersTable -TableWelcomeMessage "Following servers have been processed for events"
        }
        If ($ReportOptions.IncludeClearedLogs -eq $true) {
            $EmailBody += Set-Emailbody -TableData $TableEventLogClearedLogs -TableWelcomeMessage "Following events regarding cleaning logs have occured"
        }
        If ($ReportOptions.IncludeEventLogSize.Use -eq $true) {
            $EmailBody += Set-EmailBody -TableData $EventLogTable -TableWelcomeMessage "Following event log sizes were reported"
        }
        if ($ReportOptions.IncludeGroupEvents -eq $true) {
            $EmailBody += Set-EmailBody -TableData $GroupsEventsTable -TableWelcomeMessage "The membership of those groups below has changed"
        }
        if ($ReportOptions.IncludeUserEvents -eq $true) {
            $EmailBody += Set-EmailBody -TableData $UsersEventsTable -TableWelcomeMessage "Following user changes happend"
        }
        if ($ReportOptions.IncludeUserStatuses -eq $true) {
            $EmailBody += Set-EmailBody -TableData $UsersEventsStatusesTable -TableWelcomeMessage "Following user status happend"
        }
        If ($ReportOptions.IncludeUserLockouts -eq $true) {
            $EmailBody += Set-EmailBody -TableData $UsersLockoutsTable -TableWelcomeMessage "Following user lockouts happend"
        }
        if ($ReportOptions.IncludeLogonEvents -eq $true) {
            $EmailBody += Set-EmailBody -TableData $LogonEvents -TableWelcomeMessage "Following logon events happend"
        }
        if ($ReportOptions.IncludeGroupCreateDelete -eq $true) {
            $EmailBody += Set-EmailBody -TableData $GroupCreateDeleteTable -TableWelcomeMessage "Following group creation/deletion occured"
        }
        if ($ReportOptions.IncludeDomainControllersReboots -eq $true) {
            $EmailBody += Set-EmailBody -TableData $RebootEventsTable -TableWelcomeMessage "Following reboot related events happened"
        }
        if ($ReportOptions.IncludeGroupPolicyChanges -eq $true) {
            $EmailBody += Set-EmailBody -TableData $TableGroupPolicyChanges -TableWelcomeMessage "Following group policy changes happend"
        }
    }
    $Reports = @()
    If ($ReportOptions.AsExcel) {
        $ReportFilePathXLSX = Set-ReportFileName -ReportOptions $ReportOptions -ReportExtension "xlsx"
        Export-ReportToXLSX -Report $ReportOptions.IncludeDomainControllers -ReportOptions $ReportOptions -ReportFilePath $ReportFilePathXLSX -ReportName "Processed Servers" -ReportTable $ServersTable
        Export-ReportToXLSX -Report $ReportOptions.IncludeClearedLogs -ReportOptions $ReportOptions -ReportFilePath $ReportFilePathXLSX -ReportName "Clear Log Events" -ReportTable $TableEventLogClearedLogs
        Export-ReportToXLSX -Report $ReportOptions.IncludeEventLogSize.Use -ReportOptions $ReportOptions -ReportFilePath $ReportFilePathXLSX -ReportName "Event log sizes" -ReportTable $EventLogTable
        Export-ReportToXLSX -Report $ReportOptions.IncludeGroupEvents -ReportOptions $ReportOptions -ReportFilePath $ReportFilePathXLSX -ReportName "Group Membership Changes"  -ReportTable $GroupsEventsTable
        Export-ReportToXLSX -Report $ReportOptions.IncludeGroupCreateDelete -ReportOptions $ReportOptions -ReportFilePath $ReportFilePathXLSX -ReportName "Group Creation Deletion Changes"  -ReportTable $GroupCreateDeleteTable
        Export-ReportToXLSX -Report $ReportOptions.IncludeUserEvents -ReportOptions $ReportOptions -ReportFilePath $ReportFilePathXLSX -ReportName  "User Changes" -ReportTable $UsersEventsTable
        Export-ReportToXLSX -Report $ReportOptions.IncludeUserStatuses -ReportOptions $ReportOptions -ReportFilePath $ReportFilePathXLSX -ReportName  "User Status Changes" -ReportTable $UsersEventsStatusesTable
        Export-ReportToXLSX -Report $ReportOptions.IncludeUserLockouts -ReportOptions $ReportOptions -ReportFilePath $ReportFilePathXLSX -ReportName "User Lockouts" -ReportTable $UsersLockoutsTable
        Export-ReportToXLSX -Report $ReportOptions.IncludeLogonEvents -ReportOptions $ReportOptions -ReportFilePath $ReportFilePathXLSX -ReportName "User Logon Events" -ReportTable $LogonEvents
        Export-ReportToXLSX -Report $ReportOptions.IncludeDomainControllersReboots -ReportOptions $ReportOptions -ReportFilePath $ReportFilePathXLSX -ReportName "Troubleshooting Reboots" -ReportTable $RebootEventsTable
        Export-ReportToXLSX -Report $ReportOptions.IncludeGroupPolicyChanges -ReportOptions $ReportOptions -ReportFilePath $ReportFilePathXLSX -ReportName "Group Policy Changes" -ReportTable $TableGroupPolicyChanges
        $Reports += $ReportFilePathXLSX
    }
    If ($ReportOptions.AsCSV) {
        $Reports += Export-ReportToCSV -Report $ReportOptions.IncludeDomainControllers -ReportOptions $ReportOptions -Extension "csv" -ReportName "ReportServers" -ReportTable $ServersTable
        $Reports += Export-ReportToCSV -Report $ReportOptions.IncludeClearedLogs -ReportOptions $ReportOptions -Extension "csv" -ReportName "IncludeClearedLogs" -ReportTable $TableEventLogClearedLogs
        $Reports += Export-ReportToCSV -Report $ReportOptions.IncludeEventLogSize.Use -ReportOptions $ReportOptions -Extension "csv" -ReportName "ReportEventLogSize" -ReportTable $EventLogTable
        $Reports += Export-ReportToCSV -Report $ReportOptions.IncludeGroupEvents -ReportOptions $ReportOptions -Extension "csv" -ReportName "ReportGroupEvents" -ReportTable $GroupsEventsTable
        $Reports += Export-ReportToCSV -Report $ReportOptions.IncludeGroupCreateDelete -ReportOptions $ReportOptions -Extension "csv" -ReportName "ReportGroupCreateDeleteEvents" -ReportTable $GroupCreateDeleteTable
        $Reports += Export-ReportToCSV -Report $ReportOptions.IncludeUserEvents -ReportOptions $ReportOptions -Extension "csv" -ReportName "ReportUserEvents" -ReportTable $UsersEventsTable
        $Reports += Export-ReportToCSV -Report $ReportOptions.IncludeUserStatuses -ReportOptions $ReportOptions -Extension "csv" -ReportName "ReportUserStatuses" -ReportTable $UsersEventsStatusesTable
        $Reports += Export-ReportToCSV -Report $ReportOptions.IncludeUserLockouts -ReportOptions $ReportOptions -Extension "csv" -ReportName "ReportUserLockouts" -ReportTable $UsersLockoutsTable
        $Reports += Export-ReportToCSV -Report $ReportOptions.IncludeLogonEvents -ReportOptions $ReportOptions -Extension "csv" -ReportName "ReportUserLogons" -ReportTable $LogonEvents
        $Reports += Export-ReportToCSV -Report $ReportOptions.IncludeDomainControllersReboots -ReportOptions $ReportOptions -Extension "csv" -ReportName "ReportReboots" -ReportTable $RebootEventsTable
        $Reports += Export-ReportToCSV -Report $ReportOptions.IncludeGroupPolicyChanges -ReportOptions $ReportOptions -Extension "csv" -ReportName "ReportGroupPolicyChanges" -ReportTable $TableGroupPolicyChanges
    }
    $Reports = $Reports |  Where-Object { $_ } | Sort-Object -Uniq

    # Do Cleanup of Emails
    $EmailBody = Set-EmailWordReplacements -Body $EmailBody -Replace '**TimeToGenerateDays**' -ReplaceWith $time.Elapsed.Days
    $EmailBody = Set-EmailWordReplacements -Body $EmailBody -Replace '**TimeToGenerateHours**' -ReplaceWith $time.Elapsed.Hours
    $EmailBody = Set-EmailWordReplacements -Body $EmailBody -Replace '**TimeToGenerateMinutes**' -ReplaceWith $time.Elapsed.Minutes
    $EmailBody = Set-EmailWordReplacements -Body $EmailBody -Replace '**TimeToGenerateSeconds**' -ReplaceWith $time.Elapsed.Seconds
    $EmailBody = Set-EmailWordReplacements -Body $EmailBody -Replace '**TimeToGenerateMilliseconds**' -ReplaceWith $time.Elapsed.Milliseconds
    $Time.Stop()

    #$script:TimeToGenerateReports | ConvertTo-Json

    # Sending email - finalizing package
    if ($ReportOptions.SendMail -eq $true) {
        $TemporarySubject = $EmailParameters.EmailSubject -replace "<<DateFrom>>", "$($Dates.DateFrom)" -replace "<<DateTo>>", "$($Dates.DateTo)"
        Write-Color @script:WriteParameters "[i] Sending email with reports..." -Color White, Green -NoNewLine
        $SendMail = Send-Email -EmailParameters $EmailParameters -Body $EmailBody -Attachment $Reports -Subject $TemporarySubject
        if ($SendMail.Status -eq $True) {
            Write-Color "Success!" -Color Green
        } else {
            Write-Color "Not working!" -Color Red
            Write-Color @script:WriteParameters "[i] Error: ", "$($SendMail.Error)" -Color White, Red
        }
    } else {
        Write-Color @script:WriteParameters "[i] Skipping sending email with reports...", "as per configuration!" -Color White, Green
    }

    Remove-ReportsFiles -KeepReports $ReportOptions.KeepReports -AsExcel $ReportOptions.AsExcel -AsCSV $ReportOptions.AsCSV -ReportFiles $Reports
}
function Get-TimeZoneLegacy () {
    return ([System.TimeZone]::CurrentTimeZone).StandardName
}
function Get-TimeZoneAdvanced {
    param(
        [string[]]$ComputerName = $Env:COMPUTERNAME,
        [System.Management.Automation.PSCredential] $Credential = [System.Management.Automation.PSCredential]::Empty
    )
    foreach ($computer in $computerName) {
        $TimeZone = Get-WmiObject -Class win32_timezone -ComputerName $computer -Credential $Credential
        $LocalTime = Get-WmiObject -Class win32_localtime -ComputerName $computer -Credential $Credential
        $Output = @{
            'ComputerName' = $localTime.__SERVER;
            'TimeZone' = $timeZone.Caption;
            'CurrentTime' = (Get-Date -Day $localTime.Day -Month $localTime.Month);
        }
        $Object = New-Object -TypeName PSObject -Property $Output
        Write-Output $Object
    }
}
function Remove-ReportsFiles ($KeepReports, $AsExcel, $AsCSV, $ReportFiles) {
    if ($KeepReports -eq $false -and ($AsExcel -eq $true -or $AsCSV -eq $true)) {
        foreach ($report in $ReportFiles) {
            if (Test-Path $report) {
                Write-Color @script:WriteParameters "[i] ", "Removing file ", " $report " -Color White, White, Yellow, White, Red
                try {
                    Remove-Item $report -ErrorAction Stop
                } catch {
                    #Write-Color @Global:WriteParameters "[i] Error reported when removing file ", "$Report", ". File will be skipped..." -Color White, Red, White
                    Write-Color @script:WriteParameters "[i] Error: ", "$($_.Exception.Message)" -Color White, Red
                }
            }
        }
    }
}
function Export-ReportToXLSX ($Report, $ReportOptions, $ReportFilePath, $ReportName, $ReportTable) {
    if ($Report -eq $true) {
        $ReportTable | Export-Excel -Path $ReportFilePath -WorkSheetname $ReportName -AutoSize -FreezeTopRow -AutoFilter
        return
    } else {
        return
    }
}
function Export-ReportToCSV ($Report, $ReportOptions, $Extension, $ReportName, $ReportTable) {
    if ($Report -eq $true) {
        $ReportFilePath = Set-ReportFileName -ReportOptions $ReportOptions -ReportExtension $Extension -ReportName $ReportName
        $ReportTable | Export-Csv -Encoding Unicode -Path $ReportFilePath
        return $ReportFilePath
    } else {
        return ""
    }
}
function Get-Servers($ReportOptions) {
    $Servers = @()
    if ($ReportOptions.OnlyPrimaryDC -eq $true) { $ServerOptions = @{ Server = (get-addomain).pdcemulator; ErrorAction = "Stop" }
    } else { $ServerOptions = @{ Filter = "*"; ErrorAction = "Stop" }
    }
    try {
        $Servers = Get-ADDomainController @ServerOptions | Select-Object Name, HostName, Ipv4Address, IsGlobalCatalog, IsReadOnly, OperatingSystem, Site, Enabled, Supported #, EventsFound
    } catch {
        if ($_.Exception -match "Unable to find a default server with Active Directory Web Services running.") {
            Write-Color @script:WriteParameters "[-] ", "Active Directory", " not found. Please run this script with access to ", "Domain Controllers." -Color White, Red, White, Red
        }
        Write-Color @script:WriteParameters "[i] Error: ", "$($_.Exception.Message)" -Color White, Red
    }
    return $Servers
}
function Start-ADReporting ($EmailParameters, $ReportOptions, $FormattingOptions, $ScriptParameters) {

    $Test1 = Test-Key -ConfigurationTable $ScriptParameters -ConfigurationSection "" -ConfigurationKey "ShowTime" -DisplayProgress $false
    $Test2 = Test-Key -ConfigurationTable $ScriptParameters -ConfigurationSection "" -ConfigurationKey "LogFile" -DisplayProgress $false
    $Test3 = Test-Key -ConfigurationTable $ScriptParameters -ConfigurationSection "" -ConfigurationKey "TimeFormat" -DisplayProgress $false
    if ($Test1 -and $Test2 -and $Test3) { $script:WriteParameters = $ScriptParameters }
    Test-Prerequisite $EmailParameters $ReportOptions $FormattingOptions
    if ($ReportOptions.JustTestPrerequisite -ne $null -and $ReportOptions.JustTestPrerequisite -eq $true) {
        Exit
    }
    $Servers = Get-Servers $ReportOptions
    # Report Per Hour
    if ($ReportOptions.ReportPastHour -eq $true) {
        $DatesPastHour = Find-DatesPastHour
        if ($DatesPastHour -ne $null) {
            Start-Report -Dates $DatesPastHour $EmailParameters $ReportOptions $FormattingOptions $Servers
        }
    }
    if ($ReportOptions.ReportCurrentHour -eq $true) {
        $DatesCurrentHour = Find-DatesCurrentHour
        if ($DatesCurrentHour -ne $null) {
            Start-Report -Dates $DatesCurrentHour $EmailParameters $ReportOptions $FormattingOptions $Servers
        }
    }
    # Report Per Day
    if ($ReportOptions.ReportPastDay -eq $true) {
        $DatesDayPrevious = Find-DatesDayPrevious
        if ($DatesDayPrevious -ne $null) {
            Start-Report -Dates $DatesDayPrevious $EmailParameters $ReportOptions $FormattingOptions $Servers
        }
    }
    if ($ReportOptions.ReportCurrentDay -eq $true) {
        $DatesDayToday = Find-DatesDayToday
        if ($DatesDayToday -ne $null) {
            Start-Report -Dates $DatesDayToday $EmailParameters $ReportOptions $FormattingOptions $Servers
        }
    }
    # Report Per Week
    if ($ReportOptions.ReportOnDay.Use -eq $true) {
        foreach ($Day in $ReportOptions.ReportOnDay.Days) {
            $DatesReportOnDay = Find-DatesPastWeek $Day
            if ($DatesReportOnDay -ne $null) {
                Start-Report -Dates $DatesReportOnDay $EmailParameters $ReportOptions $FormattingOptions $Servers
            }
        }
    }
    # Report Per Month
    if ($ReportOptions.ReportPastMonth.Use -eq $true -or $ReportOptions.ReportPastMonth.Force -eq $true) {
        $DatesMonthPrevious = Find-DatesMonthPast -Force $ReportOptions.ReportPastMonth.Force     # Find-DatesMonthPast runs only on 1st of the month unless -Force is used
        if ($DatesMonthPrevious -ne $null) {
            Start-Report -Dates $DatesMonthPrevious -EmailParameters $EmailParameters $ReportOptions $FormattingOptions $Servers
        }
    }
    if ($ReportOptions.ReportCurrentMonth -eq $true) {
        $DatesMonthCurrent = Find-DatesMonthCurrent
        if ($DatesMonthCurrent -ne $null) {
            Start-Report -Dates $DatesMonthCurrent $EmailParameters $ReportOptions $FormattingOptions $Servers
        }
    }
    # Report Per Quarter
    if ($ReportOptions.ReportPastQuarter.Use -eq $true -or $ReportOptions.ReportPastQuarter.Force -eq $true) {
        $DatesQuarterLast = Find-DatesQuarterLast -Force $ReportOptions.ReportPastQuarter.Force  # Find-DatesMonthPast runs only on 1st of the quarter unless -Force is used
        if ($DatesQuarterLast -ne $null) {
            Start-Report -Dates $DatesQuarterLast $EmailParameters $ReportOptions $FormattingOptions $Servers
        }
    }
    if ($ReportOptions.ReportCurrentQuarter -eq $true) {
        $DatesQuarterCurrent = Find-DatesQuarterCurrent
        if ($DatesQuarterCurrent -ne $null) {
            Start-Report -Dates $DatesQuarterCurrent $EmailParameters $ReportOptions $FormattingOptions $Servers
        }
    }
    # Report Custom
    if ($ReportOptions.ReportCurrentDayMinusDayX.Use -eq $true) {
        $DatesCurrentDayMinusDayX = Find-DatesCurrentDayMinusDayX $ReportOptions.ReportCurrentDayMinusDayX.Days
        if ($DatesCurrentDayMinusDayX -ne $null) {
            Start-Report -Dates $DatesCurrentDayMinusDayX $EmailParameters $ReportOptions $FormattingOptions $Servers
        }
    }
    if ($ReportOptions.ReportCurrentDayMinuxDaysX.Use -eq $true) {
        $DatesCurrentDayMinusDaysX = Find-DatesCurrentDayMinuxDaysX $ReportOptions.ReportCurrentDayMinuxDaysX.Days
        if ($DatesCurrentDayMinusDaysX -ne $null) {
            Start-Report -Dates $DatesCurrentDayMinusDaysX $EmailParameters $ReportOptions $FormattingOptions $Servers
        }
    }
    if ($ReportOptions.ReportCustomDate.Use -eq $true) {
        $DatesCustom = @{
            DateFrom = $ReportOptions.ReportCustomDate.DateFrom
            DateTo = $ReportOptions.ReportCustomDate.DateTo
        }
        if ($DatesCustom -ne $null) {
            Start-Report -Dates $DatesCustom $EmailParameters $ReportOptions $FormattingOptions $Servers
        }
    }

}

Export-ModuleMember -function 'Start-ADReporting'