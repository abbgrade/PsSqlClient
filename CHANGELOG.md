# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Port parameter for Connect-Instance.

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
