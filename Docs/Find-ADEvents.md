---
external help file: PSWinReporting-help.xml
Module Name: PSWinReporting
online version:
schema: 2.0.0
---

# Find-ADEvents

## SYNOPSIS
{{Fill in the Synopsis}}

## SYNTAX

### DateManual
```
Find-ADEvents [-DateFrom <DateTime>] [-DateTo <DateTime>] [-Servers <String[]>]
 [-LoggerParameters <IDictionary>] -Report <String> [<CommonParameters>]
```

### DateRange
```
Find-ADEvents [-Servers <String[]>] [-LoggerParameters <IDictionary>] -Report <String> -DatesRange <String>
 [<CommonParameters>]
```

## DESCRIPTION
{{Fill in the Description}}

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -DateFrom
{{Fill DateFrom Description}}

```yaml
Type: DateTime
Parameter Sets: DateManual
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DateTo
{{Fill DateTo Description}}

```yaml
Type: DateTime
Parameter Sets: DateManual
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DatesRange
{{Fill DatesRange Description}}

```yaml
Type: String
Parameter Sets: DateRange
Aliases:
Accepted values: PastHour, CurrentDayMinusDayX, CurrentDayMinuxDaysX, Last7days, CurrentMonth, CurrentDay, Last3days, Everything, PastDay, CurrentQuarter, PastMonth, PastQuarter, OnDay, CustomDate, CurrentHour, Last14days

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -LoggerParameters
{{Fill LoggerParameters Description}}

```yaml
Type: IDictionary
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Report
{{Fill Report Description}}

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: ComputerChangesDetailed, UserLockouts, GroupMembershipChanges, ComputerCreatedChanged, GroupPolicyChanges, UserLogonKerberos, LogsClearedSecurity, GroupCreateDelete, ComputerDeleted, UserChanges, UserStatus, UserChangesDetailed, LogsClearedOther, EventsReboots, UserLogon

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Servers
{{Fill Servers Description}}

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: Server, ComputerName

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
