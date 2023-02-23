# Readme

The PowerShell SQL Client module replaces the SQL Server utilities [SQLCMD](https://docs.microsoft.com/de-de/sql/tools/sqlcmd-utility) and [BCP](https://docs.microsoft.com/en-us/sql/tools/BCP-utility) with native PowerShell commands.

For details, visit the [GitHub Pages](https://abbgrade.github.io/PsSqlClient/).

## Installation

This module can be installed from [PsGallery](https://www.powershellgallery.com/packages/PsSqlClient).

```powershell
Install-Module -Name PsSqlClient -Scope CurrentUser
```

Alternatively it can be build and installed from source.

1. Install the development dependencies
2. Download or clone it from GitHub
3. Run the installation task:

```powershell
Invoke-Build Install
```

## Usage

See [the command reference](./docs/) for descriptions and examples.

### Copy from CSV to SQL database

```powershell
# connect to a SQL Server using your current Windows login
Connect-TSqlInstance -DataSource '(LocalDb)\MSSQLLocalDB'

# create a temporary table with the columns of your CSV file
Invoke-TSqlCommand 'CREATE TABLE #Test (Id INT NULL, Name NVARCHAR(MAX))'

# copy the data from CSV to the SQL table
Import-Csv 'test.csv' | Export-TSqlTable '#Test'
```

### Get a single value

```powershell
# connect to a SQL Server using your current Windows login
Connect-TSqlInstance -DataSource '(LocalDb)\MSSQLLocalDB'

# get a scalar value from the database
[string] $databaseName = Get-TSqlValue 'SELECT DB_NAME()'
```

### Parameterize a query and process results in a pipeline

```powershell
# connect to a SQL Server using your current Windows login
Connect-TSqlInstance -DataSource '(LocalDb)\MSSQLLocalDB'

# get a result from the database and filter the first five by name
Invoke-TSqlProcedure 'sp_tables' @{ 'table_qualifier' = 'master' } |
    Sort-Object TABLE_NAME |
    Select-Object -First 5
```

## Commands

| Command                                | Description                                            | Status  |
| -------------------------------------- | ------------------------------------------------------ | ------- |
| Connect-Instance                       | Create a new database connection.                      | &#9744; |
| &#11185; by Connection String          | Use a custom connection string.                        | &#9745; |
| &#11185; by Properties                 | Use specific properties for host, database, user, etc. | &#9745; |
| &#11185; with AD credentials           | Use integrated security                                | &#9745; |
| &#11185; to Azure SQL                  | Connect to Azure SQL (token-based)                     | &#9744; |
| &#11185; to Azure SQL                  | Connect to Azure SQL (AAD)                             | &#9745; |
| &#11185; global connection             | Save and reuse the connection                          | &#9745; |
| Disconnect-Instance                    | Close connection                                       | &#9745; |
| Invoke-Command                         | Execute stored procedure or select data                | &#9745; |
| &#11185; Procedure instead of SQL text | Execute procedure by procedure name                    | &#9745; |
| &#11185; SQL text from file            | Execute sql command from file                          | &#9745; |
| Export-Table                           | Insert data                                            | &#9745; |
| &#11185; show progress                 | show how many rows already inserted                    | &#9744; |

## Changelog

See the [changelog](./CHANGELOG.md) file.

## Development

[![.github/workflows/build-validation.yml](https://github.com/abbgrade/PsSqlClient/actions/workflows/build-validation.yml/badge.svg?branch=develop)](https://github.com/abbgrade/PsSqlClient/actions/workflows/build-validation.yml)

- This is a [Portable Module](https://docs.microsoft.com/de-de/powershell/scripting/dev-cross-plat/writing-portable-modules?view=powershell-7) based on [PowerShell Standard](https://github.com/powershell/powershellstandard) and [.NET Standard](https://docs.microsoft.com/en-us/dotnet/standard/net-standard).
- [VSCode](https://code.visualstudio.com) is recommended as IDE. [VSCode Tasks](https://code.visualstudio.com/docs/editor/tasks) are configured.
- Build automation is based on [InvokeBuild](https://github.com/nightroman/Invoke-Build)
- Documentation is based on [platyPs](https://github.com/PowerShell/platyPS)
- Test automation is based on [Pester](https://pester.dev)
- Commands are named based on [Approved Verbs for PowerShell Commands](https://docs.microsoft.com/de-de/powershell/scripting/developer/cmdlet/approved-verbs-for-windows-powershell-commands)
- This project uses [git-flow](https://github.com/nvie/gitflow).
- This project uses [keep a changelog](https://keepachangelog.com/en/1.0.0/).
- This project uses [PsBuildTasks](https://github.com/abbgrade/PsBuildTasks).

### Build

The build scripts require InvokeBuild. If it is not installed, install it with the command `Install-Module InvokeBuild -Scope CurrentUser`.

You can build the module using the VS Code build task or with the command `Invoke-Build Build`.

### Testing

The tests scripts are based on Pester. If it is not installed, install it with the command `Install-Module Pester -Force -SkipPublisherCheck`. Some tests require a SQL Server. Therefore the module PsSqlTestServer is used, that can be installed by `Install-Module PsSqlTestServer -Scope CurrentUser`. The test creates a SQL Server in a Docker container. If needed, [install Docker](https://www.docker.com/get-started). The container are created using PSDocker, which can be installed using `Install-Module PSDocker -Scope CurrentUser`.

For local testing use the VSCode test tasks or execute the test scripts directly or with `Invoke-Pester`.
The InvokeBuild test tasks are for CI and do not generate console output.

### Release

1. Create a release branch using git-flow.
2. Update the version number in the module manifest.
3. Extend the changelog in this readme.
4. If you want to create a pre-release.
   1. Push the release branch to github, to publish the pre-release to PsGallery.
5. Finish release using git-flow.
6. Check if tags are not pushed to github.
7. Check if the release branch is deleted on github.
8. Create the release on github.
