#Requires -Modules @{ ModuleName='Pester'; ModuleVersion='5.0.0' }, @{ ModuleName='PSDocker'; ModuleVersion='1.5.0' }

Describe 'Connect-Instance' {

    BeforeAll {
        Import-Module -Name $PSScriptRoot/../src/PsSqlClient/bin/Release/netstandard2.0/PsSqlClient.psd1 -Force -ErrorAction 'Stop'

        . ./Helper/New-SqlServer.ps1

        $script:password = 'Passw0rd!'

        $script:server = New-SqlServer -ServerAdminPassword $script:password -DockerContainerName 'PsSqlClient-Sandbox' -AcceptEula -ErrorAction 'Stop'
    }

    AfterAll {
        Remove-DockerContainer -Name 'PsSqlClient-Sandbox' -Force
    }

    It 'works' {
        $connection = Connect-Instance -ConnectionString $script:server.ConnectionString
        $connection | Should -Not -BeNullOrEmpty
    }
}
