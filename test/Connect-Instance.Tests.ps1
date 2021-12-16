#Requires -Modules @{ ModuleName='Pester'; ModuleVersion='5.0.0' }

Describe 'Connect-Instance' {

    BeforeAll {
        Import-Module $PSScriptRoot/../src/PsSqlClient/bin/Debug/netcoreapp2.1/publish/PsSqlClient.psd1 -Force -ErrorAction Stop
        Import-Module PsSqlTestServer -ErrorAction Stop
    }

    Context 'Docker' -Tag Docker {

        BeforeDiscovery {
            $Script:DockerIsUnavailable = $true
            if ( Import-Module PSDocker -PassThru -ErrorAction SilentlyContinue ) {
                if ( ( Get-DockerVersion -ErrorAction SilentlyContinue ).Server ) {
                    $Script:DockerIsUnavailable = $false
                }
            }

            if ( $Script:DockerIsUnavailable ) {
                Write-Warning "Skip Docker-based tests."
            }
        }

        Context 'DockerServer' -Skip:$Script:DockerIsUnavailable {

            BeforeAll {
                $Script:Server = New-DockerSqlServer -AcceptEula -ErrorAction Stop
            }

            AfterAll {
                if ( $Script:Server ) {
                    $Script:Server | Remove-DockerSqlServer
                }
            }

            It 'Returns a connection by connection string' -Skip:$Script:DockerIsUnavailable {
                $connection = Connect-TSqlInstance -ConnectionString $Script:Server.ConnectionString -RetryCount 3 -ErrorAction Stop
                $connection.State | Should -be 'Open'
            }

            It 'Returns a connection by properties' -Skip:$Script:DockerIsUnavailable {
                $connection = Connect-TSqlInstance -DataSource $Script:Server.Hostname -UserId $Script:Server.UserId -Password $Script:Server.SecurePassword -RetryCount 3
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
                            $Script:DataSource = '(localdb)\v11.0'
                            $Script:LocalDbIsUnavailable = $false
                            break;
                        }
                        '13.0' {
                            $Script:DataSource = '(LocalDb)\MSSQLLocalDB'
                            $Script:LocalDbIsUnavailable = $false
                            break;
                        }
                        '15.0' {
                            $Script:DataSource = '(LocalDb)\MSSQLLocalDB'
                            $Script:LocalDbIsUnavailable = $false
                            break;
                        }
                        Default {
                            Write-Warning "LocalDb version $_ is not implemented."
                        }
                    }
                }

                if ( $Script:LocalDbIsUnavailable ) {
                    Write-Warning "Skip LocalDb-based tests."
                }
            }
        }

        AfterEach {
            if ( $connection ) {
                Disconnect-TSqlInstance -Connection $connection
            }
        }

        It 'Returns a connection' -Skip:$Script:LocalDbIsUnavailable {
            $connection = Connect-TSqlInstance -ConnectionString "Data Source=$( $Script:DataSource );Integrated Security=True"
            $connection.State | Should -be 'Open'
        }

        It 'Returns a connection by properties' -Skip:$Script:LocalDbIsUnavailable {
            $connection = Connect-TSqlInstance -DataSource $Script:DataSource
            $connection.State | Should -be 'Open'
        }

    }

    Context 'AzureSql' -Tag AzureSql {

        BeforeDiscovery {
            $Script:AzureIsDisconnected = $true

            $azAccount = Get-Module -ListAvailable -Name Az.Account
            if ( $azAccount ) {
                Import-Module $azAccount
                Import-Module Az.Sql
                Import-Module Az.Resources

                if ( Get-AzContext ) {
                    $Script:AzureIsDisconnected = $false
                }
            }

            if ( $Script:AzureIsDisconnected ) {
                Write-Warning "Skip Azure-based tests."
            }
        }

        Context 'Azure' -Skip:$Script:AzureIsDisconnected {

            BeforeAll {
                $Script:ResourceGroup = Get-AzResourceGroup -Name 'PsSqlClientTests'
                if ( -not $Script:ResourceGroup ) {
                    $Script:ResourceGroup = New-AzResourceGroup -Name 'PsSqlClientTests' -Location 'Central US' -ErrorAction Stop
                }
                $Script:Server = New-AzSqlServer -ErrorAction Stop `
                    -ServerName ( New-Guid ) `
                    -ResourceGroupName $Script:ResourceGroup.ResourceGroupName `
                    -Location $Script:ResourceGroup.Location `
                    -EnableActiveDirectoryOnlyAuthentication -ExternalAdminName ( ( Get-AzContext ).Account )

                $myIp = ( Invoke-WebRequest ifconfig.me/ip ).Content.Trim()

                New-AzSqlServerFirewallRule `
                    -ResourceGroupName $Script:ResourceGroup.ResourceGroupName `
                    -ServerName $Script:Server.ServerName `
                    -FirewallRuleName 'myIP' `
                    -StartIpAddress $myIp -EndIpAddress $myIp

                $Script:Database = New-AzSqlDatabase -ErrorAction Stop `
                    -DatabaseName ( New-Guid ) `
                    -ServerName $Script:Server.ServerName `
                    -ResourceGroupName $Script:ResourceGroup.ResourceGroupName `
                    -Edition GeneralPurpose -Vcore 1 -ComputeGeneration Gen5 -ComputeModel Serverless
            }

            AfterAll {
                if ( $Script:Database ) {
                    $Script:Database | Remove-AzSqlDatabase
                }

                if ( $Script:Server ) {
                    $Script:Server | Remove-AzSqlServer
                }
            }

            It 'Returns a connection by properties' {
                $connection = Connect-TSqlInstance -DataSource $Script:Server.FullyQualifiedDomainName
                $connection.State | Should -be 'Open'
            }

            It 'Returns a connection by token' {
                $token = Get-AzAccessToken -ResourceUrl 'https://database.windows.net'
                $connection = Connect-TSqlInstance -DataSource $Script:Server.FullyQualifiedDomainName -AccessToken $token
                $connection.State | Should -be 'Open'
            }
        }
    }
}
