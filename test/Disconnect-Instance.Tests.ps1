#Requires -Modules @{ ModuleName='Pester'; ModuleVersion='5.0.0' }, @{ ModuleName='PSDocker'; ModuleVersion='1.5.0' }

Describe 'Disconnect-Instance' {

    BeforeAll {
        Import-Module -Name $PSScriptRoot/../src/PsSqlClient/bin/Release/netstandard2.0/PsSqlClient.psd1 -Force -ErrorAction 'Stop'

        if ( Get-Module -ListAvailable -Name PSDocker ) {
            . ./Helper/New-SqlServer.ps1

            [string] $script:password = 'Passw0rd!'
            [securestring] $script:securePassword = ConvertTo-SecureString $script:password -AsPlainText -Force

            $script:server = New-SqlServer -ServerAdminPassword $script:password -DockerContainerName 'PsSqlClient-Sandbox' -AcceptEula -ErrorAction 'Stop'
        } else {
            $script:missingPsDocker = $true
        }
    }

    AfterAll {
        Remove-DockerContainer -Name 'PsSqlClient-Sandbox' -Force
    }

    BeforeEach {
        $script:connection = Connect-TSqlInstance -ConnectionString $script:server.ConnectionString -RetryCount 3 -ErrorAction 'SilentlyContinue'
    }

    It 'disconnects the instance' -Skip:$script:missingPsDocker {
        Disconnect-TSqlInstance -Connection $script:connection
        $script:connection.State | Should -Be 'Closed'
    }

    It 'disconnects the instance in the session' -Skip:$script:missingPsDocker {
        Disconnect-TSqlInstance
        $script:connection.State | Should -Be 'Closed'
    }

    It 'disconnects the instance in the session' -Skip:$script:missingPsDocker {
        Disconnect-TSqlInstance
        { Disconnect-TSqlInstance } | Should -Throw
    }

}
