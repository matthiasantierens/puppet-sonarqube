# Configuration of SonarQube Runner
class sonarqube::runner::config {
  assert_private()

  # Sonar Runner configuration file
  file { "${sonarqube::runner::installroot}/${sonarqube::runner::package_name}-${sonarqube::runner::version}/conf/sonar-runner.properties":
    content => template('sonarqube/sonar-runner.properties.erb'),
  }
}
