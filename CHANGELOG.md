# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed
- Update OS compatibility: drop SLES and Solaris

### Fixed
- Move sysctl handling to systemd service ([#2])

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

[Unreleased]: https://github.com/markt-de/puppet-sonarqube/compare/v3.0.0...HEAD
[3.0.0]: https://github.com/markt-de/puppet-sonarqube/compare/v2.6.7...v3.0.0
[#2]: https://github.com/markt-de/puppet-sonarqube/pull/2
[#1]: https://github.com/markt-de/puppet-sonarqube/pull/1
