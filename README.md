<center>

[![PowerShellGallery Version](https://img.shields.io/powershellgallery/v/PSWinReporting.svg?style=for-the-badge)](https://www.powershellgallery.com/packages/PSWinReporting)

[![PowerShellGallery Platform](https://img.shields.io/powershellgallery/p/PSWinReporting.svg?style=for-the-badge)](https://www.powershellgallery.com/packages/PSWinReporting)
[![PowerShellGallery Preview Version](https://img.shields.io/powershellgallery/vpre/PSWinReporting.svg?label=powershell%20gallery%20preview&colorB=yellow&style=for-the-badge)](https://www.powershellgallery.com/packages/PSWinReporting)

![Top Language](https://img.shields.io/github/languages/top/evotecit/PSWinReporting.svg?style=for-the-badge)
![Code](https://img.shields.io/github/languages/code-size/evotecit/PSWinReporting.svg?style=for-the-badge)
[![PowerShellGallery Downloads](https://img.shields.io/powershellgallery/dt/PSWinReporting.svg?style=for-the-badge)](https://www.powershellgallery.com/packages/PSWinReporting)

</center>

# PSWinReporting - Legacy Edition

This `PowerShell Module`, which started as an event library `(Get-EventsLibrary.ps1)`, has now grown up and became full fledged PowerShell Module. This module has multiple functionalities but one of the signature features of this module is ability to parse Security (mostly) logs on `Domain Controllers`. But that's not all. You can set up reporting on it and have emails delivered with summary of **hourly**, **daily**, **weekly**, **monthly** or **quarterly** changes. Changes that happen on your **Active Directory** Domain. Changes that your Service Desk agents, or other administrators do. And with new versions… well you can do a lot of stuff. Just read below. Make sure to go thru related articles as they have all the KNOW HOW which is quite useful if you want to get everything from this module. Module is published on [Powershell Gallery](https://www.powershellgallery.com/packages/PSWinReporting/).

This ***legacy edition*** will continue it's life as ***1.7.X***. If you want to keep on using it, feel free, but it's highely encouraged to use ***2.x.x*** when it's fully functional with all features. 


## ChangeLog

- 1.8.0 - 10.03.2019
  - Update to configuration and overview of some features
  - All information provied in blog post: https://evotec.xyz/pswinreporting-1-8-split-of-branches-legacy-vs-new-hope/
- 1.7.7 - 21.02.2019
  - Fix for long RecordID
  - Fix of colors for Teams 
  - Fix for Teams Summary visible in activity pane
- 1.7.6 - XX.02.2019
  - Fixes for PDC detection
  - Some optimization
  - Bundle as single PSM1 file (speed up loading process)

## Links

-   [Documentation for PSWinReporting (module description, installation, how to)](https://evotec.xyz/hub/scripts/pswinreporting-powershell-module/) - Full project description
-   [Review of features coming in 2.0 along with some features description for the current version](https://evotec.xyz/pswinreporting-1-8-split-of-branches-legacy-vs-new-hope/) - Nice overview
-   [Review of new features in PSWinReporting 1.7](https://evotec.xyz/pswinreporting-forwarders-microsoft-teams-slack-microsoft-sql-and-more/) - Lots of changes, review required. Microsoft Teams, Slack, SQL and forwarders support
-   [Review of new features in PSWinReporting 1.0](https://evotec.xyz/pswinreporting-1-0-is-out/) - Lots of changes, review required.
-   [Last version of Get-EventsLibrary.ps1](https://evotec.xyz/get-eventslibrary-ps1-monitoring-events-powershell/) - This is actual code base for the old version. Just in case…
-   [Blog post about version 0.8](https://evotec.xyz/whats-new-event-monitoring-0-8/) - Updates from feedback. Last version before name change.
-   [Blog post about version 0.7](https://evotec.xyz/whats-new-event-monitoring-v0-7/) - Updates from feedback.
-   [Blog post about version 0.6](https://evotec.xyz/whats-new-event-monitoring-v0-6/) - Updates from feedback.
-   [Blog post about initial version and the differences in monitoring approach](https://evotec.xyz/monitoring-active-directory-changes-on-users-and-groups-with-powershell/)

## Project Features

Following AD Events are supported:

-   [x] Group create, delete, modify (Who / When / What)
-   [x] Group membership changes (Who / When / What)
-   [x] User changes (Who / When / What)
-   [x] User created / deleted (Who / When)
-   [x] User password changes (Who / When)
-   [x] User lockouts (Who / When / Where)
-   [x] Computer Created / Modified (Who / When / Where)
-   [x] Computer Deleted (Who / When / Where)
-   [x] Event Log Backup (Who / When)
-   [x] Event Log Clear (Who / When)

Features:

-   [x] Support for Event Forwarding - monitoring one event log instead of scanning all domain controllers
-   [x] Support for Microsoft Teams - Sending events as they happen to Microsoft Teams (only supported when forwarders are in use)
-   [x] Support for Slack - Sending events as they happen to Slack (only supported when forwarders are in use)
-   [x] Support for Microsoft SQL - Sending events directly to SQL (some people prefer it that way)
-   [x] Support for backing up old archived logs (moves logs from Domain Controllers into chosen place)
-   [x] Support for re-scanning logs from files - a way to recheck your logs for missing information

### Example - Script running

![image](https://evotec.xyz/wp-content/uploads/2018/06/2018-06-10_11-20-08.gif.pagespeed.ce.xrLSOGTIkk.gif)

### Example - Email Report

![image](https://evotec.xyz/wp-content/uploads/2018/06/PSWinReporting1.0-Example1.png)

### Example - Microsoft Teams

![image](https://evotec.xyz/wp-content/uploads/2018/09/img_5b9e830101081.png)

### Example - Slack

![image](https://evotec.xyz/wp-content/uploads/2018/09/img_5b9e7041638f5.png)
