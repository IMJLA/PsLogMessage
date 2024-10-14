function Write-LogMsg {

    <#
        .SYNOPSIS
            Prepend a prefix to a log message, write the message to an output stream, and write the message to a text file.
            Writes a message to a log file and/or PowerShell output stream
        .DESCRIPTION
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
        .INPUTS
        [System.String]$Text parameter
        .OUTPUTS
        [System.String] Resulting log line, returned if the -PassThru or -Type Output parameters were used
    #>
    [OutputType([System.String])]
    [CmdletBinding()]
    param(

        # Message to log
        [Parameter(Position = 0, ValueFromPipeline)]
        [string]$Text,

        # Output stream to send the message to
        [ValidateSet('Silent', 'Quiet', 'Success', 'Debug', 'Verbose', 'Output', 'Host', 'Warning', 'Error', 'Information', $null)]
        [string]$Type = 'Information',

        # Add a prefix to the message including the date, hostname, current user, and info about the current call stack
        [bool]$AddPrefix = $true,

        # Text file to append the log message to
        [string]$LogFile,

        # Output the message to the pipeline
        [bool]$PassThru = $false,

        # Hostname to use in the log messages and/or output object
        [string]$ThisHostname = (HOSTNAME.EXE),

        # Hostname to use in the log messages and/or output object
        [string]$WhoAmI = (whoami.EXE),

        # Log messages which have not yet been written to disk
        [hashtable]$Buffer = @{},

        <#
        Splats for the command at the end of the -Text parameter.
        E.g.
            Write-LogMsg -Text 'Get-Process' -Expand @{Name = 'explorer'}
        Has a resultant $Text value of:
            Get-Process -Name explorer
        #>
        [hashtable[]]$Expand,

        # Used to override key-value pairs in the Expand parameter.
        [hashtable]$ExpandKeyMap = @{}

    )

    # This will ensure the message is not written to any PowerShell output streams or log files
    if ($Type -eq 'Silent') { return }

    $Timestamp = Get-Date -Format 'yyyy-MM-ddTHH:mm:ss.ffffK'
    $OutputToPipeline = $false
    $PSCallStack = Get-PSCallStack
    $Location = $PSCallStack[1].Location
    $Command = $PSCallStack[1].Command

    ForEach ($Splat in $Expand) {
        ForEach ($ParamName in $Splat.Keys) {
            $ParamValue = $ExpandKeyMap[$ParamName]
            if (-not $ParamValue) {
                $ParamValue = $Splat[$ParamName]
                if ($ParamValue) {
                    switch ($ParamValue.GetType().FullName) {
                        'System.Collections.Hashtable' {
                            $ParamValue = "`$$ParamName"
                            break
                        }
                        'System.Collections.Hashtable+SyncHashtable' {
                            $ParamValue = "`$$ParamName"
                            break
                        }
                        'System.Int32' {
                            $ParamValue = "($ParamValue)" # paren to encapsulate negative values
                            break
                        }
                        'System.UInt16' {
                            $ParamValue = "($ParamValue)" # paren to encapsulate negative values
                            break
                        }
                        'System.Object[]' {
                            $ParamValue = "@('$($ParamValue -join "','")')"
                            break
                        }
                        'System.String[]' {
                            $ParamValue = "@('$($ParamValue -join "','")')"
                            break
                        }
                        default {
                            if ($ParamName -eq 'CurrentDomain') { pause }
                            $ParamValue = "'$ParamValue'"
                        }
                    }
                } else {
                    # Hopefully this skips appending this parameter but I'm not sure it will 'continue' in the right ForEach scope due to the nesting
                    continue
                }
            }
            $Text = "$Text -$ParamName $ParamValue"
        }
    }

    if ($AddPrefix) {
        # This method is faster than StringBuilder or the -join operator
        $MessageToLog = "$Timestamp`t$ThisHostname`t$WhoAmI`t$Location`t$Command`t$($MyInvocation.ScriptLineNumber)`t$Type`t$Text"
    } else {
        $MessageToLog = $Text
    }

    Switch ($Type) {

        # This will ensure the message is added to log files, but not written to any PowerShell output streams
        'Quiet' { break }

        # This one is made-up to correspond with the 'success' contextual class in Bootstrap.
        'Success' { Write-Information "SUCCESS: $MessageToLog" ; break }

        # These represent normal PowerShell output streams
        # The correct number of spaces should be added to maintain proper column alignment
        'Debug' { Write-Debug "  $MessageToLog" ; break }
        'Verbose' { Write-Verbose $MessageToLog ; break }
        'Host' { Write-Host "HOST:    $MessageToLog" ; break }
        'Warning' { Write-Warning $MessageToLog ; break }
        'Error' { Write-Error $MessageToLog ; break }
        'Output' { $OutputToPipeline = $true ; break }
        default { Write-Information "INFO:    $MessageToLog" ; break }
    }

    if ($PSBoundParameters.ContainsKey('LogFile')) {
        $MessageToLog | Out-File $LogFile -Append
    }

    if ($PassThru -or $OutputToPipeline) {
        $MessageToLog
    }

    # Add a GUID to the timestamp and use it as a unique key in the hashtable of log messages
    [string]$Guid = [guid]::NewGuid()
    [string]$Key = "$Timestamp$Guid"

    $Buffer[$Key] = [pscustomobject]@{
        Timestamp = $Timestamp
        Hostname  = $ThisHostname
        WhoAmI    = $WhoAmI
        Location  = $Location
        Command   = $Command
        Line      = $MyInvocation.ScriptLineNumber
        Type      = $Type
        Text      = $Text
    }

}
