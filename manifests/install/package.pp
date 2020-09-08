# install sonarqube from packages
class sonarqube::install::package {
  Sonarqube::Move_to_home {
    home => $sonarqube::home,
  }

  # this class intended to be used from sonarqube::install class
  assert_private()

  $arch         = $::sonarqube::arch
  $installdir   = $::sonarqube::installdir
  $package_name = $::sonarqube::package_name
  $version      = $::sonarqube::version

  $arch_dir = "${installdir}/bin/${arch}"
  $sonar_script = "${arch_dir}/sonar.sh"
  $pid_file = "${arch_dir}/SonarQube.pid"

  package { $package_name:
    ensure => $version,
  }
  -> exec {'echo variables':
    command => "echo ${sonarqube::installroot}",
  }
  -> exec { 'move sonar to correct location':
    command => "cp /opt/sonarqube-* ${sonarqube::installroot} && chown -R \
      ${sonarqube::user}:${sonarqube::group} ${sonarqube::installroot}/${sonarqube::distribution_name}-${sonarqube::version} && chown -R ${sonarqube::user}:${sonarqube::group} ${sonarqube::home}",
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
    notify => Class['sonarqube::service'],
  }
  -> sonarqube::move_to_home { 'data': }
  -> sonarqube::move_to_home { 'extras': }
  -> sonarqube::move_to_home { 'extensions': }
  -> sonarqube::move_to_home { 'logs': }

}
