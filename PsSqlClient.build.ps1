<#
.Synopsis
	Build script <https://github.com/nightroman/Invoke-Build>
#>

param(
	[ValidateSet('Debug', 'Release')]
	[string] $Configuration = 'Release'
)

# Synopsis: Build project.
task build {
	exec { dotnet publish ./src/PsSqlClient -c $Configuration }
}

# Synopsis: Remove files.
task clean {
	remove src/PsSqlClient/bin, src/PsSqlClient/obj
}

# Synopsis: Test project.
task test requireTestDependencies, build, {
	Push-Location test
	Invoke-Pester -CI
	Pop-Location
}

task testDocker requireTestDependencies, build, {
	Push-Location test
	$config = [PesterConfiguration]::Default
	$config.Filter.Tag = 'Docker'
	$config.CodeCoverage.Enabled = $true
	Invoke-Pester -Configuration $config
	Pop-Location
}

task testLocalDb requireTestDependencies, build, {
	Push-Location test
	$config = [PesterConfiguration]::Default
	$config.Filter.Tag = 'LocalDb'
	$config.CodeCoverage.Enabled = $true
	Invoke-Pester -Configuration $config
	Pop-Location
}

task testAzureSql requireTestDependencies, build, {
	Push-Location test
	$config = [PesterConfiguration]::Default
	$config.Filter.Tag = 'AzureSql'
	$config.CodeCoverage.Enabled = $true
	Invoke-Pester -Configuration $config
	Pop-Location
}

# Synopsis: Install the dependencies for tests.
task requirePester {
	$installedPester = Get-Module -ListAvailable -Name Pester | Sort-Object Version -Descending | Select-Object -First 1
	if ( -not ( $installedPester )) {
		Write-Verbose 'Pester is not installed'
		Install-Module Pester -Scope CurrentUser -SkipPublisherCheck -Force
	} elseif ( ( $installedPester | Measure-Object Version -Max ).Maximum.Major -lt 5 ) {
		Write-Verbose 'Pester is not updated'
		( $installedPester | Measure-Object Version -Max ).Maximum | Write-Verbose
		Update-Module Pester -Scope CurrentUser -Force
	}
	Write-Verbose "Pester Version: $( ( $installedPester ).Version )"
}

task requirePsDocker {
	$installedPsDocker = Get-Module -ListAvailable -Name PSDocker
	if ( -not ( $installedPsDocker )) {
		Write-Verbose 'PSDocker is not installed'
		Install-Module PSDocker -Scope CurrentUser -Force
	} elseif ( ( $installedPsDocker | Measure-Object Version -Max ).Maximum.Major -lt 1) {
		Write-Verbose 'PSDocker is not updated'
		( $installedPsDocker | Measure-Object Version -Max ).Maximum | Write-Verbose
		Update-Module PSDocker -Scope CurrentUser -Force
	}
	Write-Verbose "PSDocker Version: $( ( $installedPsDocker ).Version )"
}

task requireTestDependencies requirePester, requirePsDocker

task importModule build, {
	Import-Module ./src/PsSqlClient/bin/Release/netstandard2.0/PsSqlClient.psd1
}

task docs importModule, {

	if ( Test-Path ./docs -PathType Container ) {
		Update-MarkdownHelp ./docs
	} else {
		New-MarkdownHelp -Module PsSqlClient -OutputFolder ./docs
	}
}

# Synopsis: Install the dependencies without installing the module.
task installDependencies {
	Find-Package -ProviderName NuGet -Name System.Data.SqlClient | Install-Package
}

task checkDependencies {
	# Install-Module -Name Gac -Scope CurrentUser
	Get-GacAssembly -Name System.Data.SqlClient
}

# Synopsis: Default task.
task . build
