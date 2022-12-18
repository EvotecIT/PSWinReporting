### Changelog

#### - 2.0.23 - 18.12.2023
  - In some situations, it is necessary to use credentials for getting the Domain Controller using the DetectDC parameter. [#77](https://github.com/EvotecIT/PSWinReporting/pull/77) by @ferwe

#### - 2.0.22 - 18.05.2022
  - Fixes rare missing username in AD UserLockout events [#66](https://github.com/EvotecIT/PSWinReporting/issues/66)
  - Fixes ADUserChangesDetailed where moving user from one OU to another is not reported properly [#68](https://github.com/EvotecIT/PSWinReporting/issues/68)

#### - 2.0.21 - 26.09.2021
  - Changed Dynamic Parameters to ArgumentCompleter
  - Fixed issue with Dates not being used in `Start-WinReporting`

#### - 2.0.20 - 30.01.2020
  - Fix for executing Discord/Slack or Teams if it's not in use during Trigger

#### - 2.0.19 - 28.01.2020
  - Fix for DatesRanges using cached values
  - Fix for Ldap* reports always running even when not requested

#### - 2.0.18 - 20.01.2020
  - Fix for detecting forest/domains

#### - 2.0.17 - 19.01.2020
  - Added LdapBindingsDetails
  - Added LdapBindingsSummary

#### - 2.0.16 - 12.01.2020
  - Fix for typos

#### - 2.0.15 - 11.01.2020
  - Simplified, enhanced `New-WinSubscriptionTemplates` (see examples)
  - Some engine fixes

#### - 2.0.14 - 11.09.2019
  - Fixed New-WinSubscriptionTemplates

#### - 2.0.13 - 30.08.2019
  - Find-Events
    - Fix for Target not having anything to run
    - Fix for Files being passed even thou - not existing
    - Fix for Reports variable not being available during non-standard runs
  - Removed definitions
    - [x] ADEventsReboots
  - Added definitions
    - [x] OSStartupShutdownCrash
    - [x] OSCrash
    - [x] NetworkAccessAuthenticationPolicy
  - Changed .psd1 required modules to have specific required version. Less likely things will be broken during update of other modules.
  - Fixes for Reporting based on ForwardedEvents

#### - 2.0.12 - 09.07.2019
  - Small fixes

#### - 2.0.11 - 15.06..2019
  - Find-Events
    - Fix for Group Policy Events
    - Fix for Subevents within Events overwriting values
    - Fix for output when using Definitions/Times/Servers (1 definition returns an Array, 2 or more returns hashtable of Arrays)
#### - 2.0.10 - 06.05.2019
  - Fixes for reporting
  - Adding subscriptions