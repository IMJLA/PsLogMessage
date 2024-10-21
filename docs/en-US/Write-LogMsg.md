---
external help file: PsLogMessage-help.xml
Module Name: PsLogMessage
online version:
schema: 2.0.0
---

# Write-LogMsg

## SYNOPSIS
Prepend a prefix to a log message, write the message to an output stream, and write the message to a text file.
Writes a message to a log file and/or PowerShell output stream

## SYNTAX

```
Write-LogMsg [[-Text] <String>] [-Type <String>] [-Suffix <String>] [-AddPrefix <Boolean>] [-LogFile <String>]
 [-PassThru <Boolean>] [-ThisHostname <String>] [-WhoAmI <String>] [-Buffer <Hashtable>]
 [-Expand <Hashtable[]>] [-ExpandKeyMap <Hashtable>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Prepends the log message with:
    a current timestamp
    the current hostname
    the current username
    the current command (function or file name)
    the current location (line number in the code)

Tab-delimits these fields for a compromise between readability and parseability

Adds the log message to either:
* a hashtable (which can be thread-safe) using the timestamp as the key, which was passed to the $Buffer parameter
* a Global:$LogMessages variable which was created by the PsLogMessage module during import

Optionally writes the message to a log file

Optionally writes the message to a PowerShell output stream

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -AddPrefix
Add a prefix to the message including the date, hostname, current user, and info about the current call stack

```yaml
Type: System.Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: True
Accept pipeline input: False
Accept wildcard characters: False
```

### -Buffer
Log messages which have not yet been written to disk

```yaml
Type: System.Collections.Hashtable
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: @{}
Accept pipeline input: False
Accept wildcard characters: False
```

### -Expand
Splats for the command at the end of the -Text parameter.
E.g.
    Write-LogMsg -Text 'Get-Process' -Expand @{Name = 'explorer'}
Has a resultant $Text value of:
    Get-Process -Name explorer

```yaml
Type: System.Collections.Hashtable[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExpandKeyMap
Used to override key-value pairs in the Expand parameter.

```yaml
Type: System.Collections.Hashtable
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: @{}
Accept pipeline input: False
Accept wildcard characters: False
```

### -LogFile
Text file to append the log message to

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PassThru
Output the message to the pipeline

```yaml
Type: System.Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
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

### -Suffix
Suffix to append to the end of the string

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Text
Message to log

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -ThisHostname
Hostname to use in the log messages and/or output object

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: (HOSTNAME.EXE)
Accept pipeline input: False
Accept wildcard characters: False
```

### -Type
Output stream to send the message to

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: Information
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhoAmI
Hostname to use in the log messages and/or output object

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: (whoami.EXE)
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### [System.String]$Text parameter
## OUTPUTS

### [System.String] Resulting log line, returned if the -PassThru or -Type Output parameters were used
## NOTES

## RELATED LINKS
