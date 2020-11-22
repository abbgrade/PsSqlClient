#Requires -Modules @{ ModuleName='Pester'; ModuleVersion='5.0.0' }, @{ ModuleName='PSDocker'; ModuleVersion='1.5.0' }

Describe 'Get-Value' {

    BeforeAll {
        Import-Module -Name $PSScriptRoot/../src/PsSqlClient/bin/Release/netstandard2.0/PsSqlClient.psd1 -Force -ErrorAction 'Stop'

        if ( Get-Module -ListAvailable -Name PSDocker ) {
            . ./Helper/New-SqlServer.ps1

            [string] $script:password = 'Passw0rd!'
            [securestring] $script:securePassword = ConvertTo-SecureString $script:password -AsPlainText -Force

            $script:server = New-SqlServer -ServerAdminPassword $script:password -DockerContainerName 'PsSqlClient-Sandbox' -AcceptEula -ErrorAction 'Stop'
            $script:connection = Connect-TSqlInstance -ConnectionString $script:server.ConnectionString -RetryCount 3 -ErrorAction 'SilentlyContinue'
        } else {
            $script:missingPsDocker = $true
        }
    }

    AfterAll {
        if ( $script:connection ) {
            Disconnect-TSqlInstance -ErrorAction 'Continue'
        }
        Remove-DockerContainer -Name 'PsSqlClient-Sandbox' -Force
    }

    It 'gets an integer value' {
        $result = Get-TSqlValue -Text 'SELECT CONVERT(INT, 1)'
        $result | Should -Be '1'
        $result | Should -BeOfType [int]
    }

    It 'trows a string value' {
        $result = Get-TSqlValue -Text 'SELECT ''test'''
        $result | Should -Be 'test'
        $result | Should -BeOfType [string]
    }
}
