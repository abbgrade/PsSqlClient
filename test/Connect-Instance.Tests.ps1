#Requires -Modules @{ ModuleName='Pester'; ModuleVersion='5.0.0' }

Describe 'Connect-Instance' {

    BeforeAll {
        Import-Module -Name $PSScriptRoot/../src/PsSqlClient/bin/Release/netstandard2.0/PsSqlClient.psd1 -Force -ErrorAction 'Stop'
    }

    Context 'Docker' -Tag Docker {

        BeforeAll {

            $script:missingDocker = $false
            if ( Get-Module -ListAvailable -Name PSDocker ) {

                $local:dockerVersion = Get-DockerVersion -ErrorAction 'SilentlyContinue'
                if ( $local:dockerVersion.Server ) {
                } else {
                    $script:missingDocker = $true
                }
            } else {
                $script:missingDocker = $true
            }

            if ( -not $script:missingDocker ) {
                . ./Helper/New-DockerSqlServer.ps1

                [string] $script:password = 'Passw0rd!'
                [securestring] $script:securePassword = ConvertTo-SecureString $script:password -AsPlainText -Force

                $script:server = New-DockerSqlServer -ServerAdminPassword $script:password -DockerContainerName 'PsSqlClient-Sandbox' -AcceptEula -ErrorAction 'Stop'
            }
        }

        AfterAll {
            if ( -not $script:missingDocker ) {
                . ./Helper/Remove-DockerSqlServer.ps1
                Remove-DockerSqlServer -DockerContainerName 'PsSqlClient-Sandbox'
            }
        }

        It 'Returns a connection by connection string' -Skip:$script:missingDocker {
            $connection = Connect-TSqlInstance -ConnectionString $script:server.ConnectionString -RetryCount 3 -ErrorAction Stop
            $connection.State | Should -be 'Open'
        }

        It 'Returns a connection by properties' -Skip:$script:missingDocker {
            $connection = Connect-TSqlInstance -DataSource $script:server.Hostname -UserId $script:server.UserId -Password $script:securePassword -RetryCount 3
            $connection.State | Should -be 'Open'
        }

    }

    Context 'LocalDb' -Tag LocalDb {

        BeforeAll {
            $script:missingLocalDb = $true
            foreach( $version in Get-ChildItem -Path 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Microsoft SQL Server Local DB\Installed Versions' | Sort-Object Name -Descending ) {
                if ( $script:missingLocalDb ) {
                    switch ( $version.PSChildName ) {
                        '11.0' {
                            $script:DataSource = '(localdb)\v11.0'
                            $script:missingLocalDb = $false
                            break;
                        }
                        '13.0' {
                            $script:DataSource = '(LocalDb)\MSSQLLocalDB'
                            $script:missingLocalDb = $false
                            break;
                        }
                        '15.0' {
                            $script:DataSource = '(LocalDb)\MSSQLLocalDB'
                            $script:missingLocalDb = $false
                            break;
                        }
                        Default {
                            Write-Warning "LocalDb version $_ is not implemented."
                        }
                    }
                }
            }
        }

        AfterEach {
            if ( $connection ) {
                $connection | Disconnect-TSqlInstance
            }
        }

        It 'Returns a connection' -Skip:$script:missingLocalDb {
            $connection = Connect-TSqlInstance -ConnectionString "Data Source=$( $script:DataSource );Integrated Security=True"
            $connection.State | Should -be 'Open'
        }

        It 'Returns a connection by properties' -Skip:$script:missingLocalDb {
            $connection = Connect-TSqlInstance -DataSource $script:DataSource
            $connection.State | Should -be 'Open'
        }

    }
}
