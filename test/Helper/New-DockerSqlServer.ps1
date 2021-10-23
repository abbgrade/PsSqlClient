#Requires -Modules @{ ModuleName='PsDocker'; ModuleVersion='1.5.0' }

function New-DockerSqlServer {

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

    if ( -not $AcceptEula ) {
        throw "Accept the Microsoft EULA with -AcceptEula"
    }

    $environment = @{
        'ACCEPT_EULA' = "Y"
    }

    switch ( ( Get-DockerVersion ).Server.Engine.OSArch ) {
        'linux/amd64' {
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
        }
        'windows/amd64' {
            $environment['sa_password'] = $ServerAdminPassword

            # create container
            $container = New-DockerContainer `
                -Image 'microsoft/mssql-server-windows-developer' `
                -Name $DockerContainerName `
                -Environment $environment `
                -Ports @{
                1433 = 1433
            } -Detach -ErrorAction Stop

            foreach ( $index in (1..30)) {
                $status = Invoke-DockerCommand -Name $container.Name -Command 'powershell -C "Get-Service -Name MSSQLSERVER" | Select -ExpandProperty Status' -StringOutput -ErrorAction 'SilentlyContinue'
                if ( $status -eq 'Running' ) {
                    break
                }
                Start-Sleep -Seconds 1
            }

        }
        default {
            throw "$_ not implemented"
        }
    }

    $container | Add-Member 'Hostname' 'localhost'
    $container | Add-Member 'UserId' 'sa'
    $container | Add-Member 'ConnectionString' "Server='$( $container.Hostname )';Encrypt=False;User Id='$( $container.UserId )';Password='$ServerAdminPassword'"

    # return
    $container | Write-Output
}
