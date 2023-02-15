$LoadedAssemblies = [System.AppDomain]::CurrentDomain.GetAssemblies()

@(
    "$PSScriptRoot\runtimes\win\lib\netstandard2.1\Microsoft.Data.SqlClient.dll",
    "$PSScriptRoot\Microsoft.Identity.Client.dll",
    "$PSScriptRoot\Azure.Core.dll",
    "$PSScriptRoot\Azure.Identity.dll",
    "$PSScriptRoot\Microsoft.SqlServer.Server.dll"
) | ForEach-Object {
    $RequiredAssemblyPath = $_
    $LoadedAssembly = $LoadedAssemblies | Where-Object Location -Like "*$( $RequiredAssemblyPath.Name )"

    if ( $SqlClientAssembly ) {
        Write-Warning "Assembly '$( $LoadedAssembly.GetName() )' already loaded from '$( $LoadedAssembly.Location )'. Skip adding defined dll."
    }
    else {
        Write-Verbose "Add assembly '$( $RequiredAssemblyPath.Name )'"
        Add-Type -Path $RequiredAssemblyPath
    }
}
