#Requires -Modules @{ ModuleName='Pester'; ModuleVersion='5.0.0' }

Describe 'Export-Table' {

    BeforeAll {
        Import-Module $PSScriptRoot/../src/PsSqlClient/bin/Debug/netcoreapp2.1/publish/PsSqlClient.psd1 -Force -ErrorAction Stop

        . $PsScriptRoot/Helper/New-SqlServer.ps1
        $script:server = New-SqlServer -ErrorAction Stop
        $script:connection = Connect-TSqlInstance -ConnectionString $script:server.ConnectionString -RetryCount 3 -ErrorAction 'SilentlyContinue'
        Invoke-TSqlCommand 'CREATE TABLE #test (Id INT IDENTITY, Name NVARCHAR(MAX) NOT NULL)'
    }

    AfterAll {
        if ( $script:connection ) {
            Disconnect-TSqlInstance -ErrorAction 'Continue'
        }

        . $PsScriptRoot/Helper/Remove-SqlServer.ps1
        Remove-SqlServer
    }

    BeforeEach {
        Invoke-TSqlCommand 'TRUNCATE TABLE #test'
    }

    It 'inserts 3 rows' {
        @(
            [PSCustomObject] @{ Id=1; Name='Iron Maiden'},
            [PSCustomObject] @{ Id=2; Name='Killers'},
            [PSCustomObject] @{ Id=3; Name='The Number of the Beast'}
        ) | Export-TSqlTable -Table '#test' -Connection $script:connection

        Get-TSqlValue 'SELECT COUNT(*) FROM #test' | Should -Be 3
    }

    It 'throws on null value' {
        {
            @(
                [PSCustomObject] @{ Id=4; Name=$null}
            ) | Export-TSqlTable -Table '#test' -Connection $script:connection
        } | Should -Throw 'Column ''Name'' does not allow DBNull.Value.'
    }

    It 'throws not on null value' {
        {
            @(
                [PSCustomObject] @{ Id=4; Name=$null}
            ) | Export-TSqlTable -Table '#test' -KeepNulls
        } | Should -Throw 'Column ''Name'' does not allow DBNull.Value.'
    }

    It 'works with keep identity' {
        @(
            [PSCustomObject] @{ Id=666; Name='The Number of the Beast'}
        ) | Export-TSqlTable -Table '#test' -KeepIdentity

        $rows = Invoke-TSqlCommand 'SELECT * FROM #test'
        $rows | Where-Object Id -eq 666 | Select-Object -ExpandProperty Name | Should -Be 'The Number of the Beast'
    }

}
