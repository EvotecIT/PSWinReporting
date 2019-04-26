---
external help file: PSWinReportingV2-help.xml
Module Name: PSWinReportingV2
online version:
schema: 2.0.0
---

# Find-Events

## SYNOPSIS
{{ Fill in the Synopsis }}

## SYNTAX

### DateManual
```
Find-Events [-DateFrom <DateTime>] [-DateTo <DateTime>] [-Servers <String[]>] [-DetectDC] [-Quiet]
 [-LoggerParameters <IDictionary>] [-ExtentedOutput] -Report <String[]> [<CommonParameters>]
```

### DateRange
```
Find-Events [-Servers <String[]>] [-DetectDC] [-Quiet] [-LoggerParameters <IDictionary>] [-ExtentedOutput]
 -Report <String[]> -DatesRange <String> [<CommonParameters>]
```

## DESCRIPTION
{{ Fill in the Description }}

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -DateFrom
{{ Fill DateFrom Description }}

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
{{ Fill DateTo Description }}

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
{{ Fill DatesRange Description }}

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

### -DetectDC
{{ Fill DetectDC Description }}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: RunAgainstDC

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExtentedOutput
{{ Fill ExtentedOutput Description }}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -LoggerParameters
{{ Fill LoggerParameters Description }}

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

### -Quiet
{{ Fill Quiet Description }}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Report
{{ Fill Report Description }}

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:
Accepted values: UserChanges, UserChangesDetailed, ComputerChangesDetailed, UserStatus, UserLockouts, UserLogon, UserUnlocked, ComputerCreatedChanged, ComputerDeleted, UserLogonKerberos, GroupMembershipChanges, GroupEnumeration, GroupChanges, GroupCreateDelete, GroupChangesDetailed, GroupPolicyChanges, LogsClearedSecurity, LogsClearedOther, EventsReboots

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Servers
{{ Fill Servers Description }}

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
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
