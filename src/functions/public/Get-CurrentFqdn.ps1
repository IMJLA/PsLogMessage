function Get-CurrentFqdn {

    # Output the results of a DNS lookup to the default DNS server for the current hostname

    # Wrapper for [System.Net.Dns]::GetHostByName([string])

    param (

        <#
        Hostname of the computer running this function.

        Can be provided as a string to avoid calls to HOSTNAME.EXE
        #>
        [string]$ThisHostName = (HOSTNAME.EXE),

        # Username to record in log messages (can be passed to Write-LogMsg as a parameter to avoid calling an external process)
        [string]$WhoAmI = (whoami.EXE),

        # Dictionary of log messages for Write-LogMsg (can be thread-safe if a synchronized hashtable is provided)
        [hashtable]$LogMsgCache = $Global:LogMessages

    )
    $LogParams = @{
        ThisHostname = $ThisHostname
        Type         = 'Debug'
        LogMsgCache  = $LogMsgCache
        WhoAmI       = $WhoAmI
    }
    Write-LogMsg @LogParams -Text "[System.Net.Dns]::GetHostByName($ThisHostName)"
    [System.Net.Dns]::GetHostByName($ThisHostName).HostName # -replace "^$ThisHostname", "$ThisHostname" #replace does not appear to be needed, capitalization is correct from GetHostByName()

}
