#Requires -Modules @{ ModuleName='Pester'; ModuleVersion='5.0.0' }, @{ ModuleName='PSDocker'; ModuleVersion='1.5.0' }

Describe 'Invoke-Command' {

    BeforeAll {
        Import-Module -Name $PSScriptRoot/../src/PsSqlClient/bin/Debug/netcoreapp2.1/PsSqlClient.psd1 -Force -ErrorAction 'Stop'

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

    It 'selects data' {
        $result = Invoke-TSqlCommand 'SELECT CONVERT(INT, 1) AS a, 2 AS b UNION SELECT 3, NULL'
        $result[0].a | Should -Be '1'
        $result[0].a | Should -BeOfType [int]
        $result[0].b | Should -Be '2'
        $result[1].a | Should -Be '3'
        $result[1].b | Should -Be $null
    }

    It 'selects data set' {
        $result = Invoke-TSqlCommand 'SELECT 1 AS a, 2 AS b; print ''test''; SELECT 3 AS c, 4 AS d'
        $result[0].a | Should -Be '1'
        $result[0].b | Should -Be '2'
        $result[1].c | Should -Be '3'
        $result[1].d | Should -Be '4'
    }

    It 'works with parameters' {
        $result = Invoke-TSqlCommand 'SELECT @a AS a, @b AS b' -Parameter @{ a = 1; b = 2}
        $result[0].a | Should -Be 1
        $result[0].b | Should -Be 2
    }

    It 'works with ddl' {
        Invoke-TSqlCommand 'CREATE TABLE #test (Id INT NULL)' -InformationAction 'Continue'
        Invoke-TSqlCommand 'INSERT INTO #test (Id) VALUES (@Id)' -Parameter @{ Id = 5 } -InformationAction 'Continue'
        $result = Invoke-TSqlCommand 'SELECT * FROM #test' -InformationAction 'Continue'
        $result[0].Id | Should -Be 5
    }

    It 'returns prints' {
        Invoke-TSqlCommand 'PRINT ''test''' -InformationVariable output
        $output | Should -Be 'test'
    }

    It 'throws on SQL error' {
        {
            Invoke-TSqlCommand 'SELECT 1 / 0'
        } | Should -Throw
    }

    It 'throws on timeout' {
        {
            Invoke-TSqlCommand 'WAITFOR DELAY ''00:01''' -Timeout 1
        } | Should -Throw
    }

}
