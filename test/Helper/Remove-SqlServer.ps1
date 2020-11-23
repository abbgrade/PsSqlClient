function Remove-SqlServer {
    if ( $isDocker ) {

        . ./Remove-DockerSqlServer.ps1

        Remove-DockerSqlServer -DockerContainerName 'PsSqlClient-Sandbox'
    }
}
