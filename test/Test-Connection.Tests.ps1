#Requires -Modules @{ ModuleName='Pester'; ModuleVersion='5.2.0' }

Describe Test-Connection {

    BeforeDiscovery {
        Import-Module $PSScriptRoot/../publish/PsSqlClient/PsSqlClient.psd1 -Force -ErrorAction Stop
        Import-Module PsSqlTestServer -ErrorAction Stop
    }

    Context TestInstance {

        BeforeAll {
            $TestInstance = New-SqlTestInstance -ErrorAction Stop
        }

        AfterAll {
            $TestInstance | Remove-SqlTestInstance
        }

        Context Connection {

            BeforeAll {
                $Connection = $TestInstance | Connect-TSqlInstance
            }

            AfterAll {
                if ( $Connection ) {
                    Disconnect-TSqlInstance -Connection $Connection -ErrorAction Continue
                }
            }

            It works {
                Test-TsqlConnection -Connection $Connection -Verbose | Should -Be $true
            }

            Context Database {
                BeforeEach {
                    $Database = New-SqlTestDatabase -Instance $TestInstance -InstanceConnection $Connection
                    $DatabaseConnection = $Database | Connect-TSqlInstance
                }

                AfterEach {
                    if ( $DatabaseConnection ) {
                        Disconnect-TSqlInstance -Connection $DatabaseConnection -ErrorAction Continue
                    }
                }

                It works {
                    Test-TsqlConnection -Connection $DatabaseConnection -Verbose | Should -Be $true
                }

            }
        }
    }
}
