#Requires -Modules @{ ModuleName='Pester'; ModuleVersion='5.0.0' }, @{ ModuleName='PSDocker'; ModuleVersion='1.5.0' }

Describe 'Get-Value' {

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

    It 'gets an integer value' {
        $result = Get-TSqlValue 'SELECT CONVERT(INT, 1)'
        $result | Should -Be '1'
        $result | Should -BeOfType [int]
    }

    It 'trows a string value' {
        $result = Get-TSqlValue 'SELECT ''test'''
        $result | Should -Be 'test'
        $result | Should -BeOfType [string]
    }
}
