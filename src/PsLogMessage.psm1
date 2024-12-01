<#
# Add any custom C# classes as usable (exported) types
$CSharpFiles = Get-ChildItem -Path "$PSScriptRoot\*.cs"
ForEach ($ThisFile in $CSharpFiles) {
    Add-Type -Path $ThisFile.FullName -ErrorAction Stop
}
#>
Export-ModuleMember -Function @('ConvertTo-DnsFqdn','ConvertTo-PSCodeString','Export-LogCsv','Get-CurrentHostname','Get-CurrentWhoAmI','Get-ParamStringMap','New-DatedSubfolder','Write-LogMsg')




























