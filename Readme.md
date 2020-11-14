# PsSqlClient

The PowerShell SQL Client module aims to replace to the SQL Server utilities [SQLCMD](https://docs.microsoft.com/de-de/sql/tools/sqlcmd-utility) and [BCP](https://docs.microsoft.com/en-us/sql/tools/BCP-utility) with native PowerShell commands.

## Commands

- [x] Connect-Instance | Create a new database connection.
  - [x] by Connection String
  - [ ] by Properties
  - [ ] with AD credentials
  - [ ] to Azure SQL
- [ ] Disconnect-Instance
- [ ] Add-Row

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
