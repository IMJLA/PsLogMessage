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
Write-LogMsg [[-Text] <String>] [-Type <String>] [-AddPrefix <Boolean>] [-LogFile <String>]
 [-PassThru <Boolean>] [-ThisHostname <String>] [-WhoAmI <String>] [-LogMsgCache <Hashtable>]
 [<CommonParameters>]
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
* a hashtable (which can be thread-safe) using the timestamp as the key, which was passed to the $LogMsgCache parameter
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

### -LogMsgCache
{{ Fill LogMsgCache Description }}

```yaml
Type: System.Collections.Hashtable
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: $Global:LogMessages
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
