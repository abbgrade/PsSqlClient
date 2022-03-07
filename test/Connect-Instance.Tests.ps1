#Requires -Modules @{ ModuleName='Pester'; ModuleVersion='5.0.0' }

Describe 'Connect-Instance' {

    BeforeAll {
        Add-Type -Path $PSScriptRoot\..\publish\PsSqlClient\runtimes\win\lib\netcoreapp3.1\Microsoft.Data.SqlClient.dll
        Add-Type -Path $PSScriptRoot\..\publish\PsSqlClient\Microsoft.Identity.Client.dll

        Import-Module $PSScriptRoot\..\publish\PsSqlClient\PsSqlClient.psd1 -Force -ErrorAction Stop
    }

    BeforeDiscovery {
        Import-Module PsSqlTestServer -MinimumVersion 0.2.0 -ErrorAction Stop
        $Script:DockerIsUnavailable = -Not ( Test-DockerSqlServer )

        if ( $Script:DockerIsUnavailable ) {
            Write-Warning "Skip Docker-based tests."
        }
    }

    Context 'Docker' -Tag Docker -Skip:$Script:DockerIsUnavailable {

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
            $connection = Connect-TSqlInstance -DataSource $Script:Server.DataSource -UserId $Script:Server.UserId -Password $Script:Server.SecurePassword -RetryCount 3
            $connection.State | Should -be 'Open'
        }
    }

    Context 'LocalDb' -Tag LocalDb {

        BeforeAll {
            $Script:LocalDb = Get-LocalDb
        }

        AfterEach {
            if ( $Script:Connection ) {
                Disconnect-TSqlInstance -Connection $Script:Connection
            }
        }

        It 'Returns a connection' {
            $Script:Connection = Connect-TSqlInstance -ConnectionString "Data Source=$( $Script:LocalDb.DataSource );Integrated Security=True"
            $Script:Connection.State | Should -be 'Open'
        }

        It 'Returns a connection by properties' {
            $Script:Connection = Connect-TSqlInstance -DataSource $Script:LocalDb.DataSource
            $Script:Connection.State | Should -be 'Open'
        }

    }

    Context 'AzureSql' -Tag AzureSql {

        BeforeDiscovery {
            $Script:AzureIsDisconnected = $true

            $azAccounts = Import-Module Az.Accounts -PassThru
            if ( $azAccounts ) {
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
