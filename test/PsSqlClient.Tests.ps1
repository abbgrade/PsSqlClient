#Requires -Modules @{ ModuleName='Pester'; ModuleVersion='5.0.0' }

Describe 'PsSqlClient' {

    BeforeAll {
        $Script:ManifestPath = Get-Item $PSScriptRoot\..\publish\PsSqlClient\PsSqlClient.psd1
    }

    It 'Has valid manifest' {
        Test-ModuleManifest -Path $Script:ManifestPath
    }

    Context 'Loaded Modules' {

        BeforeAll {
            Import-Module $Script:ManifestPath
            Import-Module PsSqlTestServer
        }

        It 'Has matching dependencies' {
            function Get-Library {

                [CmdletBinding()]
                param (
                    [Parameter(Mandatory, ValueFromPipeline)]
                    $Module
                )

                process {
                    $Module.ModuleBase | ForEach-Object {
                        $_ | Get-ChildItem -Filter *.dll | ForEach-Object {
                            [PSCustomObject]@{
                                Module  = $Module.Name
                                Name    = $PSItem.BaseName
                                Version = $PSItem.VersionInfo.FileVersion
                            }
                        }
                    }
                }
            }

            $dllFiles = Get-Module PsSqlTestServer, PsSqlClient | Where { $PSItem.Name -NotIn @( 'Microsoft.PowerShell.Management', 'Microsoft.PowerShell.Security', 'Microsoft.PowerShell.Utility', 'Microsoft.WSMan.Management' ) } | Get-Library
            $dllFiles | Group-Object Name | Where-Object {
                if ( ( $PSItem.Group | Select-Object -ExpandProperty Version -Unique ).Count -gt 1 ) {
                    $versions = $PSItem.Group | Group-Object Version | Sort-Object
                    Write-Warning "$( $PSItem.Name ) is used: $( $versions | ForEach-Object { "in $( $PSItem.Name ) by $( $PSItem.Group | Select-Object -ExpandProperty Module );" } )"
                }
            }
        }
    }
}
