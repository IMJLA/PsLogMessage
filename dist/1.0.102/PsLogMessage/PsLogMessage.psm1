
function Get-ParamStringMap {

    return @{

        'System.Collections.Hashtable'                 = {
            param ($ParamName, $ParamValue)
            "`$$ParamName"
        }

        'System.Collections.Hashtable+SyncHashtable'   = {
            param ($ParamName, $ParamValue)
            "`$$ParamName"
        }

        'System.Int32'                                 = {
            param ($ParamName, $ParamValue)
            "($ParamValue)" # paren to encapsulate negative values
        }

        'System.UInt16'                                = {
            param ($ParamName, $ParamValue)
            "($ParamValue)" # paren to encapsulate negative values
        }

        'System.Object[]'                              = {
            param ($ParamName, $ParamValue)
            "@('$($ParamValue -join "','")')"
        }

        'System.String[]'                              = {
            param ($ParamName, $ParamValue)
            $NewValues = Get-ParamValueString -String $ParamValue
            "@($($NewValues -join ','))"
        }

        'System.Management.Automation.PSCustomObject'  = {
            param ($ParamName, $ParamValue)
            "[PSCustomObject]$ParamValue"
        }

        'System.String'                                = {
            param ($ParamName, $ParamValue)
            Get-ParamValueString -String $ParamValue
        }

        'System.Boolean'                               = {
            param ($ParamName, $ParamValue)
            "`$$ParamValue"
        }

        'System.Management.Automation.SwitchParameter' = {
            param ($ParamName, $ParamValue)
            "`$$ParamValue"
        }

    }

}
function Get-ParamValueString {

    param ([string[]]$String)

    ForEach ($CurrentString in $String) {

        if ($CurrentString.Contains("'")) {
            "`"$CurrentString`""
        } else {
            "'$CurrentString'"
        }

    }

}
function ConvertTo-DnsFqdn {

    # Output the results of a DNS lookup to the default DNS server for the specified

    # Wrapper for [System.Net.Dns]::GetHostByName([string]$ComputerName)

    param (

        [string]$ComputerName,

        <#
        Hostname of the computer running this function.

        Can be provided as a string to avoid calls to HOSTNAME.EXE
        #>
        [string]$ThisHostName = (HOSTNAME.EXE),

        # Username to record in log messages (can be passed to Write-LogMsg as a parameter to avoid calling an external process)
        [string]$WhoAmI = (whoami.EXE),

        # Log messages which have not yet been written to disk
        [Parameter(Mandatory)]
        [ref]$LogBuffer,

        # Output stream to send the log messages to
        [ValidateSet('Silent', 'Quiet', 'Success', 'Debug', 'Verbose', 'Output', 'Host', 'Warning', 'Error', 'Information', $null)]
        [String]$DebugOutputStream = 'Debug'

    )

    $Log = @{
        ThisHostname = $ThisHostname
        Type         = $DebugOutputStream
        Buffer       = $LogBuffer
        WhoAmI       = $WhoAmI
    }

    Write-LogMsg @Log -Text "[System.Net.Dns]::GetHostByName('$ComputerName')"
    [System.Net.Dns]::GetHostByName($ComputerName).HostName # -replace "^$ThisHostname", "$ThisHostname" #replace does not appear to be needed, capitalization is correct from GetHostByName()

}
function ConvertTo-PSCodeString {

    <#
        .SYNOPSIS
            Convert an object or array of objects into a code string which could be converted into a ScriptBlock with valid PowerShell syntax
        .DESCRIPTION
            Originally used for hashtables and arrays
        .INPUTS
            $InputObject parameter
        .OUTPUTS
            [System.String] Resulting PowerShell code
    #>
    [OutputType([System.String])]
    [CmdletBinding()]

    param (

        # Object to convert to a PowerShell code string
        $InputObject

    )

    if ($InputObject) {
        switch ($InputObject.GetType().FullName) {
            'System.Collections.Hashtable' {
                $Strings = ForEach ($OriginalKey in $InputObject.Keys) {
                    $Key = ConvertTo-PSCodeString -InputObject $OriginalKey
                    $Value = ConvertTo-PSCodeString -InputObject $InputObject[$OriginalKey]
                    "$Key=$Value"
                }
                "@{$($Strings -join ';')}"
            }
            'System.Object[]' {
                $Strings = ForEach ($Object in $InputObject) {
                    ConvertTo-PSCodeString -InputObject $Object
                }
                "@($($Strings -join ','))"
            }
            'System.String' {
                if ($InputObject.Contains("'")) {
                    $Value = $InputObject.Replace('"', '`"')
                    "`"$Value`""
                } else {
                    "'$InputObject'"
                }
            }
            default { "$InputObject" }
        }
    } else {
        "`$null"
    }

}
function Export-LogCsv {

    <#
        .SYNOPSIS
            Export a hashtable of log message objects to a CSV file.
        .DESCRIPTION
            Sort the log message objects by their Timestamp property.
            Export the log message objects to a CSV file.
            Write the file path to the Information stream.
        .INPUTS
        [System.String]$LogFile parameter
        .OUTPUTS
        None.  The value of $LogFile is written to the Information stream.
    #>
    [OutputType([System.String])]
    [CmdletBinding()]
    param(

        # Log file to create
        [string]$LogFile,

        # Log messages which have not yet been written to disk
        [Parameter(Mandatory)]
        [ref]$Buffer,

        <#
        Hostname of the computer running this function.

        Can be provided as a string to avoid calls to HOSTNAME.EXE
        #>
        [String]$ThisHostName = (HOSTNAME.EXE),

        # Username to record in log messages (can be passed to Write-LogMsg as a parameter to avoid calling an external process)
        [String]$WhoAmI = (whoami.EXE),

        # Output stream to send the log messages to
        [ValidateSet('Silent', 'Quiet', 'Success', 'Debug', 'Verbose', 'Output', 'Host', 'Warning', 'Error', 'Information', $null)]
        [String]$DebugOutputStream = 'Debug',

        # ID of the parent progress bar under which to show progres
        [int]$ProgressParentId

    )

    $Log = @{
        Buffer       = $Buffer
        ThisHostname = $ThisHostname
        Type         = $DebugOutputStream
        WhoAmI       = $WhoAmI
    }

    Write-LogMsg @Log -Text "`$Buffer.Values | Sort-Object -Property Timestamp | Export-Csv -Delimiter '$('`t')' -NoTypeInformation -LiteralPath '$LogFile'"

    $Buffer.Value.GetEnumerator() |
    Export-Csv -Delimiter "`t" -NoTypeInformation -LiteralPath $LogFile

    # Write the full path of the log file to the Information stream
    Write-Information $LogFile

}
function Get-CurrentHostName {
    # Future function to universally retrieve hostname using various methods (in order of preference):
    # hostname.exe
    # $env:hostname
    # CIM
    # other?
}
function Get-CurrentWhoAmI {

    # Output the results of whoami.exe after editing them to correct capitalization of both the hostname and the account name

    # whoami.exe returns lowercase but we want to honor the correct capitalization

    # Correct capitalization is returned from $ENV:USERNAME

    param (

        <#
        Hostname of the computer running this function.

        Can be provided as a string to avoid calls to HOSTNAME.EXE
        #>
        [string]$ThisHostName = (HOSTNAME.EXE),

        # Username to record in log messages (can be passed to Write-LogMsg as a parameter to avoid calling an external process)
        [string]$WhoAmI = (whoami.EXE),

        # Log messages which have not yet been written to disk
        [Parameter(Mandatory)]
        [ref]$LogBuffer

    )

    $WhoAmI -replace "^$ThisHostname\\", "$ThisHostname\" -replace "$ENV:USERNAME", $ENV:USERNAME

    if (-not $PSBoundParameters.ContainsKey('WhoAmI')) {

        $Log = @{
            ThisHostname = $ThisHostname
            Type         = 'Debug'
            Buffer       = $LogBuffer
            WhoAmI       = $WhoAmI
        }

        # This exe has already been run as the default value for the parameter if it was not specified
        # Log it now, with the correct capitalization
        Write-LogMsg @Log -Text 'whoami.exe # This command was already run but is now being logged'

    }

}
function New-DatedSubfolder {
    # Creates a folder structure with a folder for each year and month
    # Then it creates one timestamped folder inside the appropriate month
    # This folder is intended to be used to store output from a single execution of a script
    param (
        [parameter(Mandatory)]
        [string]$Root,

        # A suffix to append to the folder name
        [string]$Suffix
    )
    $Year = Get-Date -Format 'yyyy'
    $Month = Get-Date -Format 'MM'
    $Timestamp = (Get-Date -Format s) -replace ':', '-'

    $NewDir = "$Root\$Year\$Month\$Timestamp$Suffix"

    $null = New-Item -ItemType Directory -Path $NewDir -ErrorAction SilentlyContinue
    Write-Output $NewDir
}
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

        # Suffix to append to the end of the string
        [string]$Suffix,

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
        [Parameter(Mandatory)]
        [ref]$Buffer,

        <#
        Splats for the command at the end of the -Text parameter.
        E.g.
            Write-LogMsg -Text 'Get-Process' -Expand @{Name = 'explorer'}
        Has a resultant $Text value of:
            Get-Process -Name explorer
        #>
        [hashtable[]]$Expand,

        # Used to override key-value pairs in the Expand parameter.
        [hashtable]$ExpandKeyMap = @{},

        [hashtable]$ParamStringMap = (Get-ParamStringMap)

    )

    # This will ensure the message is not written to any PowerShell output streams or log files
    if ($Type -eq 'Silent') { return }

    $Timestamp = Get-Date -Format 'yyyy-MM-ddTHH:mm:ss.ffffK'
    $OutputToPipeline = $false
    $PSCallStack = Get-PSCallStack
    $Caller = $PSCallStack[1]
    $Location = $Caller.Location
    $Command = $Caller.Command

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

            $Text = "$Text -$ParamName $ParamValue"

        }

    }

    if ($AddPrefix) {
        # This method is faster than StringBuilder or the -join operator
        $MessageToLog = "$Timestamp`t$ThisHostname`t$WhoAmI`t$Location`t$Command`t$($MyInvocation.ScriptLineNumber)`t$Type`t$Text$Suffix"
    } else {
        $MessageToLog = "$Text$Suffix"
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

    $Obj = @{
        Timestamp = $Timestamp
        Hostname  = $ThisHostname
        WhoAmI    = $WhoAmI
        Location  = $Location
        Command   = $Command
        Line      = $MyInvocation.ScriptLineNumber
        Type      = $Type
        Text      = $Text
    }

    $null = $Buffer.Value.Enqueue($Obj)

}
<#
# Add any custom C# classes as usable (exported) types
$CSharpFiles = Get-ChildItem -Path "$PSScriptRoot\*.cs"
ForEach ($ThisFile in $CSharpFiles) {
    Add-Type -Path $ThisFile.FullName -ErrorAction Stop
}
#>
Export-ModuleMember -Function @('ConvertTo-DnsFqdn','ConvertTo-PSCodeString','Export-LogCsv','Get-CurrentHostname','Get-CurrentWhoAmI','New-DatedSubfolder','Write-LogMsg')

















