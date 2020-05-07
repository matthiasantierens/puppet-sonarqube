# Installation of SonarQube Runner
class sonarqube::runner::install (
  $package_name,
  $version,
  $download_url,
  $installroot,
) {
  if ! defined(Package[unzip]) {
    package { 'unzip':
      ensure => present,
      before => Exec[unzip-sonar-runner],
    }
  }

  $tmpzip = "/usr/local/src/${package_name}-dist-${version}.zip"

  archive { 'download-sonar-runner':
    ensure => present,
    path   => $tmpzip,
    source => "${download_url}/${version}/sonar-runner-dist-${version}.zip",
  }

  -> file { "${installroot}/${package_name}-${version}":
    ensure => directory,
  }

  -> file { "${installroot}/${package_name}":
    ensure => link,
    target => "${installroot}/${package_name}-${version}",
  }

  -> exec { 'unzip-sonar-runner':
    command => "unzip -o ${tmpzip} -d ${installroot}",
    creates => "${installroot}/sonar-runner-${version}/bin",
    require => [Package[unzip], Archive['download-sonar-runner']],
  }

  # Sonar settings for terminal sessions.
  file { '/etc/profile.d/sonarhome.sh':
    content => "export SONAR_RUNNER_HOME=${installroot}/${package_name}-${version}",
  }

  file { '/usr/bin/sonar-runner':
    ensure => link,
    target => "${installroot}/${package_name}-${version}/bin/sonar-runner",
  }
}
