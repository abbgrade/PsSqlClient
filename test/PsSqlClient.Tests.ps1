#Requires -Modules @{ ModuleName='Pester'; ModuleVersion='5.0.0' }

Describe 'PsSqlClient' {

    BeforeAll {
        Import-Module -Name ../src/PsSqlClient/bin/Debug/netcoreapp2.1/publish/PsSqlClient.psd1 -Force
    }

    It 'Loads the module' {

        $module = Get-Module -Name 'PsSqlClient'

        $module | Should -Not -BeNullOrEmpty

        Get-Command -Module 'PsSqlClient' | Should -Not -BeNullOrEmpty

    }

}
