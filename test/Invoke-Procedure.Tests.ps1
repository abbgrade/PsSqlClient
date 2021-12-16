#Requires -Modules @{ ModuleName='Pester'; ModuleVersion='5.0.0' }

Describe 'Invoke-Procedure' {

    BeforeAll {
        Import-Module $PSScriptRoot/../src/PsSqlClient/bin/Debug/netcoreapp2.1/publish/PsSqlClient.psd1 -Force -ErrorAction Stop
        Import-Module PsSqlTestServer -ErrorAction Stop

        $Script:Server = New-SqlServer -ErrorAction Stop
        $Script:Connection = Connect-TSqlInstance -ConnectionString $Script:Server.ConnectionString -RetryCount 3 -ErrorAction 'SilentlyContinue'
    }

    AfterAll {
        if ( $Script:Connection ) {
            Disconnect-TSqlInstance -ErrorAction 'Continue'
        }

        $Script:Server | Remove-SqlServer
    }

    It 'works with parameters' {
        $result = Invoke-TSqlProcedure 'sp_tables' @{ table_qualifier = 'master'}
        $result | Should -Not -BeNullOrEmpty
    }

}
