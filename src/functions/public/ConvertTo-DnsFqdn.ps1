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
        [hashtable]$Buffer = @{}

    )

    $Log = @{
        ThisHostname = $ThisHostname
        Type         = 'Debug'
        Buffer       = $Buffer
        WhoAmI       = $WhoAmI
    }

    Write-LogMsg @Log -Text "[System.Net.Dns]::GetHostByName('$ComputerName')"
    [System.Net.Dns]::GetHostByName($ComputerName).HostName # -replace "^$ThisHostname", "$ThisHostname" #replace does not appear to be needed, capitalization is correct from GetHostByName()

}
