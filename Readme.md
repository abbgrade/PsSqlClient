# PsSqlClient

The PowerShell SQL Client module aims to replace to the SQL Server utilities [SQLCMD](https://docs.microsoft.com/de-de/sql/tools/sqlcmd-utility) and [BCP](https://docs.microsoft.com/en-us/sql/tools/BCP-utility) with native PowerShell commands.

![CI](https://github.com/abbgrade/PsSqlClient/workflows/CI/badge.svg)

## Commands

| Command | Description | Status |
|--| -- | -- |
| Connect-Instance | Create a new database connection. | &#9744;
| &#11185; by Connection String | Use a custom connection string. | &#9745; |
| &#11185; by Properties | Use specific properties for host, database, user, etc. | &#9745; |
| &#11185; with AD credentials | Use integrated security | &#9745; |
| &#11185; to Azure SQL | Connect to Azure SQL (token-based) | &#9744;
| &#11185; to Azure SQL | Connect to Azure SQL (AAD) | &#9744;
| Disconnect-Instance | Close connection | &#9745;
| Invoke-Command | Execute stored procedure or select data| &#9745;
| Export-Table | Insert data | &#9745;
| &#11185; show progress | show how many rows already inserted | &#9744;

## Development

- This is a [Portable Module](https://docs.microsoft.com/de-de/powershell/scripting/dev-cross-plat/writing-portable-modules?view=powershell-7)
- [VSCode](https://code.visualstudio.com) is recommended as IDE. [VSCode Tasks](https://code.visualstudio.com/docs/editor/tasks) are configured.
- Build automation is based on [InvokeBuild](https://github.com/nightroman/Invoke-Build)
- Test automation is based on [Pester](https://pester.dev)
- Commands are named based on [Approved Verbs for PowerShell Commands](https://docs.microsoft.com/de-de/powershell/scripting/developer/cmdlet/approved-verbs-for-windows-powershell-commands)

### Build

The build scripts require InvokeBuild. If it is not installed, install it with the command `Install-Module InvokeBuild -Scope CurrentUser`.

You can build the module using the VS Code build task or with the command `Invoke-Build Build`.

### Testing

The tests scripts are based on Pester. If it is not installed, install it with the command `Install-Module -Name Pester -Force -SkipPublisherCheck`. Some tests require a SQL Server. The test creates a SQL Server in a Docker container. If needed, [install Docker](https://www.docker.com/get-started). The container are created using PSDocker, which can be installed using `Install-Module PSDocker -Scope CurrentUser`.
For local testing use the VSCode test tasks or execute the test scripts directly or with `Invoke-Pester`.
The InvokeBuild test tasks are for CI and do not generate console output.
