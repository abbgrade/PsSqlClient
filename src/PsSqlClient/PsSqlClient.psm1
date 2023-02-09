$assemblyLoaded = [System.AppDomain]::CurrentDomain.GetAssemblies() | Where-Object Location -like "*Microsoft.Data.SqlClient.dll"
if ([string]::IsNullOrEmpty($assemblyLoaded)) {
    Add-Type -AssemblyName $PSScriptRoot\runtimes\win\lib\netcoreapp3.1\Microsoft.Data.SqlClient.dll
}
Add-Type -Path $PSScriptRoot\Microsoft.Identity.Client.dll
Add-Type -Path $PSScriptRoot\Azure.Core.dll
Add-Type -Path $PSScriptRoot\Azure.Identity.dll
