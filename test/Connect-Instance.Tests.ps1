#Requires -Modules @{ ModuleName='Pester'; ModuleVersion='5.2.0' }

Describe Connect-Instance {

    BeforeDiscovery {
        Import-Module $PSScriptRoot/../publish/PsSqlClient/PsSqlClient.psd1 -Force -ErrorAction Stop
        Import-Module PsSqlTestServer -ErrorAction Stop
    }

    BeforeAll {
        $VerbosePreference = 'Continue'
    }

    Context LocalDb -Tag LocalDb {

        BeforeDiscovery {
            $LocalDbIsUnavailable = -Not ( Test-SqlTestLocalDb )

            if ( $LocalDbIsUnavailable ) {
                Write-Warning "Skip LocalDb-based tests."
            }
        }

        Context LocalTestInstance -Skip:$LocalDbIsUnavailable {

            BeforeAll {
                $LocalDbInstance = Get-SqlTestLocalInstance
            }

            AfterEach {
                if ( $Connection ) {
                    $Connection | Disconnect-TSqlInstance
                }
            }

            It 'Connects by pipeline' {
                $Connection = $LocalDbInstance | Connect-TSqlInstance
                $Connection.State | Should -Be Open
            }

            It 'Connects by properties' {
                $Connection = Connect-TSqlInstance `
                    -DataSource $LocalDbInstance.DataSource `
                    -ConnectTimeout $LocalDbInstance.ConnectTimeout
                $Connection.State | Should -Be Open
            }

            It 'Connects by properties integrated security' {
                $Connection = Connect-TSqlInstance `
                    -DataSource $LocalDbInstance.DataSource `
                    -IntegratedSecurity `
                    -ConnectTimeout $LocalDbInstance.ConnectTimeout
                $Connection.State | Should -Be Open
            }

            It 'Connects by connection string' {
                $Connection = Connect-TSqlInstance `
                    -ConnectionString $LocalDbInstance.ConnectionString
                $Connection.State | Should -Be Open
            }
        }
    }

    Context Docker -Tag Docker {

        BeforeDiscovery {
            $DockerIsUnavailable = -Not ( Test-SqlTestDocker )

            if ( $DockerIsUnavailable ) {
                Write-Warning "Skip Docker-based tests."
            }
        }

        Context DockerTestDatabase -Skip:$DockerIsUnavailable {

            BeforeAll {
                $DockerTestInstance = New-SqlTestDockerInstance -AcceptEula -ErrorAction Stop
            }

            AfterAll {
                if ( $DockerTestInstance  ) {
                    $DockerTestInstance  | Remove-SqlTestDockerInstance
                }
            }

            It 'Connects by pipeline' -Skip:$DockerIsUnavailable {
                $connection = $DockerTestInstance | Connect-TSqlInstance
                $connection.State | Should -Be 'Open'
            }

            It 'Connects by properties' -Skip:$DockerIsUnavailable {
                $connection = Connect-TSqlInstance `
                    -DataSource $DockerTestInstance.DataSource `
                    -ConnectTimeout $DockerTestInstance.ConnectTimeout `
                    -UserId $DockerTestInstance.UserId `
                    -Password $DockerTestInstance.SecurePassword

                $connection.State | Should -Be 'Open'
            }

            It 'Connects by connection string' -Skip:$DockerIsUnavailable {
                $connection = Connect-TSqlInstance -ConnectionString $DockerTestInstance.ConnectionString
                $connection.State | Should -Be 'Open'
            }
        }
    }

    Context AzureSql -Tag AzureSql {

        BeforeDiscovery {
            $AzureSqlIsUnavailable = -Not ( Test-SqlTestAzure )

            if ( $AzureSqlIsUnavailable ) {
                Write-Warning "Skip AzureSql-based tests."
            }
        }

        Context AzureTestDatabase -Skip:$AzureSqlIsUnavailable {

            BeforeAll {
                $AzureSqlDatabase = New-SqlTestAzureDatabase -Subscription 'Visual Studio'
            }

            AfterAll {
                if ( $AzureSqlDatabase ) {
                    $AzureSqlDatabase | Remove-SqlTestAzureDatabase
                }
            }

            It 'Connects by pipeline' {
                $connection = $AzureSqlDatabase | Connect-TSqlInstance
                $connection.State | Should -Be 'Open'
            }

            It 'Connects by properties (not specified)' {
                $connection = Connect-TSqlInstance `
                    -DataSource $AzureSqlDatabase.DataSource `
                    -InitialCatalog $AzureSqlDatabase.InitialCatalog `
                    -ConnectTimeout $AzureSqlDatabase.ConnectTimeout
                $connection.State | Should -Be 'Open'
            }

            It 'Connects by properties (integrated)' {
                $connection = Connect-TSqlInstance `
                    -DataSource $AzureSqlDatabase.DataSource `
                    -InitialCatalog $AzureSqlDatabase.InitialCatalog `
                    -Authentication ActiveDirectoryIntegrated `
                    -ConnectTimeout $AzureSqlDatabase.ConnectTimeout
                $connection.State | Should -Be 'Open'
            }

            It 'Connects by properties (non-interactive)' {
                $connection = Connect-TSqlInstance `
                    -DataSource $AzureSqlDatabase.DataSource `
                    -InitialCatalog $AzureSqlDatabase.InitialCatalog `
                    -Authentication ActiveDirectoryDefault `
                    -ConnectTimeout $AzureSqlDatabase.ConnectTimeout
                $connection.State | Should -Be 'Open'
            }

            It 'Connects by properties (interactive)' {
                $connection = Connect-TSqlInstance `
                    -DataSource $AzureSqlDatabase.DataSource `
                    -InitialCatalog $AzureSqlDatabase.InitialCatalog `
                    -Authentication ActiveDirectoryInteractive `
                    -ConnectTimeout $AzureSqlDatabase.ConnectTimeout
                $connection.State | Should -Be 'Open'
            }

            It 'Connects by connection string' {
                $connection = Connect-TSqlInstance -ConnectionString $AzureSqlDatabase.ConnectionString
                $connection.State | Should -Be 'Open'
            }

            Context AccessToken {

                BeforeAll {
                    $AzureSqlDatabaseWithToken = $AzureSqlDatabase.PsObject.Copy()
                    $AzureSqlDatabaseWithToken | Add-Member AccessToken ( Get-AzAccessToken -ResourceUrl https://database.windows.net ).Token
                }

                It 'Connects by pipeline' {
                    $connection = $AzureSqlDatabaseWithToken | Connect-TSqlInstance
                    $connection.State | Should -Be 'Open'
                }

                It 'Connects by properties (not specified)' {
                    $connection = Connect-TSqlInstance `
                        -DataSource $AzureSqlDatabaseWithToken.DataSource `
                        -InitialCatalog $AzureSqlDatabaseWithToken.InitialCatalog `
                        -AccessToken $AzureSqlDatabaseWithToken.AccessToken `
                        -ConnectTimeout $AzureSqlDatabaseWithToken.ConnectTimeout
                    $connection.State | Should -Be 'Open'
                }

                It 'Connects by connection string' {
                    $connection = Connect-TSqlInstance `
                        -ConnectionString $AzureSqlDatabaseWithToken.ConnectionString `
                        -AccessToken $AzureSqlDatabaseWithToken.AccessToken
                    $connection.State | Should -Be 'Open'
                }
            }
        }
    }
}
