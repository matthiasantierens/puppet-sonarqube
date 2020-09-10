# @summary Configure SonarQube
# @api private
class sonarqube::config {
  File {
    owner => $sonarqube::user,
    group => $sonarqube::group,
  }

  # Create configuration files
  if $sonarqube::config != undef {
    # Create config from scratch, do not use the template.
    file { "${sonarqube::home}/conf/sonar.properties":
      source => $sonarqube::config,
      notify => Class['sonarqube::service'],
      mode   => '0600',
    }
  } else {
    # Create config from template.
    file { "${sonarqube::installroot}/conf/sonar.properties":
      content => epp("${module_name}/sonar.properties.epp"),
      notify  => Class['sonarqube::service'],
      mode    => '0600',
    }
  }
}
