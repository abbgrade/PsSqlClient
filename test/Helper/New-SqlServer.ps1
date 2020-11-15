#Requires -Modules @{ ModuleName='PsDocker'; ModuleVersion='1.5.0' }

function New-SqlServer {

    [CmdletBinding()]
    param (
        [Parameter( Mandatory )]
        [ValidateNotNullOrEmpty()]
        [string] $ServerAdminPassword,

        [Parameter( Mandatory )]
        [string] $DockerContainerName,

        [Parameter( Mandatory )]
        [switch] $AcceptEula
    )

    # prepare parameter
    if ( -not $AcceptEula ) {
        throw "Accept the Microsoft EULA with -AcceptEula"
    }
    $environment = @{
        'ACCEPT_EULA' = "Y"
    }

    $environment['MSSQL_SA_PASSWORD'] = $ServerAdminPassword

    # create container
    $container = New-DockerContainer `
        -Image 'mcr.microsoft.com/mssql/server' `
        -Name $DockerContainerName `
        -Environment $environment `
        -Ports @{
        1433 = 1433
    } -Detach
    Start-Sleep -Seconds 10 # wait until service is up and running
    $container | Add-Member 'Hostname' 'localhost'
    $container | Add-Member 'ConnectionString' "Server='$( $container.Hostname )';Encrypt=False;User Id='sa';Password='$ServerAdminPassword'"

    # return
    $container | Write-Output
}
