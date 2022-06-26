
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
