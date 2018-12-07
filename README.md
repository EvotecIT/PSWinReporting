# PSWinReporting
This `PowerShell Module`, which started as an event library `(Get-EventsLibrary.ps1)`, has now grown up and became full fledged PowerShell Module. This module has multiple functionalities but one of the signature features of this module is ability to parse Security (mostly) logs on `Domain Controllers`. But that's not all. You can set up reporting on it and have emails delivered with summary of hourly, daily, weekly, monthly or quarterly changes. Changes that happen on your Active Directory Domain. Changes that your Service Desk agents, or other administrators do. And with new versions… well you can do a lot of stuff. Just read below. Make sure to go thru related articles as they have all the KNOW HOW which is quite useful if you want to get everything from this module.

## Links

Documentation for PSWinReporting (overview - latest post):
> https://evotec.xyz/pswinreporting-1-0-is-out/

Documentation for PSWinReporting (module description, installation, how to):
> https://evotec.xyz/hub/scripts/pswinreporting-powershell-module/

Module is published on Powershell Gallery:
> https://www.powershellgallery.com/packages/PSWinReporting/


## To Do

- [ ] Active Directory Diagnostics Reporting
- [ ] File Server Events monitoring
- [ ] Improvements to config
- [ ] Manual way to execute, and get events in console
- [ ] Improvements to errors handling
- [ ] Totally custom building of events reporting

## Project Features

Following AD Events are supported:

- [x] Group create, delete, modify (Who / When / What)
- [x] Group membership changes (Who / When / What)
- [x] User changes (Who / When / What)
- [x] User created / deleted (Who / When)
- [x] User password changes (Who / When)
- [x] User lockouts (Who / When / Where)
- [x] Computer Created / Modified (Who / When / Where)
- [x] Computer Deleted (Who / When / Where)
- [x] Event Log Backup (Who / When)
- [x] Event Log Clear (Who / When)

Features:

- [x] Support for Event Forwarding – monitoring one event log instead of scanning all domain controllers
- [x] Support for Microsoft Teams – Sending events as they happen to Microsoft Teams (only supported when forwarders are in use)
- [x] Support for Slack – Sending events as they happen to Slack (only supported when forwarders are in use)
- [x] Support for Microsoft SQL – Sending events directly to SQL (some people prefer it that way)
- [x] Support for backing up old archived logs (moves logs from Domain Controllers into chosen place)
- [x] Support for re-scanning logs from files – a way to recheck your logs for missing information

### Example - Script running

![image](https://evotec.xyz/wp-content/uploads/2018/06/2018-06-10_11-20-08.gif.pagespeed.ce.xrLSOGTIkk.gif)

### Example - Email Report

![image](https://evotec.xyz/wp-content/uploads/2018/06/PSWinReporting1.0-Example1.png)

### Example - Microsoft Teams

![image](https://evotec.xyz/wp-content/uploads/2018/09/img_5b9e830101081.png)

### Example - Slack

![image](https://evotec.xyz/wp-content/uploads/2018/09/img_5b9e7041638f5.png)