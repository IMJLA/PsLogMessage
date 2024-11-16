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
        [string]$WhoAmI = (whoami.EXE)

    )

    $WhoAmI -replace "^$ThisHostname\\", "$ThisHostname\" -replace "$ENV:USERNAME", $ENV:USERNAME

}
