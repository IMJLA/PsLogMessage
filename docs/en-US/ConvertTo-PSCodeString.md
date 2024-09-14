---
external help file: PsLogMessage-help.xml
Module Name: PsLogMessage
online version:
schema: 2.0.0
---

# ConvertTo-PSCodeString

## SYNOPSIS
Convert an object or array of objects into a code string which could be converted into a ScriptBlock with valid PowerShell syntax

## SYNTAX

```
ConvertTo-PSCodeString [[-InputObject] <Object>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Originally used for hashtables and arrays

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -InputObject
Object to convert to a PowerShell code string

```yaml
Type: System.Object
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

### $InputObject parameter
## OUTPUTS

### [System.String] Resulting PowerShell code
## NOTES

## RELATED LINKS
