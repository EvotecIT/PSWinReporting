
Import-Module Dashimo # Install-Module Dashimo -Force
Import-Module PSWinReportingV2 # Install-Module PSWinReportingV2 -Force

$Reports = @(
    'ADUserChanges'
    'ADUserChangesDetailed'
    'ADComputerChangesDetailed'
    'ADUserStatus'
    'ADUserLockouts'
    #ADUserLogon
    'ADUserUnlocked'
    'ADComputerCreatedChanged'
    'ADComputerDeleted'
    #'ADUserLogonKerberos'
    'ADGroupMembershipChanges'
    'ADGroupEnumeration'
    'ADGroupChanges'
    'ADGroupCreateDelete'
    'ADGroupChangesDetailed'
    'ADGroupPolicyChanges'
    'ADLogsClearedSecurity'
    'ADLogsClearedOther'
    #ADEventsReboots
)

$Events = Find-Events -Report $Reports -DatesRange Last3days -Servers 'AD1', 'AD2' -Verbose

Dashboard -FilePath $PSScriptRoot\DashboardFromEvents.html -Name 'Dashimo - FindEvents' -Show {
    Tab -Name 'Computer Changes' {
        Section -Name 'ADComputerCreatedChanged' {
            Table -DataTable $Events.ADComputerCreatedChanged
        }
        Section -Name 'ADComputerDeleted' {
            Table -DataTable $Events.ADComputerDeleted
        }
        Section -Name 'ADComputerChangesDetailed' {
            Table -DataTable $Events.ADComputerChangesDetailed
        }
    }
    Tab -Name 'Group Changes' {
        Section -Name 'ADGroupCreateDelete' {
            Table -DataTable $Events.ADGroupCreateDelete
        }
        Section -Name 'ADGroupMembershipChanges' {
            Table -DataTable $Events.ADGroupMembershipChanges
        }
        Section -Name 'ADGroupEnumeration' {
            Table -DataTable $Events.ADGroupEnumeration
        }
        Section -Name 'ADGroupChanges' {
            Table -DataTable $Events.ADGroupChanges
        }
        Section -Name 'ADGroupChangesDetailed' {
            Table -DataTable $Events.ADGroupChangesDetailed
        }
    }
    Tab -Name 'User Changes' {
        Section -Name 'ADUserChanges' {
            Table -DataTable $Events.ADUserChanges
        }
        Section -Name 'ADUserChangesDetailed' {
            Table -DataTable $Events.ADUserChangesDetailed
        }
        Section -Name 'ADUserLockouts' {
            Table -DataTable $Events.ADUserLockouts
        }
        Section -Name 'ADUserStatus' {
            Table -DataTable $Events.ADUserStatus
        }
        Section -Name 'ADUserUnlocked' {
            Table -DataTable $Events.ADUserUnlocked
        }
    }
    Tab -Name 'Group Policy Changes' {
        Section -Name 'ADGroupPolicyChanges' {
            Table -DataTable $Events.ADGroupPolicyChanges
        }
    }
    Tab -Name 'Logs' {
        Section -Name 'ADLogsClearedOther' {
            Table -DataTable $Events.ADLogsClearedOther
        }
        Section -Name 'ADLogsClearedSecurity' {
            Table -DataTable $Events.ADLogsClearedSecurity
        }
    }
}