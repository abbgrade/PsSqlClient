#Requires -Modules @{ ModuleName='Pester'; ModuleVersion='5.0.0' }

Describe 'Invoke-Procedure' {

    BeforeAll {
        Import-Module $PSScriptRoot/../publish/PsSqlClient/PsSqlClient.psd1 -Force -ErrorAction Stop
        Import-Module PsSqlTestServer -ErrorAction Stop
    }

    Context 'TestInstance' {

        BeforeAll {
            $Script:TestInstance = New-SqlTestInstance -ErrorAction Stop
        }

        AfterAll {
            $Script:TestInstance | Remove-SqlTestInstance
        }

        Context 'Connection' {

            BeforeAll {
                $Script:Connection = Connect-TSqlInstance -ConnectionString $Script:TestInstance.ConnectionString
            }

            AfterAll {
                if ( $Script:Connection ) {
                    Disconnect-TSqlInstance -ErrorAction Continue
                }
            }

            It 'works with parameters' {
                $result = Invoke-TSqlProcedure 'sp_tables' @{ table_qualifier = 'master' }
                $result | Should -Not -BeNullOrEmpty
            }
        }
    }
}
