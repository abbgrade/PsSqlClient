#Requires -Modules @{ ModuleName='PsDocker'; ModuleVersion='1.5.0' }

function Remove-DockerSqlServer {

    [CmdletBinding()]
    param (
        [Parameter( Mandatory )]
        [string] $DockerContainerName
    )

    Remove-DockerContainer -Name $DockerContainerName -Force
}
