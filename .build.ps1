<#
.Synopsis
	Build script <https://github.com/nightroman/Invoke-Build>

.Example
    # Create module from source.
    Invoke-Build Build

.Example
    # Add doc templates for new command.
    # BE CAREFUL! Existing documents will be overwritten and must be discarded using git.
    Invoke-Build Doc.Init -ForceDocInit
#>

param(
	[ValidateSet('Debug', 'Release')]
	[string] $Configuration = 'Debug',

	[string] $NuGetApiKey = $env:nuget_apikey,

	# Overwrite published versions
	[switch] $ForcePublish,

    # Add doc templates for new command.
	[switch] $ForceDocInit,

	# Version suffix to prereleases
	[int] $BuildNumber
)

$ModuleName = 'PsSqlClient'

. $PSScriptRoot\tasks\Dependency.Tasks.ps1
. $PSScriptRoot\tasks\Build.Tasks.ps1

# Synopsis: Default task.
task . Build

task UpdateBuildTasks {
    Invoke-WebRequest `
        -Uri 'https://raw.githubusercontent.com/abbgrade/PsBuildTasks/main/DotNet/Build.Tasks.ps1' `
        -OutFile "$PSScriptRoot\tasks\Build.Tasks.ps1"
}

task UpdateValidationWorkflow {
    Invoke-WebRequest `
        -Uri 'https://raw.githubusercontent.com/abbgrade/PsBuildTasks/main/GitHub/build-validation-matrix.yml' `
        -OutFile "$PSScriptRoot\.github\workflows\build-validation.yml"
}

task UpdatePreReleaseWorkflow {
    Invoke-WebRequest `
        -Uri 'https://raw.githubusercontent.com/abbgrade/PsBuildTasks/main/GitHub/pre-release-windows.yml' `
        -OutFile "$PSScriptRoot\.github\workflows\pre-release.yml"
}

task UpdateReleaseWorkflow {
    Invoke-WebRequest `
        -Uri 'https://raw.githubusercontent.com/abbgrade/PsBuildTasks/main/GitHub/release-windows.yml' `
        -OutFile "$PSScriptRoot\.github\workflows\release.yml"
}

task UpdatePsBuildTasks -Jobs UpdateBuildTasks, UpdateValidationWorkflow, UpdatePreReleaseWorkflow, UpdateReleaseWorkflow
