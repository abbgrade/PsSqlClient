#Requires -Modules @{ ModuleName='Pester'; ModuleVersion='5.0.0' }, @{ ModuleName='PSDocker'; ModuleVersion='1.5.0' }

Describe 'Export-Table' {

    BeforeAll {
        Import-Module -Name $PSScriptRoot/../src/PsSqlClient/bin/Release/netstandard2.0/PsSqlClient.psd1 -Force -ErrorAction 'Stop'

        if ( Get-Module -ListAvailable -Name PSDocker ) {
            . ./Helper/New-SqlServer.ps1

            [string] $script:password = 'Passw0rd!'
            [securestring] $script:securePassword = ConvertTo-SecureString $script:password -AsPlainText -Force

            $script:server = New-SqlServer -ServerAdminPassword $script:password -DockerContainerName 'PsSqlClient-Sandbox' -AcceptEula -ErrorAction 'Stop'
            $script:connection = Connect-TSqlInstance -ConnectionString $script:server.ConnectionString -RetryCount 3 -ErrorAction 'SilentlyContinue'
            Invoke-TSqlCommand -Text 'CREATE TABLE #test (Id INT IDENTITY, Name NVARCHAR(MAX) NOT NULL)'
        } else {
            $script:missingPsDocker = $true
        }
    }

    BeforeEach {
        Invoke-TSqlCommand -Text 'TRUNCATE TABLE #test'
    }

    AfterAll {
        if ( $script:connection ) {
            Disconnect-TSqlInstance -ErrorAction 'Continue'
        }
        Remove-DockerContainer -Name 'PsSqlClient-Sandbox' -Force
    }

    It 'inserts 3 rows' {
        @(
            [PSCustomObject] @{ Id=1; Name='Iron Maiden'},
            [PSCustomObject] @{ Id=2; Name='Killers'},
            [PSCustomObject] @{ Id=3; Name='The Number of the Beast'}
        ) | Export-TSqlTable -Table '#test' -Connection $script:connection

        Get-TSqlValue -Text 'SELECT COUNT(*) FROM #test' | Should -Be 3
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

        $rows = Invoke-TSqlCommand -Text 'SELECT * FROM #test'
        $rows | Where-Object Id -eq 666 | Select-Object -ExpandProperty Name | Should -Be 'The Number of the Beast'
    }

}
