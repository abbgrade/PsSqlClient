task InstallBuildDependencies -Jobs {
    Install-Module platyPs -Scope CurrentUser
}

task InstallTestDependencies -Jobs {}

task InstallPublishDependencies -Jobs {}
