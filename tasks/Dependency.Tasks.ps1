task InstallBuildDependencies -Jobs {
    Install-Module platyPs -Scope CurrentUser
}

task InstallTestDependencies -Jobs {
    Install-Module PsSqlTestServer -Scope CurrentUser
}

task InstallReleaseDependencies -Jobs {}
