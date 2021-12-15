#Requires -Modules @{ ModuleName='Pester'; ModuleVersion='5.0.0' }

Describe 'Connect-Instance' {

    BeforeAll {
        Import-Module $PSScriptRoot/../src/PsSqlClient/bin/Debug/netcoreapp2.1/publish/PsSqlClient.psd1 -Force -ErrorAction Stop
        Import-Module PsSqlTestServer -ErrorAction Stop
    }

    Context 'Docker' -Tag Docker {

        BeforeDiscovery {
            $Script:DockerIsUnavailable = $true
            $local:psDocker = Import-Module PSDocker -PassThru -ErrorAction SilentlyContinue
            if ( $local:psDocker ) {
                $local:dockerVersion = Get-DockerVersion -ErrorAction SilentlyContinue
                if ( $local:dockerVersion.Server ) {
                    $Script:DockerIsUnavailable = $false
                }
            }
        }

        Context 'DockerServer' -Skip:$Script:DockerIsUnavailable {

            BeforeAll {
                [string] $script:password = 'Passw0rd!'
                [securestring] $script:securePassword = ConvertTo-SecureString $script:password -AsPlainText -Force

                $script:server = New-DockerSqlServer -ServerAdminPassword $script:password -DockerContainerName 'PsSqlClient-Sandbox' -AcceptEula -ErrorAction Stop
            }

            AfterAll {
                if ( -not $Script:DockerIsUnavailable ) {
                    Remove-DockerSqlServer -DockerContainerName 'PsSqlClient-Sandbox'
                }
            }

            It 'Returns a connection by connection string' -Skip:$Script:DockerIsUnavailable {
                $connection = Connect-TSqlInstance -ConnectionString $script:server.ConnectionString -RetryCount 3 -ErrorAction Stop
                $connection.State | Should -be 'Open'
            }

            It 'Returns a connection by properties' -Skip:$Script:DockerIsUnavailable {
                $connection = Connect-TSqlInstance -DataSource $script:server.Hostname -UserId $script:server.UserId -Password $script:securePassword -RetryCount 3
                $connection.State | Should -be 'Open'
            }
        }
    }

    Context 'LocalDb' -Tag LocalDb {

        BeforeAll {
            $Script:LocalDbIsUnavailable = $true
            foreach( $version in Get-ChildItem -Path 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Microsoft SQL Server Local DB\Installed Versions' | Sort-Object Name -Descending ) {
                if ( $Script:LocalDbIsUnavailable ) {
                    switch ( $version.PSChildName ) {
                        '11.0' {
                            $script:DataSource = '(localdb)\v11.0'
                            $Script:LocalDbIsUnavailable = $false
                            break;
                        }
                        '13.0' {
                            $script:DataSource = '(LocalDb)\MSSQLLocalDB'
                            $Script:LocalDbIsUnavailable = $false
                            break;
                        }
                        '15.0' {
                            $script:DataSource = '(LocalDb)\MSSQLLocalDB'
                            $Script:LocalDbIsUnavailable = $false
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
                Disconnect-TSqlInstance -Connection $connection
            }
        }

        It 'Returns a connection' -Skip:$Script:LocalDbIsUnavailable {
            $connection = Connect-TSqlInstance -ConnectionString "Data Source=$( $script:DataSource );Integrated Security=True"
            $connection.State | Should -be 'Open'
        }

        It 'Returns a connection by properties' -Skip:$Script:LocalDbIsUnavailable {
            $connection = Connect-TSqlInstance -DataSource $script:DataSource
            $connection.State | Should -be 'Open'
        }

    }

    Context 'AzureSql' -Tag AzureSql {

        BeforeDiscovery {
            $Script:AzureIsDisconnected = $true

            $local:azAccount = Get-Module -ListAvailable -Name Az.Account
            if ( $local:azAccount ) {
                Import-Module $local:azAccount
                Import-Module Az.Sql
                Import-Module Az.Resources

                if ( Get-AzContext ) {
                    $Script:AzureIsDisconnected = $false
                }
            }
        }

        Context 'Azure' -Skip:$Script:AzureIsDisconnected {

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
