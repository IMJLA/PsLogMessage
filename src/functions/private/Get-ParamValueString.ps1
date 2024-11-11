function Get-ParamValueString {

    param ([string[]]$String)

    ForEach ($CurrentString in $String) {

        if ($CurrentString.Contains("'")) {
            "`"$CurrentString`""
        } else {
            "'$CurrentString'"
        }

    }

}
