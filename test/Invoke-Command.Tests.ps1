#Requires -Modules @{ ModuleName='Pester'; ModuleVersion='5.0.0' }, @{ ModuleName='PSDocker'; ModuleVersion='1.5.0' }

Describe 'Invoke-Command' {

    BeforeAll {
        Import-Module -Name $PSScriptRoot/../src/PsSqlClient/bin/Release/netstandard2.0/PsSqlClient.psd1 -Force -ErrorAction 'Stop'

        if ( Get-Module -ListAvailable -Name PSDocker ) {
            . ./Helper/New-SqlServer.ps1

            [string] $script:password = 'Passw0rd!'
            [securestring] $script:securePassword = ConvertTo-SecureString $script:password -AsPlainText -Force

            $script:server = New-SqlServer -ServerAdminPassword $script:password -DockerContainerName 'PsSqlClient-Sandbox' -AcceptEula -ErrorAction 'Stop'
            $script:connection = Connect-TSqlInstance -ConnectionString $script:server.ConnectionString
        } else {
            $script:missingPsDocker = $true
        }
    }

    AfterAll {
        Disconnect-TSqlInstance -Connection $script:connection -ErrorAction 'Continue'
        Remove-DockerContainer -Name 'PsSqlClient-Sandbox' -Force
    }

    It 'selects data' {
        $result = Invoke-TSqlCommand -Connection $script:connection -Text 'SELECT 1 AS a, 2 AS b UNION SELECT 3, 4'
        $result[0].a | Should -Be '1'
        $result[0].b | Should -Be '2'
        $result[1].a | Should -Be '3'
        $result[1].b | Should -Be '4'
    }

    It 'returns prints' {
        Invoke-TSqlCommand -Connection $script:connection -Text 'PRINT ''test''' -InformationVariable output
        $output | Should -Be 'test'
    }

}
