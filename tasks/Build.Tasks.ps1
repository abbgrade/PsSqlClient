
# Synopsis: Build project.
task build {
	exec { dotnet publish ./src/PsSqlClient -c $Configuration }
}

# Synopsis: Remove files.
task clean {
	remove src/PsSqlClient/bin, src/PsSqlClient/obj
}

[System.IO.FileInfo] $global:Manifest = "$PSScriptRoot/../src/PsSqlClient/bin/$Configuration/netstandard2.0/publish/PsSqlClient.psd1"

task importModule build, {
	Import-Module $global:Manifest
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

task install {
    $info = Import-PowerShellDataFile $global:Manifest.FullName
    $version = ([System.Version] $info.ModuleVersion)
    $name = $global:Manifest.BaseName
    $defaultModulePath = $env:PsModulePath -split ';' | Select-Object -First 1
    $installPath = Join-Path $defaultModulePath $name $version
    New-Item -Type Directory $installPath -Force
    Get-ChildItem $global:Manifest.Directory | Copy-Item -Destination $installPath -Recurse -Force
}
