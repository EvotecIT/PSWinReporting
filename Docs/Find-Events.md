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

### Manual (Default)
```
Find-Events -DateFrom <DateTime> -DateTo <DateTime> [-Servers <String[]>] [-DetectDC]
 [-Credential <PSCredential>] [-Quiet] [-LoggerParameters <IDictionary>] [-ExtentedOutput] [-Who <String>]
 [-Whom <String>] [-NotWho <String>] [-NotWhom <String>] -Report <String[]> [<CommonParameters>]
```

### DateManual
```
Find-Events [-DateFrom <DateTime>] [-DateTo <DateTime>] [-Servers <String[]>] [-DetectDC]
 [-Credential <PSCredential>] [-Quiet] [-LoggerParameters <IDictionary>] [-ExtentedOutput] [-Who <String>]
 [-Whom <String>] [-NotWho <String>] [-NotWhom <String>] -Report <String[]> [<CommonParameters>]
```

### DateRange
```
Find-Events [-Servers <String[]>] [-DetectDC] [-Credential <PSCredential>] [-Quiet]
 [-LoggerParameters <IDictionary>] [-ExtentedOutput] [-Who <String>] [-Whom <String>] [-NotWho <String>]
 [-NotWhom <String>] -Report <String[]> -DatesRange <String> [<CommonParameters>]
```

### Extended
```
Find-Events [-Credential <PSCredential>] -Definitions <IDictionary> -Times <IDictionary> -Target <IDictionary>
 [-EventID <Int32>] [-EventRecordID <Int64>] [<CommonParameters>]
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

### -Credential
{{ Fill Credential Description }}

```yaml
Type: PSCredential
Parameter Sets: (All)
Aliases: Credentials

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DateFrom
{{ Fill DateFrom Description }}

```yaml
Type: DateTime
Parameter Sets: Manual
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

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
Parameter Sets: Manual
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

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
Accepted values: PastHour, CurrentHour, PastDay, CurrentDay, OnDay, PastMonth, CurrentMonth, PastQuarter, CurrentQuarter, CurrentDayMinusDayX, CurrentDayMinuxDaysX, CustomDate, Last3days, Last7days, Last14days, Everything

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Definitions
{{ Fill Definitions Description }}

```yaml
Type: IDictionary
Parameter Sets: Extended
Aliases:

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
Parameter Sets: Manual, DateManual, DateRange
Aliases: RunAgainstDC

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -EventID
{{ Fill EventID Description }}

```yaml
Type: Int32
Parameter Sets: Extended
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -EventRecordID
{{ Fill EventRecordID Description }}

```yaml
Type: Int64
Parameter Sets: Extended
Aliases:

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
Parameter Sets: Manual, DateManual, DateRange
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
Parameter Sets: Manual, DateManual, DateRange
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -NotWho
{{ Fill NotWho Description }}

```yaml
Type: String
Parameter Sets: Manual, DateManual, DateRange
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -NotWhom
{{ Fill NotWhom Description }}

```yaml
Type: String
Parameter Sets: Manual, DateManual, DateRange
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
Parameter Sets: Manual, DateManual, DateRange
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
Parameter Sets: Manual, DateManual, DateRange
Aliases:
Accepted values: ADUserChanges, ADUserChangesDetailed, ADComputerChangesDetailed, ADOrganizationalUnitChangesDetailed, ADUserStatus, ADUserLockouts, ADUserLogon, ADUserUnlocked, ADComputerCreatedChanged, ADComputerDeleted, ADUserLogonKerberos, ADGroupMembershipChanges, ADGroupEnumeration, ADGroupChanges, ADGroupCreateDelete, ADGroupChangesDetailed, ADGroupPolicyChanges, ADLogsClearedSecurity, ADLogsClearedOther, ADEventsReboots

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
Parameter Sets: Manual, DateManual, DateRange
Aliases: Server, ComputerName

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Target
{{ Fill Target Description }}

```yaml
Type: IDictionary
Parameter Sets: Extended
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Times
{{ Fill Times Description }}

```yaml
Type: IDictionary
Parameter Sets: Extended
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Who
{{ Fill Who Description }}

```yaml
Type: String
Parameter Sets: Manual, DateManual, DateRange
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Whom
{{ Fill Whom Description }}

```yaml
Type: String
Parameter Sets: Manual, DateManual, DateRange
Aliases:

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
