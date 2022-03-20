#Requires -Modules @{ ModuleName='Pester'; ModuleVersion='5.0.0' }

Describe 'Connect-Instance' {

    BeforeAll {
        Import-Module $PSScriptRoot\..\publish\PsSqlClient\PsSqlClient.psd1 -Force -ErrorAction Stop
    }

    BeforeDiscovery {
        Import-Module PsSqlTestServer -MinimumVersion 0.2.0 -ErrorAction Stop
    }

    Context 'Docker' -Tag Docker {

        BeforeDiscovery {
            $Script:DockerIsUnavailable = -Not ( Test-SqlTestDocker )

            if ( $Script:DockerIsUnavailable ) {
                Write-Warning "Skip Docker-based tests."
            }
        }

        Context 'DockerTestDatabase' -Skip:$Script:DockerIsUnavailable {

            BeforeAll {
                $Script:DockerTestInstance = New-SqlTestDockerInstance -AcceptEula -ErrorAction Stop
            }

            AfterAll {
                if ( $Script:DockerTestInstance  ) {
                    $Script:DockerTestInstance  | Remove-SqlTestDockerInstance
                }
            }

            It 'Returns a connection by connection string' -Skip:$Script:DockerIsUnavailable {
                $connection = Connect-TSqlInstance -ConnectionString $Script:DockerTestInstance.ConnectionString
                $connection.State | Should -Be 'Open'
            }

            It 'Returns a connection by properties' -Skip:$Script:DockerIsUnavailable {
                $connection = Connect-TSqlInstance `
                    -DataSource $Script:DockerTestInstance.DataSource `
                    -UserId $Script:DockerTestInstance.UserId `
                    -Password $Script:DockerTestInstance.SecurePassword

                $connection.State | Should -Be 'Open'
            }
        }
    }

    Context 'LocalDb' -Tag LocalDb {

        BeforeDiscovery {
            $Script:LocalDbIsUnavailable = -Not ( Test-SqlTestLocalDb )

            if ( $Script:LocalDbIsUnavailable ) {
                Write-Warning "Skip LocalDb-based tests."
            }
        }

        Context 'LocalTestInstance' -Skip:$Script:LocalDbIsUnavailable {

            BeforeAll {
                $Script:LocalDbInstance = Get-SqlTestLocalInstance
            }

            AfterEach {
                if ( $Script:Connection ) {
                    Disconnect-TSqlInstance -Connection $Script:Connection
                }
            }

            It 'Returns a connection' {
                $Script:Connection = Connect-TSqlInstance -ConnectionString "Data Source=$( $Script:LocalDbInstance.DataSource );Integrated Security=True"
                $Script:Connection.State | Should -Be 'Open'
            }

            It 'Returns a connection by properties' {
                $Script:Connection = Connect-TSqlInstance -DataSource $Script:LocalDbInstance.DataSource -ConnectTimeout 30
                $Script:Connection.State | Should -Be 'Open'
            }
        }
    }

    Context 'AzureSql' -Tag AzureSql {

        BeforeDiscovery {
            $Script:AzureSqlIsUnavailable = -Not ( Test-SqlTestAzure )

            if ( $Script:AzureSqlIsUnavailable ) {
                Write-Warning "Skip AzureSql-based tests."
            }
        }

        Context 'AzureTestDatabase' -Skip:$Script:AzureSqlIsUnavailable {

            BeforeAll {
                $Script:AzureSqlDatabase = New-SqlTestAzureDatabase -Subscription $Script:Subscription -Verbose
            }

            AfterAll {
                $Script:AzureSqlDatabase | Remove-SqlTestAzureDatabase
            }

            It 'Returns a connection by properties' {
                $connection = Connect-TSqlInstance `
                    -DataSource $Script:AzureSqlDatabase.DataSource `
                    -InitialCatalog $Script:AzureSqlDatabase.InitialCatalog `
                    -ConnectTimeout $Script:AzureSqlDatabase.ConnectTimeout
                $connection.State | Should -Be 'Open'
            }

            It 'Returns a connection by token' {
                $connection = Connect-TSqlInstance -ConnectionString $Script:AzureSqlDatabase.ConnectionString
                $connection.State | Should -Be 'Open'
            }
        }
    }
}
