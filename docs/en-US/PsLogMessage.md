---
Module Name: PsLogMessage
Module Guid: 2d9d8fd4-afc2-45e9-93b3-5939c590adc7
Download Help Link: {{ Update Download Link }}
Help Version: 1.0.46
Locale: en-US
---

# PsLogMessage Module
## Description
Logs, displays, and outputs log messages after adding metadata such as timestamp, hostname, etc.

## PsLogMessage Cmdlets
### [ConvertTo-DnsFqdn](ConvertTo-DnsFqdn.md)

ConvertTo-DnsFqdn [[-ComputerName] <string>] [[-ThisHostName] <string>] [[-WhoAmI] <string>] [[-LogBuffer] <hashtable>]


### [Get-CurrentHostname](Get-CurrentHostname.md)

Get-CurrentHostName 


### [Get-CurrentWhoAmI](Get-CurrentWhoAmI.md)

Get-CurrentWhoAmI [[-ThisHostName] <string>] [[-WhoAmI] <string>] [[-LogBuffer] <hashtable>]


### [New-DatedSubfolder](New-DatedSubfolder.md)

New-DatedSubfolder [-Root] <string> [[-Suffix] <string>] [<CommonParameters>]


### [Write-LogMsg](Write-LogMsg.md)
Prepend a prefix to a log message, write the message to an output stream, and write the message to a text file.
Writes a message to a log file and/or PowerShell output stream


