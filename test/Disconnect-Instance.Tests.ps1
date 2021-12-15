#Requires -Modules @{ ModuleName='Pester'; ModuleVersion='5.0.0' }, PsSqlTestServer

Describe 'Disconnect-Instance' {

    BeforeAll {
        Import-Module $PSScriptRoot/../src/PsSqlClient/bin/Debug/netcoreapp2.1/publish/PsSqlClient.psd1 -Force -ErrorAction Stop
        Import-Module PsSqlTestServer -ErrorAction Stop

        $Script:Server = New-SqlServer -ErrorAction Stop
    }

    AfterAll {
        Remove-SqlServer
    }

    BeforeEach {
        $Script:Connection = Connect-TSqlInstance -ConnectionString $Script:Server.ConnectionString -RetryCount 3 -ErrorAction SilentlyContinue
    }

    It 'Disconnects the instance' {
        Disconnect-TSqlInstance -Connection $Script:Connection
        $Script:Connection.State | Should -Be 'Closed'
    }

    It 'Disconnects the instance in the session' {
        Disconnect-TSqlInstance
        $Script:Connection.State | Should -Be 'Closed'
    }

    It 'Disconnects the instance in the session' {
        Disconnect-TSqlInstance
        { Disconnect-TSqlInstance } | Should -Throw
    }

    Context 'New Database' {
        BeforeEach {
            [string] $Script:DatabaseName = New-Guid
            Invoke-TSqlCommand "CREATE DATABASE [$Script:DatabaseName];" -Connection $Script:Connection
            $Script:OpenConnection = Connect-TSqlInstance -DataSource $Script:Connection.DataSource -InitialCatalog $Script:DatabaseName -ErrorAction Stop
        }

        It 'Is connected from server side' {
            {
                Invoke-TSqlCommand "DROP DATABASE [$Script:DatabaseName];" -Connection $Script:Connection
            } | Should -Throw "Cannot drop database ""$Script:DatabaseName"" because it is currently in use."
        }

        AfterEach {
            Invoke-TSqlCommand 'USE [master];' -Connection $Script:OpenConnection
            Disconnect-TSqlInstance -Connection $Script:OpenConnection

            # Invoke-TSqlCommand "ALTER DATABASE [$Script:DatabaseName] SET OFFLINE WITH ROLLBACK IMMEDIATE;" -Connection $Script:Connection
            Invoke-TSqlCommand "DROP DATABASE [$Script:DatabaseName];" -Connection $Script:Connection
        }
    }

}
