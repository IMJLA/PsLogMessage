function ConvertTo-DnsFqdn {

    # Output the results of a DNS lookup to the default DNS server for the specified
    # Wrapper for [System.Net.Dns]::GetHostByName([string]$ComputerName)

    param (

        # DNS or NetBIOS hostname whose DNS FQDN to lookup
        [Parameter(Mandatory)]
        [string]$ComputerName,

        # Update the ThisFqdn cache instead of returning the Fqdn
        [switch]$ThisFqdn,

        # In-process cache to reduce calls to other processes or disk, and store repetitive parameters for better readability of code and logs
        [Parameter(Mandatory)]
        [ref]$Cache

    )

    Write-LogMsg -Text "[System.Net.Dns]::GetHostByName('$ComputerName')" -Cache $Cache
    $Fqdn = [System.Net.Dns]::GetHostByName($ComputerName).HostName
    if ( $ThisFqdn ) { $Cache.Value['ThisFqdn'].Value = $Fqdn }
    return $Fqdn

}
