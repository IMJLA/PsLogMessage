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
        [hashtable]$Buffer = @{},

        <#
        Hostname of the computer running this function.

        Can be provided as a string to avoid calls to HOSTNAME.EXE
        #>
        [String]$ThisHostName = (HOSTNAME.EXE),

        # Username to record in log messages (can be passed to Write-LogMsg as a parameter to avoid calling an external process)
        [String]$WhoAmI = (whoami.EXE),

        # Log messages which have not yet been written to disk
        [Hashtable]$LogBuffer = @{},

        # Output stream to send the log messages to
        [ValidateSet('Silent', 'Quiet', 'Success', 'Debug', 'Verbose', 'Output', 'Host', 'Warning', 'Error', 'Information', $null)]
        [String]$DebugOutputStream = 'Debug'

    )

    $Log = @{
        Buffer       = $Buffer
        ThisHostname = $ThisHostname
        Type         = $DebugOutputStream
        WhoAmI       = $WhoAmI
    }

    Write-LogMsg @Log -Text "`$Buffer.Values | Sort-Object -Property Timestamp | Export-Csv -Delimiter '$('`t')' -NoTypeInformation -LiteralPath '$LogFile'"

    $Buffer.Values | Sort-Object -Property Timestamp |
    Export-Csv -Delimiter "`t" -NoTypeInformation -LiteralPath $LogFile

    # Write the full path of the log file to the Information stream
    Write-Information $LogFile

}
