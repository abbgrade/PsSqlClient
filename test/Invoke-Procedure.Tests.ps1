#Requires -Modules @{ ModuleName='Pester'; ModuleVersion='5.0.0' }, @{ ModuleName='PSDocker'; ModuleVersion='1.5.0' }

Describe 'Invoke-Procedure' {

    BeforeAll {
        Import-Module -Name $PSScriptRoot/../src/PsSqlClient/bin/Release/netstandard2.0/PsSqlClient.psd1 -Force -ErrorAction 'Stop'

        . ./Helper/New-SqlServer.ps1
        $script:server = New-SqlServer -ErrorAction 'Stop'
        $script:connection = Connect-TSqlInstance -ConnectionString $script:server.ConnectionString -RetryCount 3 -ErrorAction 'SilentlyContinue'
    }

    AfterAll {
        if ( $script:connection ) {
            Disconnect-TSqlInstance -ErrorAction 'Continue'
        }

        . ./Helper/Remove-SqlServer.ps1
        Remove-SqlServer
    }

    It 'works with parameters' {
        $result = Invoke-TSqlProcedure 'sp_tables' @{ table_qualifier = 'master'}
        $result | Should -Not -BeNullOrEmpty
    }

}
