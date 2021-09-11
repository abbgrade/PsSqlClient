<#
.Synopsis
	Build script <https://github.com/nightroman/Invoke-Build>
#>

param(
	[ValidateSet('Debug', 'Release')]
	[string] $Configuration = 'Release'
)

. $PSScriptRoot\tasks\Build.Tasks.ps1
. $PSScriptRoot\tasks\Test.Tasks.ps1

# Synopsis: Default task.
task . build
