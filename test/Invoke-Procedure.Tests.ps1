#Requires -Modules @{ ModuleName='Pester'; ModuleVersion='5.0.0' }, @{ ModuleName='PSDocker'; ModuleVersion='1.5.0' }

Describe 'Invoke-Procedure' {

    BeforeAll {
        Import-Module $PSScriptRoot/../src/PsSqlClient/bin/Debug/netcoreapp2.1/publish/PsSqlClient.psd1 -Force -ErrorAction Stop

        . $PsScriptRoot/Helper/New-SqlServer.ps1
        $script:server = New-SqlServer -ErrorAction Stop
        $script:connection = Connect-TSqlInstance -ConnectionString $script:server.ConnectionString -RetryCount 3 -ErrorAction 'SilentlyContinue'
    }

    AfterAll {
        if ( $script:connection ) {
            Disconnect-TSqlInstance -ErrorAction 'Continue'
        }

        . $PsScriptRoot/Helper/Remove-SqlServer.ps1
        Remove-SqlServer
    }

    It 'works with parameters' {
        $result = Invoke-TSqlProcedure 'sp_tables' @{ table_qualifier = 'master'}
        $result | Should -Not -BeNullOrEmpty
    }

}
