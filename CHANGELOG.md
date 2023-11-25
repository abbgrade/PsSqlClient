# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed

- Updated Microsoft.Data.SqlClient to 5.1.1.
- Updated System.Management.Automation to 7.2.16 and PowerShell 7.2.16.

### [2.1.1] - 2023-08-16

### Fixed

- PipelineStoppedException does not longer write en ErrorRecord but throws and exception.

## [2.1.0] - 2023-08-02

### Added

- Added debug output for connect command.

## [2.0.1] - 2023-08-02

### Fixed

- The ConnectTimeout was setting the CommandTimeout in the ConnectionString.

### Changed

- The authentication related parameters do not longer use pipeline properties.

## [2.0.0] - 2023-05-30

### Added

- Support for default Azure authentication.
- Acquire token switch.

### Changed

- Parametersets of `Connect-Instance`.

## [1.5.0] - 2023-03-29

### Added

- Added `Test-Connection` command.

### Changed

- Updated to net6.0

## [1.4.0] - 2022-11-23

### Changed

- Updated Microsoft.Data.SqlClient to 5.0.1.

### Added

- Added output when loading dlls.

### Fixed

- Retry ignored with ErrorAction Stop.

## [1.3.1] - 2022-05-19

### Fixed

- Export-Table with GUID columns.
- Default paramter set was not integrated security.

## [1.3.0] - 2022-05-12

### Added

- ColumnMapping parameter on Export-Table command.

## [1.2.0] - 2022-03-23

### Added

- Verbose detail output on exception.

### Fixed

- Access Token authentication.

### Changed

- Updated Microsoft.Data.SqlClient from 3.0.1 to 4.1.0.

## [1.1.0] - 2022-03-19

### Added

- Port parameter for Connect-Instance.
- ConnectTimeout for Connect-Instance.
- Support for Active Directory Credential.

## [1.0.0] - 2022-03-18

### Changed

- Replaced System.Data.SqlClient by Microsoft.Data.SqlClient.
- Updated to netcoreapp3.1.

### Added

- Added output to all commands.
- Fixed parameter validation for stored procedures.

## [0.4.0] - 2021-11-03

### Added

- Added parameter validation.
- Added connection checks.

## [0.2.0] - 2021-09-15

### Changed

- Changed from Debug to Release build.
- Downgrade from .NETStandard 2.0 to .NETCore 2.1.

<!-- markdownlint-configure-file {"MD024": { "siblings_only": true } } -->
