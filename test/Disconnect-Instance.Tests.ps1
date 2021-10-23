#Requires -Modules @{ ModuleName='Pester'; ModuleVersion='5.0.0' }

Describe 'Disconnect-Instance' {

    BeforeAll {
        Import-Module $PSScriptRoot/../src/PsSqlClient/bin/Debug/netcoreapp2.1/publish/PsSqlClient.psd1 -Force -ErrorAction Stop

        . $PsScriptRoot/Helper/New-SqlServer.ps1
        $script:server = New-SqlServer -ErrorAction Stop
    }

    AfterAll {
        . $PsScriptRoot/Helper/Remove-SqlServer.ps1
        Remove-SqlServer
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
