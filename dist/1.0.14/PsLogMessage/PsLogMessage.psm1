
function New-DatedSubfolder {
    # Creates a folder structure with a folder for each year and month
    # Then it creates one timestamped folder inside the appropriate month
    # This folder is intended to be used to store output from a single execution of a script
    param (
        [parameter(Mandatory)]
        [string]$Root
    )
    $Year = Get-Date -Format 'yyyy'
    $Month = Get-Date -Format 'MM'
    $Timestamp = (Get-Date -Format s) -replace ':', '-'

    $NewDir = "$Root\$Year\$Month\$Timestamp"

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

            Adds the log message to a Global variable #TODO: Make this a thread-safe hashtable, using the timestamp as the key

            Optionally writes the message to a log file

            Optionally writes the message to a PowerShell output stream

        .NOTES

    #>

    [CmdletBinding()]
    param(

        # Message to log
        [Parameter(Position = 0, ValueFromPipeline)]
        [string]$Text,

        # Output stream to send the message to
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

        [hashtable]$LogMsgCache = $Global:LogMessages

    )

    $Timestamp = Get-Date -Format 'yyyy-MM-ddThh:mm:ss.ffff'
    $OutputToPipeline = $false
    $PSCallStack = Get-PSCallStack

    if ($AddPrefix) {
        # This method is faster than StringBuilder or the -join operator
        [string]$MessageToLog = "$Timestamp`t$ThisHostname`t$WhoAmI`t$($PSCallStack[1].Location)`t$($PSCallStack[1].Command)`t$($MyInvocation.ScriptLineNumber)`t$($Type)`t$($Text)"
    } else {
        [string]$MessageToLog = $Text
    }

    Switch ($Type) {

        # This will ensure the message is not written to any PowerShell output streams
        'Silent' {}

        # This one is made-up to correspond with the 'success' contextual class in Bootstrap.
        'Success' { Write-Information "SUCCESS: $MessageToLog" }

        # These represent normal PowerShell output streams
        # The correct number of spaces should be added to maintain proper column alignment
        'Debug' { Write-Debug "  $MessageToLog" }
        'Verbose' { Write-Verbose $MessageToLog }
        'Host' { Write-Host "HOST:    $MessageToLog" }
        'Warning' { Write-Warning $MessageToLog }
        'Error' { Write-Error $MessageToLog }
        'Output' { $OutputToPipeline = $true }
        default { Write-Information "INFO:    $MessageToLog" }
    }

    if ('' -ne $LogFile) {
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
        Location  = $PSCallStack[1].Location
        Command   = $PSCallStack[1].Command
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
Export-ModuleMember -Function @('New-DatedSubfolder','Write-LogMsg')

#$Global:LogMessages = [system.collections.generic.list[pscustomobject]]::new()
$Global:LogMessages = [hashtable]::Synchronized(@{})








