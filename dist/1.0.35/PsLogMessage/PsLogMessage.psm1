
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

        # Dictionary of log messages for Write-LogMsg (can be thread-safe if a synchronized hashtable is provided)
        [hashtable]$LogMsgCache = @{}

    )
    $LogParams = @{
        ThisHostname = $ThisHostname
        Type         = 'Debug'
        LogMsgCache  = $LogMsgCache
        WhoAmI       = $WhoAmI
    }
    Write-LogMsg @LogParams -Text "[System.Net.Dns]::GetHostByName('$ComputerName')"
    [System.Net.Dns]::GetHostByName($ComputerName).HostName # -replace "^$ThisHostname", "$ThisHostname" #replace does not appear to be needed, capitalization is correct from GetHostByName()

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

        # Dictionary of log messages for Write-LogMsg (can be thread-safe if a synchronized hashtable is provided)
        [hashtable]$LogMsgCache = @{}

    )
    $WhoAmI -replace "^$ThisHostname\\", "$ThisHostname\" -replace "$ENV:USERNAME", $ENV:USERNAME
    if (-not $PSBoundParameters.ContainsKey('WhoAmI')) {
        $LogParams = @{
            ThisHostname = $ThisHostname
            Type         = 'Debug'
            LogMsgCache  = $LogMsgCache
            WhoAmI       = $WhoAmI
        }
        # This exe has already been run as the default value for the parameter if it was not specified
        # Log it now, with the correct capitalization
        Write-LogMsg @LogParams -Text 'whoami.exe # This command was already run but is now being logged'
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

            Adds the log message to either:
            * a hashtable (which can be thread-safe) using the timestamp as the key, which was passed to the $LogMsgCache parameter
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

        [hashtable]$LogMsgCache = @{}

    )


    # This will ensure the message is not written to any PowerShell output streams or log files
    if ($Type -eq 'Silent') { return }

    $Timestamp = Get-Date -Format 'yyyy-MM-ddTHH:mm:ss.ffffK'
    $OutputToPipeline = $false
    $PSCallStack = Get-PSCallStack
    $Location = $PSCallStack[1].Location
    $Command = $PSCallStack[1].Command

    if ($AddPrefix) {
        # This method is faster than StringBuilder or the -join operator
        $MessageToLog = "$Timestamp`t$ThisHostname`t$WhoAmI`t$Location`t$Command`t$($MyInvocation.ScriptLineNumber)`t$($Type)`t$($Text)"
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

    $LogMsgCache[$Key] = [pscustomobject]@{
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
<#
# Add any custom C# classes as usable (exported) types
$CSharpFiles = Get-ChildItem -Path "$PSScriptRoot\*.cs"
ForEach ($ThisFile in $CSharpFiles) {
    Add-Type -Path $ThisFile.FullName -ErrorAction Stop
}
#>
Export-ModuleMember -Function @('ConvertTo-DnsFqdn','Get-CurrentHostname','Get-CurrentWhoAmI','New-DatedSubfolder','Write-LogMsg')

#$Global:LogMessages = [system.collections.generic.list[pscustomobject]]::new()
$Global:LogMessages = [hashtable]::Synchronized(@{})





























