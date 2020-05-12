# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]
This is a new major release in an ongoing effort to modernize the module.

### Added
- Enable unit/acceptance tests on Travis CI
- Add support for RHEL/CentOS 8, Ubuntu 20.04

### Changed
- Change default of `$version` to 7.9 (current LTS version)
- Remove JDBC_URL from config for embedded database (avoids a SonarQube warning)
- Remove template for sonar.sh (use the one that comes bundled with SonarQube)
- Change name of PID file in systemd service (requires the bundled sonar.sh)
- Officially drop support for SonarQube <7.0
- Enforce Puppet 4 data types
- Migrate `params.pp` to Hiera module data
- Replace dependency puppet/wget with puppet/archive ([#4])
- Convert templates from ERB to EPP
- Convert to Puppet Strings
- Declare classes private, remove class parameters from private classes
- Split main class into `sonarqube::install`, `sonarqube::config` and `sonarqube::service`

### Fixed
- Fix for error "missing property sonar.embeddedDatabase.port" ([md#76])
- Fix name of PID file on recent versions of SonarQube
- Assorted style fixes
- Fix unit/acceptance tests
- Fix very old bugs that were uncovered by the resurrected tests

## [3.1.0] - 2020-04-20

### Changed
- Update OS compatibility: drop SLES and Solaris

### Fixed
- Fix startup error: move sysctl handling to systemd service ([#2])

## [3.0.0] - 2019-10-23
This is the first release after forking the module. It should be possible to
migrate from maestrodev/sonarqube to this version with only minor modifications.

### Changed
- Apply PR https://github.com/maestrodev/puppet-sonarqube/pull/75
- Apply PR https://github.com/maestrodev/puppet-sonarqube/pull/78
- Apply PR https://github.com/maestrodev/puppet-sonarqube/pull/80
- Apply PR https://github.com/maestrodev/puppet-sonarqube/pull/81
- Apply PR https://github.com/maestrodev/puppet-sonarqube/pull/89
- Apply PR https://github.com/maestrodev/puppet-sonarqube/pull/92
- Apply PR https://github.com/maestrodev/puppet-sonarqube/pull/95
- Apply PR https://github.com/maestrodev/puppet-sonarqube/pull/96
- Apply PR https://github.com/maestrodev/puppet-sonarqube/pull/97
- Convert to PDK
- Update dependencies, os support and requirements

### Fixed
- Fixes for SonarQube 7.9 LTS ([#1])

[Unreleased]: https://github.com/markt-de/puppet-sonarqube/compare/v3.1.0...HEAD
[3.1.0]: https://github.com/markt-de/puppet-sonarqube/compare/v3.0.0...v3.1.0
[3.0.0]: https://github.com/markt-de/puppet-sonarqube/compare/v2.6.7...v3.0.0
[#4]: https://github.com/markt-de/puppet-sonarqube/pull/4
[#2]: https://github.com/markt-de/puppet-sonarqube/pull/2
[#1]: https://github.com/markt-de/puppet-sonarqube/pull/1
[md#76]: https://github.com/maestrodev/puppet-sonarqube/issues/76
