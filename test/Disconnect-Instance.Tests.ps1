#Requires -Modules @{ ModuleName='Pester'; ModuleVersion='5.0.0' }, @{ ModuleName='PSDocker'; ModuleVersion='1.5.0' }

Describe 'Disconnect-Instance' {

    BeforeAll {
        Import-Module -Name $PSScriptRoot/../src/PsSqlClient/bin/Release/netstandard2.0/PsSqlClient.psd1 -Force -ErrorAction 'Stop'

        if ( Get-Module -ListAvailable -Name PSDocker ) {
            . ./Helper/New-SqlServer.ps1

            [string] $script:password = 'Passw0rd!'
            [securestring] $script:securePassword = ConvertTo-SecureString $script:password -AsPlainText -Force

            $script:server = New-SqlServer -ServerAdminPassword $script:password -DockerContainerName 'PsSqlClient-Sandbox' -AcceptEula -ErrorAction 'Stop'
            $script:connection = Connect-Instance -ConnectionString $script:server.ConnectionString
        } else {
            $script:missingPsDocker = $true
        }
    }

    AfterAll {
        Remove-DockerContainer -Name 'PsSqlClient-Sandbox' -Force
    }

    It 'disconnects the instance' -Skip:$script:missingPsDocker {
        Disconnect-Instance -Connection $script:connection
        $script:connection.State | Should -Be 'Closed'
    }

}
