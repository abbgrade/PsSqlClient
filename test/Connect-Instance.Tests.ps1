#Requires -Modules @{ ModuleName='Pester'; ModuleVersion='5.0.0' }, @{ ModuleName='PSDocker'; ModuleVersion='1.5.0' }

Describe 'Connect-Instance' {

    BeforeAll {
        Import-Module -Name $PSScriptRoot/../src/PsSqlClient/bin/Release/netstandard2.0/PsSqlClient.psd1 -Force -ErrorAction 'Stop'
    }

    Context 'Docker' -Tag Docker {

        BeforeAll {
            . ./Helper/New-SqlServer.ps1

            [string] $script:password = 'Passw0rd!'
            [securestring] $script:securePassword = ConvertTo-SecureString $script:password -AsPlainText -Force
            # $script:securePassword.MakeReadOnly()

            $script:server = New-SqlServer -ServerAdminPassword $script:password -DockerContainerName 'PsSqlClient-Sandbox' -AcceptEula -ErrorAction 'Stop'
        }

        AfterAll {
            Remove-DockerContainer -Name 'PsSqlClient-Sandbox' -Force
        }

        Context 'Docker SQL Server' {

            It 'Returns a connection by connection string' {
                $connection = Connect-Instance -ConnectionString $script:server.ConnectionString
                $connection | Should -Not -BeNullOrEmpty
            }

            It 'Returns a connection by properties' {

                $connection = Connect-Instance -DataSource $script:server.Hostname -UserId $script:server.UserId -Password $script:securePassword
                $connection | Should -Not -BeNullOrEmpty
            }

        }

    }

    Context 'LocalDb' -Tag LocalDb {

        It 'Returns a connection' {
            $connection = Connect-Instance -ConnectionString 'Data Source=(LocalDb)\MSSQLLocalDB;Integrated Security=True'
            $connection | Should -Not -BeNullOrEmpty
        }

        It 'Returns a connection by properties' {
            $connection = Connect-Instance -DataSource '(LocalDb)\MSSQLLocalDB'
            $connection | Should -Not -BeNullOrEmpty
        }

    }
}
