#Requires -Modules @{ ModuleName='Pester'; ModuleVersion='5.0.0' }

Describe 'Connect-Instance' {

    BeforeAll {
        Import-Module -Name $PSScriptRoot/../src/PsSqlClient/bin/Release/netstandard2.0/publish/PsSqlClient.psd1 -Force -ErrorAction 'Stop'
    }

    Context 'Docker' -Tag Docker {

        BeforeDiscovery {
            $script:missingDocker = $true
            $local:psDocker = Get-Module -ListAvailable -Name PSDocker
            if ( $local:psDocker ) {
                Import-Module $local:psDocker
                $local:dockerVersion = Get-DockerVersion -ErrorAction 'SilentlyContinue'
                if ( $local:dockerVersion.Server ) {
                    $script:missingDocker = $false
                }
            }
        }

        Context 'DockerServer' -Skip:$script:missingDocker {

            BeforeAll {
                . ./Helper/New-DockerSqlServer.ps1

                [string] $script:password = 'Passw0rd!'
                [securestring] $script:securePassword = ConvertTo-SecureString $script:password -AsPlainText -Force

                $script:server = New-DockerSqlServer -ServerAdminPassword $script:password -DockerContainerName 'PsSqlClient-Sandbox' -AcceptEula -ErrorAction 'Stop'
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

    Context 'AzureSql' -Tag AzureSql {

        BeforeDiscovery {
            $script:azureDisconnected = $true

            #Requires -Module Az.Sql, Az.Resources

            if ( Get-AzContext ) {
                $script:azureDisconnected = $false
            }
        }

        Context 'Azure' -Skip:$script:azureDisconnected {

            BeforeAll {
                $script:resourceGroup = Get-AzResourceGroup -Name 'PsSqlClientTests'
                if ( -not $script:resourceGroup ) {
                    $script:resourceGroup = New-AzResourceGroup -Name 'PsSqlClientTests' -Location 'Central US' -ErrorAction Stop
                }
                $script:server = New-AzSqlServer -ErrorAction Stop `
                    -ServerName ( New-Guid ) `
                    -ResourceGroupName $script:resourceGroup.ResourceGroupName `
                    -Location $script:resourceGroup.Location `
                    -EnableActiveDirectoryOnlyAuthentication -ExternalAdminName ( ( Get-AzContext ).Account )

                $myIp = ( Invoke-WebRequest ifconfig.me/ip ).Content.Trim()

                New-AzSqlServerFirewallRule `
                    -ResourceGroupName $script:resourceGroup.ResourceGroupName `
                    -ServerName $script:server.ServerName `
                    -FirewallRuleName 'myIP' `
                    -StartIpAddress $myIp -EndIpAddress $myIp

                $script:database = New-AzSqlDatabase -ErrorAction Stop `
                    -DatabaseName ( New-Guid ) `
                    -ServerName $script:server.ServerName `
                    -ResourceGroupName $script:resourceGroup.ResourceGroupName `
                    -Edition GeneralPurpose -Vcore 1 -ComputeGeneration Gen5 -ComputeModel Serverless
            }

            AfterAll {
                if ( $script:database ) {
                    $script:database | Remove-AzSqlDatabase
                }

                if ( $script:server ) {
                    $script:server | Remove-AzSqlServer
                }
            }

            It 'Returns a connection by properties' {
                $connection = Connect-TSqlInstance -DataSource $script:server.FullyQualifiedDomainName
                $connection.State | Should -be 'Open'
            }

            It 'Returns a connection by token' {
                $token = Get-AzAccessToken -ResourceUrl 'https://database.windows.net'
                $connection = Connect-TSqlInstance -DataSource $script:server.FullyQualifiedDomainName -AccessToken $token
                $connection.State | Should -be 'Open'
            }
        }
    }
}
