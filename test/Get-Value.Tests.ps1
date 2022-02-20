#Requires -Modules @{ ModuleName='Pester'; ModuleVersion='5.0.0' }

Describe 'Get-Value' {

    BeforeAll {
        Import-Module $PSScriptRoot/../publish/PsSqlClient/PsSqlClient.psd1 -Force -ErrorAction Stop
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
