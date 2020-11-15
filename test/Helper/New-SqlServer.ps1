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

    $readyMessage = 'SQL Server is now ready for client connections'
    foreach ( $index in (1..30)) {
        $sqlServerLog = Invoke-DockerCommand -Name $container.Name -Command 'tail --lines=100 /var/opt/mssql/log/errorlog' -ErrorAction 'SilentlyContinue' -WarningAction 'SilentlyContinue' -StringOutput
        if ( $sqlServerLog -and $sqlServerLog.Contains($readyMessage) ) {
            Write-Verbose $readyMessage
            break
        }
        Start-Sleep -Seconds 1
    }
    Start-Sleep -Seconds 5
    $container | Add-Member 'Hostname' 'localhost'
    $container | Add-Member 'ConnectionString' "Server='$( $container.Hostname )';Encrypt=False;User Id='sa';Password='$ServerAdminPassword'"

    # return
    $container | Write-Output
}
