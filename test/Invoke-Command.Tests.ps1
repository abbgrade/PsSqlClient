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
        if ( $script:connection ) {
            Disconnect-TSqlInstance -Connection $script:connection -ErrorAction 'Continue'
        }
        Remove-DockerContainer -Name 'PsSqlClient-Sandbox' -Force
    }

    It 'selects data' {
        $result = Invoke-TSqlCommand -Connection $script:connection -Text 'SELECT 1 AS a, 2 AS b UNION SELECT 3, 4'
        $result[0].a | Should -Be '1'
        $result[0].b | Should -Be '2'
        $result[1].a | Should -Be '3'
        $result[1].b | Should -Be '4'
    }

    It 'selects data set' {
        $result = Invoke-TSqlCommand -Connection $script:connection -Text 'SELECT 1 AS a, 2 AS b; print ''test''; SELECT 3 AS c, 4 AS d'
        $result[0].a | Should -Be '1'
        $result[0].b | Should -Be '2'
        $result[1].c | Should -Be '3'
        $result[1].d | Should -Be '4'
    }

    It 'works with parameters' {
        $result = Invoke-TSqlCommand -Connection $script:connection -Text 'SELECT @a AS a, @b AS b' -Parameter @{ a = 1; b = 2}
        $result[0].a | Should -Be 1
        $result[0].b | Should -Be 2
    }

    It 'returns prints' {
        Invoke-TSqlCommand -Connection $script:connection -Text 'PRINT ''test''' -InformationVariable output
        $output | Should -Be 'test'
    }

    It 'throws on SQL error' {
        {
            Invoke-TSqlCommand -Connection $script:connection -Text 'SELECT 1 / 0'
        } | Should -Throw
    }

    It 'Timeouts' {
        {
            Invoke-TSqlCommand -Connection $script:connection -Text 'WAITFOR DELAY ''00:01''' -Timeout 1
        } | Should -Throw
    }

}
