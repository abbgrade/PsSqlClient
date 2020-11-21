#Requires -Modules @{ ModuleName='Pester'; ModuleVersion='5.0.0' }, @{ ModuleName='PSDocker'; ModuleVersion='1.5.0' }

Describe 'Connect-Instance' {

    BeforeAll {
        Import-Module -Name $PSScriptRoot/../src/PsSqlClient/bin/Release/netstandard2.0/PsSqlClient.psd1 -Force -ErrorAction 'Stop'
    }

    Context 'Docker' -Tag Docker {

        BeforeAll {

            if ( Get-Module -ListAvailable -Name PSDocker ) {
                . ./Helper/New-SqlServer.ps1

                [string] $script:password = 'Passw0rd!'
                [securestring] $script:securePassword = ConvertTo-SecureString $script:password -AsPlainText -Force

                $script:server = New-SqlServer -ServerAdminPassword $script:password -DockerContainerName 'PsSqlClient-Sandbox' -AcceptEula -ErrorAction 'Stop'
            } else {
                $script:missingPsDocker = $true
            }
        }

        AfterAll {
            Remove-DockerContainer -Name 'PsSqlClient-Sandbox' -Force
        }

        Context 'Docker SQL Server' {

            It 'Returns a connection by connection string' -Skip:$script:missingPsDocker {
                $connection = Connect-TSqlInstance -ConnectionString $script:server.ConnectionString
                $connection.State | Should -be 'Open'
            }

            It 'Returns a connection by properties' -Skip:$script:missingPsDocker {

                $connection = Connect-TSqlInstance -DataSource $script:server.Hostname -UserId $script:server.UserId -Password $script:securePassword
                $connection.State | Should -be 'Open'
            }

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
