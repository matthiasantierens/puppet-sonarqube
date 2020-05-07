# Configuration of SonarQube Runner
class sonarqube::runner::config {
  assert_private()

  # Sonar Runner configuration file
  file { "${sonarqube::runner::installroot}/${sonarqube::runner::package_name}-${sonarqube::runner::version}/conf/sonar-runner.properties":
    content => epp("${module_name}/sonar-runner.properties.epp"),
  }
}
