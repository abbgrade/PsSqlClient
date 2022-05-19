#Requires -Modules @{ ModuleName='Pester'; ModuleVersion='5.2.0' }

Describe Export-Table {

    BeforeDiscovery {
        Import-Module $PSScriptRoot/../publish/PsSqlClient/PsSqlClient.psd1 -Force -ErrorAction Stop
        Import-Module PsSqlTestServer -ErrorAction Stop
    }

    Context TestInstance {

        BeforeAll {
            $Script:TestInstance = New-SqlTestInstance -ErrorAction Stop
        }

        AfterAll {
            $Script:TestInstance | Remove-SqlTestInstance
        }

        Context Connection {

            BeforeAll {
                $Script:Connection = $Script:TestInstance | Connect-TSqlInstance
            }

            AfterAll {
                if ( $Script:Connection ) {
                    $Script:Connection | Disconnect-TSqlInstance -ErrorAction Continue
                }
            }

            Context Table {
                BeforeAll {
                    Invoke-TSqlCommand 'CREATE TABLE #test (Id INT IDENTITY, Name NVARCHAR(MAX) NOT NULL)'
                }

                BeforeEach {
                    Invoke-TSqlCommand 'TRUNCATE TABLE #test'
                }

                It Inserts {
                    @(
                        [PSCustomObject] @{ Id = 1; Name = 'Iron Maiden' },
                        [PSCustomObject] @{ Id = 2; Name = 'Killers' },
                        [PSCustomObject] @{ Id = 3; Name = 'The Number of the Beast' }
                    ) | Export-TSqlTable -Table '#test' -Connection $Script:Connection

                    Get-TSqlValue 'SELECT COUNT(*) FROM #test' | Should -Be 3
                }

                It ThrowsOnNull {
                    {
                        @(
                            [PSCustomObject] @{ Id = 4; Name = $null }
                        ) | Export-TSqlTable -Table '#test' -Connection $Script:Connection
                    } | Should -Throw 'Column ''Name'' does not allow DBNull.Value.'
                }

                It InsertsWithKeepNulls {
                    {
                        @(
                            [PSCustomObject] @{ Id = 4; Name = $null }
                        ) | Export-TSqlTable -Table '#test' -KeepNulls
                    } | Should -Throw 'Column ''Name'' does not allow DBNull.Value.'
                }

                It InsertsWithKeepIdentity {
                    @(
                        [PSCustomObject] @{ Id = 666; Name = 'The Number of the Beast' }
                    ) | Export-TSqlTable -Table '#test' -KeepIdentity

                    $rows = Invoke-TSqlCommand 'SELECT * FROM #test'
                    $rows | Where-Object Id -eq 666 | Select-Object -ExpandProperty Name | Should -Be 'The Number of the Beast'
                }
            }

            Context TableWithGuid {
                BeforeAll {
                    Invoke-TSqlCommand 'CREATE TABLE #test2 (Id UNIQUEIDENTIFIER NOT NULL, Name NVARCHAR(MAX) NOT NULL)'
                }

                BeforeEach {
                    Invoke-TSqlCommand 'TRUNCATE TABLE #test2'
                }

                It Inserts {
                    @(
                        [PSCustomObject] @{ Id = New-Guid; Name = 'Lorem' },
                        [PSCustomObject] @{ Id = New-Guid; Name = 'Ipsum' }
                    ) | Export-TSqlTable -Table '#test2' -Connection $Script:Connection -Verbose

                    Get-TSqlValue 'SELECT COUNT(*) FROM #test2' | Should -Be 2
                }
            }
        }
    }
}
