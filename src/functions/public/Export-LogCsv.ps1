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

        # In-process cache to reduce calls to other processes or disk, and store repetitive parameters for better readability of code and logs
        [Parameter(Mandatory)]
        [ref]$Cache

    )

    Write-LogMsg -Cache $Cache -Text "`$Cache.Value['LogBuffer'].Value.GetEnumerator() | Export-Csv -Delimiter '$('`t')' -NoTypeInformation -LiteralPath '$LogFile'"

    $Cache.Value['LogBuffer'].Value.GetEnumerator() |
    Export-Csv -Delimiter "`t" -NoTypeInformation -LiteralPath $LogFile

    # Write the full path of the log file to the Information stream
    Write-Information $LogFile

}
