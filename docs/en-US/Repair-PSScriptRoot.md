---
external help file: PsLogMessage-help.xml
Module Name: PsLogMessage
online version:
schema: 2.0.0
---

# Repair-PSScriptRoot

## SYNOPSIS
Replaces '$PSScriptRoot' with "$PSScriptRoot"

## SYNTAX

```
Repair-PSScriptRoot [[-String] <String>] [[-Replacement] <String>]
```

## DESCRIPTION
$PSScriptRoot is usually null inside the param block
This prevents it from being a default parameter value
This function allows a default parameter value to be '$PSScriptRoot'
This reflects informatively in help documentation
Then this function replaces '$PSScriptRoot' with the provided replacement string
The provided replacement string should usually be $PSScriptRoot
# doing it this way allows comment-based help to accurately reflect the default values of these parameters

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -Replacement
Always use -Replacement $PSScriptRoot
This forces $PSScriptRoot to be evaluated in the caller scope
We don't want it to use the $PSScriptRoot for the Repair-PSScriptRoot function

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -String
String that contains an instance '$PSScriptRoot' which we want to replace with "$PSScriptRoot"

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

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
