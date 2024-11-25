function Get-ParamStringMap {

    return @{

        'System.Collections.Hashtable'                 = {
            param ($ParamName, $ParamValue)
            "`$$ParamName"
        }

        'System.Collections.Hashtable+SyncHashtable'   = {
            param ($ParamName, $ParamValue)
            "`$$ParamName"
        }

        'System.Int32'                                 = {
            param ($ParamName, $ParamValue)
            "($ParamValue)" # paren to encapsulate negative values
        }

        'System.UInt16'                                = {
            param ($ParamName, $ParamValue)
            "($ParamValue)" # paren to encapsulate negative values
        }

        'System.Object[]'                              = {
            param ($ParamName, $ParamValue)
            "@('$($ParamValue -join "','")')"
        }

        'System.String[]'                              = {
            param ($ParamName, $ParamValue)
            $NewValues = Get-ParamValueString -String $ParamValue
            "@($($NewValues -join ','))"
        }

        'System.Management.Automation.PSCustomObject'  = {
            param ($ParamName, $ParamValue)
            "[PSCustomObject]$ParamValue"
        }

        'System.String'                                = {
            param ($ParamName, $ParamValue)
            Get-ParamValueString -String $ParamValue
        }

        'System.Boolean'                               = {
            param ($ParamName, $ParamValue)
            "`$$ParamValue"
        }

        'System.Management.Automation.SwitchParameter' = {
            param ($ParamName, $ParamValue)
            "`$$ParamValue"
        }

    }

}
