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
        [hashtable]$LogBuffer = @{}

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
