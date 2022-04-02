#Requires -Modules @{ ModuleName='Pester'; ModuleVersion='5.0.0' }

Describe 'Disconnect-Instance' {

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

            BeforeEach {
                $Script:Connection = $Script:TestInstance | Connect-TSqlInstance
            }

            It 'Disconnects the instance' {
                Disconnect-TSqlInstance -Connection $Script:Connection
                $Script:Connection.State | Should -Be 'Closed'
            }

            It 'Disconnects the instance in the session' {
                Disconnect-TSqlInstance
                $Script:Connection.State | Should -Be 'Closed'
            }

            It 'Disconnects a closed the instance in the session' {
                Disconnect-TSqlInstance
                { Disconnect-TSqlInstance } | Should -Throw
            }

            Context 'Database' {
                BeforeEach {
                    [string] $Script:DatabaseName = New-Guid
                    Invoke-TSqlCommand "CREATE DATABASE [$Script:DatabaseName];" -Connection $Script:Connection
                    $Script:OpenConnection = Connect-TSqlInstance -DataSource $Script:Connection.DataSource -InitialCatalog $Script:DatabaseName -ErrorAction Stop
                }

                AfterEach {
                    # for some reason, disconnecting does not remove the session from the database without switching the database.
                    Invoke-TSqlCommand 'USE [master];' -Connection $Script:OpenConnection
                    Disconnect-TSqlInstance -Connection $Script:OpenConnection

                    Invoke-TSqlCommand "DROP DATABASE [$Script:DatabaseName];" -Connection $Script:Connection
                }

                It 'Is connected from server side' {
                    {
                        Invoke-TSqlCommand "DROP DATABASE [$Script:DatabaseName];" -Connection $Script:Connection
                    } | Should -Throw "Cannot drop database ""$Script:DatabaseName"" because it is currently in use."
                }
            }
        }
    }
}
