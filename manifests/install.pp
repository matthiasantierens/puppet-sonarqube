# install sonarqube from packages
class sonarqube::install {
  Sonarqube::Move_to_home {
    home => $sonarqube::home,
  }

  ## this class intended to be used from sonarqube::install class
  #assert_private()

  $package_name = $::sonarqube::package_name
  $version      = $::sonarqube::version

  if ! defined(Package[unzip]) {
    package { 'unzip':
      ensure => present,
    }
  }

  if ! defined(Package[zip]) {
    package { 'zip':
      ensure => present,
    }
  }

  # Create user and group
  user { $sonarqube::user:
    ensure     => present,
    home       => $sonarqube::home,
    managehome => false,
    system     => $sonarqube::user_system,
  }
  -> group { $sonarqube::group:
    ensure => present,
    system => $sonarqube::user_system,
  }


  # Create folder structure
  -> file { $sonarqube::home:
    ensure => directory,
    mode   => '0700',
  }
  -> file { "${sonarqube::installroot}/${sonarqube::distribution_name}-${sonarqube::version}":
    ensure => directory,
  }
  -> file { $sonarqube::installdir:
    ensure => link,
    target => "${sonarqube::installroot}/${sonarqube::distribution_name}-${sonarqube::version}",
    #notify => Class['sonarqube::service'],
  }

  -> sonarqube::move_to_home { 'data': }
  -> sonarqube::move_to_home { 'extras': }
  -> sonarqube::move_to_home { 'extensions': }
  -> sonarqube::move_to_home { 'logs': }


  -> package { $package_name:
    ensure => $version,
    #notify => Class['sonarqube::service'],
  }

  ~> exec { 'sometimes the permssions dont work':
    command => "chown -R ${sonarqube::user}:${sonarqube::group} ${sonarqube::installroot}",
  }

  file { $sonarqube::plugin_dir:
    ensure => directory,
  }  

}
