# puppet-sonarqube

[![Build Status](https://travis-ci.org/markt-de/puppet-sonarqube.png?branch=master)](https://travis-ci.org/markt-de/puppet-sonarqube)
[![Puppet Forge](https://img.shields.io/puppetforge/v/fraenki/sonarqube.svg)](https://forge.puppetlabs.com/fraenki/sonarqube)
[![Puppet Forge](https://img.shields.io/puppetforge/f/fraenki/sonarqube.svg)](https://forge.puppetlabs.com/fraenki/sonarqube)

#### Table of Contents

1. [Overview](#overview)
2. [Usage](#usage)
    - [Basic usage](#basic-usage)
    - [SonarQube Plugins](#sonarqube-plugins)
    - [LDAP Configuration](#ldap-configuration)
3. [Development](#development)
    - [Contributing](#contributing)
    - [Fork](#fork)
4. [License](#license)

## Overview

A puppet module to install and configure SonarQube (former Sonar).

## Usage

### Basic usage

The minimum configuration should at least specify the desired version:

```puppet
class { 'java': }
class { 'sonarqube':
  version => '7.9',
}
```

A more complex example could look like this:

```puppet
class { 'sonarqube':
  version       => '7.9,
  edition       => 'community',
  user          => 'sonar',
  group         => 'sonar',
  service       => 'sonar',
  installroot   => '/opt/sonar-install',
  home          => '/opt/sonar-data',
  log_folder    => '/var/log/sonar',
  download_url  => 'https://binaries.sonarsource.com/Distribution/sonarqube'
  jdbc          => {
    url         => 'jdbc:h2:tcp://localhost:9092/sonar',
    username    => 'sonar',
    password    => 'secretpassword',
  },
  web_java_opts => '-Xmx1024m',
  log_folder    => '/var/local/sonar/logs',
  updatecenter  => 'true',
  http_proxy    => {
    host        => 'proxy.example.com',
    port        => '8080',
    ntlm_domain => '',
    user        => '',
    password    => '',
  }
}
```

### SonarQube Plugins

The `sonarqube::plugin` defined type can be used to install SonarQube plugins. Note that Maven is required to download the plugins then.

```puppet
class { 'java': }
class { 'maven::maven': }
->
class { 'sonarqube': }

sonarqube::plugin { 'sonar-javascript-plugin':
  groupid    => 'org.sonarsource.javascript',
  artifactid => 'sonar-javascript-plugin',
  version    => '2.10',
  notify     => Service['sonar'],
}
```

### LDAP Configuration

The `sonarqube` class provides an easy way to configure security with LDAP, Crowd or PAM. Here's an example with LDAP:

```puppet
$ldap = {
  url          => 'ldap://myserver.mycompany.com',
  user_base_dn => 'ou=Users,dc=mycompany,dc=com',
  local_users  => ['foo', 'bar'],
}

class { 'java': }
class { 'maven::maven': }
-> class { 'sonarqube':
  ldap => $ldap,
}

# Do not forget to add the SonarQube LDAP plugin that is not provided out of the box.
# Same thing with Crowd or PAM.
sonarqube::plugin { 'sonar-ldap-plugin':
  groupid    => 'org.sonarsource.ldap',
  artifactid => 'sonar-ldap-plugin',
  version    => '1.5.1',
  notify     => Service['sonar'],
}
```

## Development

### Contributing

Please use the GitHub issues functionality to report any bugs or requests for new features. Feel free to fork and submit pull requests for potential contributions.

All contributions must pass all existing tests, new features should provide additional unit/acceptance tests.

### Fork

This is a fork of the now-defunct maestrodev/puppet-sonarqube with the following upstream PRs (partially) applied in 02/2019:

* https://github.com/maestrodev/puppet-sonarqube/pull/75
* https://github.com/maestrodev/puppet-sonarqube/pull/78
* https://github.com/maestrodev/puppet-sonarqube/pull/80
* https://github.com/maestrodev/puppet-sonarqube/pull/81
* https://github.com/maestrodev/puppet-sonarqube/pull/89
* https://github.com/maestrodev/puppet-sonarqube/pull/92
* https://github.com/maestrodev/puppet-sonarqube/pull/95
* https://github.com/maestrodev/puppet-sonarqube/pull/96
* https://github.com/maestrodev/puppet-sonarqube/pull/97

## License

```
Copyright 2019-2020 markt.de GmbH & Co. KG
Copyright 2011-2013 MaestroDev, Inc

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
