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

        Adds the log message to a ConcurrentQueue which was passed to the $Buffer parameter

        Optionally writes the message to a log file

        Optionally writes the message to a PowerShell output stream
    .INPUTS
    [System.String[]]$Text parameter
    .OUTPUTS
    [System.String] Resulting log line, returned if the -PassThru or -Type Output parameters were used
    #>

    [OutputType([System.String])]
    [CmdletBinding()]

    param(

        # Message to log
        [Parameter(Position = 0, ValueFromPipeline)]
        [string[]]$Text,

        # Suffix to append to the end of the string
        [string]$Suffix,

        # Add a prefix to the message including the date, hostname, current user, and info about the current call stack
        [bool]$AddPrefix = $true,

        # Text file to append the log message to
        [string]$LogFile,

        # Output the message to the pipeline
        [bool]$PassThru = $false,

        <#
        Splats for the command at the end of the -Text parameter.
        E.g.
            Write-LogMsg -Text 'Get-Process' -Expand @{Name = 'explorer'}
        Has a resultant $Text value of:
            Get-Process -Name explorer
        #>
        [hashtable[]]$Expand,

        # Output stream to send the message to
        [Parameter(ParameterSetName = 'NoCache')]
        [ValidateSet('Silent', 'Quiet', 'Success', 'Debug', 'Verbose', 'Output', 'Host', 'Warning', 'Error', 'Information', $null)]
        [string]$Type,

        # Hostname to use in the log messages and/or output object
        [Parameter(ParameterSetName = 'NoCache')]
        [string]$ThisHostname,

        # Hostname to use in the log messages and/or output object
        [Parameter(ParameterSetName = 'NoCache')]
        [string]$WhoAmI,

        # Log messages which have not yet been written to disk
        [Parameter(Mandatory, ParameterSetName = 'NoCache')]
        [ref]$Buffer,

        # Used to override key-value pairs in the Expand parameter.
        [Parameter(ParameterSetName = 'NoCache')]
        [hashtable]$ExpandKeyMap,

        [Parameter(ParameterSetName = 'NoCache')]
        [hashtable]$ParamStringMap,

        # In-process cache to reduce calls to other processes or disk, and store repetitive parameters for better readability of code and logs
        [Parameter(Mandatory, ParameterSetName = 'Cache')]
        [ref]$Cache,

        # Used to override key-value pairs in the Expand parameter.
        [Parameter(ParameterSetName = 'Cache')]
        [hashtable]$ExpansionMap = $Cache.Value['LogEmptyMap'].Value

    )

    begin {

        # This will ensure the message is not written to any PowerShell output streams or log files
        if ($Type -eq 'Silent') { return }

        $Timestamp = Get-Date -Format 'yyyy-MM-ddTHH:mm:ss.ffffK'
        $OutputToPipeline = $false
        $PSCallStack = Get-PSCallStack
        $Caller = $PSCallStack[1]
        $Location = $Caller.Location
        $Command = $Caller.Command

        if ($PSCmdlet.ParameterSetName -eq 'Cache') {
            [string]$Type = $Cache.Value['LogType'].Value
            [string]$ThisHostname = $Cache.Value['ThisHostname'].Value
            [string]$WhoAmI = $Cache.Value['WhoAmI'].Value
            [ref]$Buffer = $Cache.Value['LogBuffer']
            [hashtable]$ParamStringMap = $Cache.Value['ParamStringMap'].Value
            [hashtable]$ExpandKeyMap = $ExpansionMap
        } else {

            if (-not $PSBoundParameters.ContainsKey('Type')) {
                $Type = 'Information'
            }

            if (-not $PSBoundParameters.ContainsKey('ThisHostname')) {
                $ThisHostname = HOSTNAME.EXE
            }

            if (-not $PSBoundParameters.ContainsKey('WhoAmI')) {
                $WhoAmI = whoami.EXE
            }

            if (-not $PSBoundParameters.ContainsKey('ExpandKeyMap')) {
                $ExpandKeyMap = @{}
            }

            if (-not $PSBoundParameters.ContainsKey('ParamStringMap')) {
                $ParamStringMap = Get-ParamStringMap
            }

        }

    }

    process {

        ForEach ($String in $Text) {

            ForEach ($Splat in $Expand) {

                ForEach ($ParamName in $Splat.Keys) {

                    $ParamValue = $ExpandKeyMap[$ParamName]

                    if ($null -eq $ParamValue) {

                        $ParamValue = $Splat[$ParamName]

                        if ($null -ne $ParamValue) {

                            $TypeName = $ParamValue.GetType().FullName
                            $ValueScript = $ParamStringMap[$TypeName]

                            if ($ValueScript) {
                                $ParamValue = Invoke-Command -Command $ValueScript -ArgumentList $ParamName, $ParamValue
                            } else {
                                $ParamValue = "'$ParamValue'"
                            }

                        } else {

                            # Hopefully this skips appending this parameter but I'm not sure it will 'continue' in the right ForEach scope due to the nesting
                            continue

                        }

                    }

                    $String = "$String -$ParamName $ParamValue"

                }

            }

            $FullText = "$String$Suffix"

            if ($AddPrefix) {
                # This method is faster than StringBuilder or the -join operator
                $MessageToLog = "$Timestamp`t$ThisHostname`t$WhoAmI`t$Location`t$Command`t$($MyInvocation.ScriptLineNumber)`t$Type`t$FullText"
            } else {
                $MessageToLog = $FullText
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

            $Obj = [ordered]@{
                Timestamp = $Timestamp
                Hostname  = $ThisHostname
                WhoAmI    = $WhoAmI
                Location  = $Location
                Command   = $Command
                Line      = $MyInvocation.ScriptLineNumber
                Type      = $Type
                Text      = $FullText
            }

            $null = $Buffer.Value.Enqueue($Obj)

        }

    }

}
