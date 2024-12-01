---
external help file: PsLogMessage-help.xml
Module Name: PsLogMessage
online version:
schema: 2.0.0
---

# Export-LogCsv

## SYNOPSIS
Export a hashtable of log message objects to a CSV file.

## SYNTAX

```
Export-LogCsv [[-LogFile] <String>] [-Cache] <PSReference> [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

## DESCRIPTION
Sort the log message objects by their Timestamp property.
Export the log message objects to a CSV file.
Write the file path to the Information stream.

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -Cache
In-process cache to reduce calls to other processes or disk, and store repetitive parameters for better readability of code and logs

```yaml
Type: System.Management.Automation.PSReference
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -LogFile
Log file to create

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ProgressAction
{{ Fill ProgressAction Description }}

```yaml
Type: System.Management.Automation.ActionPreference
Parameter Sets: (All)
Aliases: proga

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### [System.String]$LogFile parameter
## OUTPUTS

### None.  The value of $LogFile is written to the Information stream.
## NOTES

## RELATED LINKS
