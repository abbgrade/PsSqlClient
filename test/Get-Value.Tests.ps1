#Requires -Modules @{ ModuleName='Pester'; ModuleVersion='5.2.0' }

Describe 'Get-Value' {

    BeforeDiscovery {
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
                $Script:Connection = $Script:TestInstance | Connect-TSqlInstance
            }

            AfterAll {
                if ( $Script:Connection ) {
                    $Script:Connection | Disconnect-TSqlInstance -ErrorAction Continue
                }
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
    }
}
