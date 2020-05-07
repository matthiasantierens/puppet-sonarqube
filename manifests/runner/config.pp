# Configuration of SonarQube Runner
class sonarqube::runner::config (
  String $package_name,
  String $version,
  Stdlib::Absolutepath $installroot,
  String $sonarqube_server = 'http://localhost:9000',
  Hash $jdbc = {
    url      => 'jdbc:h2:tcp://localhost:9092/sonar',
    username => 'sonar',
    password => 'sonar',
  },
) {
  # Sonar Runner configuration file
  file { "${installroot}/${package_name}-${version}/conf/sonar-runner.properties":
    content => template('sonarqube/sonar-runner.properties.erb'),
  }
}
