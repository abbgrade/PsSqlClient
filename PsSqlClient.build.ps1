<#
.Synopsis
	Build script <https://github.com/nightroman/Invoke-Build>
#>

param(
	[ValidateSet('Debug', 'Release')]
	[string]$Configuration = 'Release'
)

# Synopsis: Build project.
task build {
	exec { dotnet build ./src/PsSqlClient -c $Configuration }
}

# Synopsis: Remove files.
task clean {
	remove src/PsSqlClient/bin, src/PsSqlClient/obj
}

# Synopsis: Test project.
task test requireTestDependencies, build, {
	Push-Location test
	Invoke-Pester
	Pop-Location
}

# Synopsis: Install the dependencies for tests.
task requireTestDependencies {

	if ( -not ( Get-Module -ListAvailable -Name Pester )) {
		Install-Module Pester -Scope CurrentUser -SkipPublisherCheck
	} elseif ( ( Get-Module -ListAvailable -Name Pester ).Version.Major -lt 5) {
		Update-Module Pester -Scope CurrentUser
	}
	Write-Verbose "Pester Version: $( ( Get-Module -ListAvailable -Name Pester ).Version )"

	if ( -not ( Get-Module -ListAvailable -Name PSDocker )) {
		Install-Module PSDocker -Scope CurrentUser
	} elseif ( ( Get-Module -ListAvailable -Name PSDocker ).Version.Major -lt 1) {
		Update-Module PSDocker -Scope CurrentUser
	}
	Write-Verbose "PSDocker Version: $( ( Get-Module -ListAvailable -Name PSDocker ).Version )"
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
