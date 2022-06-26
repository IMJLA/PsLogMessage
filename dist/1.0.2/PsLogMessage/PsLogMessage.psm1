
function New-DatedSubfolder {
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

function Repair-PSScriptRoot {
    <#
    .SYNOPSIS
        Replaces '$PSScriptRoot' with "$PSScriptRoot"
    .DESCRIPTION
        $PSScriptRoot is usually null inside the param block
        This prevents it from being a default parameter value
        This function allows a default parameter value to be '$PSScriptRoot'
        This reflects informatively in help documentation
        Then this function replaces '$PSScriptRoot' with the provided replacement string
        The provided replacement string should usually be $PSScriptRoot
    # doing it this way allows comment-based help to accurately reflect the default values of these parameters
    #>

    param (
        # String that contains an instance '$PSScriptRoot' which we want to replace with "$PSScriptRoot"
        [string]$String,

        # Always use -Replacement $PSScriptRoot
        # This forces $PSScriptRoot to be evaluated in the caller scope
        # We don't want it to use the $PSScriptRoot for the Repair-PSScriptRoot function
        [string]$Replacement
    )
    $String -replace '\$PSScriptRoot', $Replacement
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
        [string]$Text,

        # Output stream to send the message to
        [string]$Type = 'Information',

        # Add a prefix to the message including the date, hostname, current user, and info about the current call stack
        [bool]$AddPrefix = $true,

        # Text file to append the log message to
        [string]$LogFile,

        # Output the message to the pipeline
        [bool]$PassThru = $false

    )

    $Timestamp = Get-Date -Format s
    $OutputToPipeline = $false
    $ThisHostname = HOSTNAME.EXE
    $WhoAmI = whoami.exe
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

    $Global:LogMessages[$Key] = [pscustomobject]@{
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
$ScriptFiles = Get-ChildItem -Path "$PSScriptRoot\*.ps1" -Recurse

# Dot source any functions
ForEach ($ThisScript in $ScriptFiles) {
    # Dot source the function
    . $($ThisScript.FullName)
}

# Add any custom C# classes as usable (exported) types
$CSharpFiles = Get-ChildItem -Path "$PSScriptRoot\*.cs"
ForEach ($ThisFile in $CSharpFiles) {
    Add-Type -Path $ThisFile.FullName -ErrorAction Stop
}

# Export any public functions
$PublicScriptFiles = $ScriptFiles | Where-Object -FilterScript {
    ($_.PSParentPath | Split-Path -Leaf) -eq 'public'
}
$publicFunctions = $PublicScriptFiles.BaseName
Export-ModuleMember -Function @('New-DatedSubfolder','Repair-PSScriptRoot','Write-LogMsg')

#$Global:LogMessages = [system.collections.generic.list[pscustomobject]]::new()
$Global:LogMessages = [hashtable]::Synchronized(@{})



