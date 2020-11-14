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
	if ( -not ( Get-Module -ListAvailable -Name PSDocker )) {
		Install-Module PSDocker -Scope CurrentUser
	}
}

# Synopsis: Default task.
task . build
