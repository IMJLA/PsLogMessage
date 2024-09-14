function ConvertTo-PSCodeString {

    <#
        .SYNOPSIS
            Convert an object or array of objects into a code string which could be converted into a ScriptBlock with valid PowerShell syntax
        .DESCRIPTION
            Originally used for hashtables and arrays
        .INPUTS
        $InputObject parameter
        .OUTPUTS
        [System.String] Resulting PowerShell code
    #>
    [OutputType([System.String])]
    [CmdletBinding()]

    param (

        # Object to convert to a PowerShell code string
        $InputObject

    )

    if ($InputObject) {
        switch ($InputObject.GetType().FullName) {
            'System.Collections.Hashtable' {
                $Strings = ForEach ($OriginalKey in $InputObject.Keys) {
                    $Key = ConvertTo-PSCodeString -InputObject $OriginalKey
                    $Value = ConvertTo-PSCodeString -InputObject $InputObject[$OriginalKey]
                    "$Key=$Value"
                }
                "@{$($Strings -join ';')}"
            }
            'System.Object[]' {
                $Strings = ForEach ($Object in $InputObject) {
                    ConvertTo-PSCodeString -InputObject $Object
                }
                "@($($Strings -join ','))"
            }
            'System.String' {
                if ($InputObject.Contains("'")) {
                    $Value = $InputObject.Replace('"', '`"')
                    "`"$Value`""
                } else {
                    "'$InputObject'"
                }
            }
            default { "$InputObject" }
        }
    } else {
        "`$null"
    }

}
