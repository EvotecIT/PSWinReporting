<!--
Building nice readme - https://help.github.com/articles/basic-writing-and-formatting-syntax/
-->

### PSWinReporting
This `PowerShell Module`, which started as an event library (`Get-EventsLibrary.ps1`), has now grown up and became full fledged PowerShell Module. This module has multiple functionalities but one of the signature features of this module is ability to parse Security (mostly) logs on `Domain Controllers`.

###### Project Features

Following features are done:

- [x] Group create, delete, modify (Who / When / What)
- [x] Group membership changes (Who / When / What)
- [x] User changes (Who / When / What)
- [x] User create, delete (Who / When)
- [x] User password changes (Who / When)
- [x] User lockouts (Who / When / Where)

Run script/config:

![image](https://evotec.xyz/wp-content/uploads/2018/06/2018-06-10_11-20-08.gif.pagespeed.ce.xrLSOGTIkk.gif)

And get a nice report

![image](https://evotec.xyz/wp-content/uploads/2018/06/PSWinReporting1.0-Example1.png)

###### To Do

- [ ] Support for forwarded events
- [ ] Support for encrypting email password
- [ ] Active Directory Diagnostics Reporting
- [ ] File Server Events monitoring

###### Links

Documentation for PSWinReporting (overview - latest post):
> https://evotec.xyz/pswinreporting-1-0-is-out/

Documentation for PSWinReporting (module description, installation, how to):
> https://evotec.xyz/hub/scripts/pswinreporting-powershell-module/

Module is published on Powershell Gallery:
> https://www.powershellgallery.com/packages/PSWinReporting/
