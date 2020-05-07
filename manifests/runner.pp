# Class: sonarqube::runner
#
# Install the sonar-runner
class sonarqube::runner (
  String $package_name = 'sonar-runner',
  String $version = '2.4',
  String $download_url = 'http://repo1.maven.org/maven2/org/codehaus/sonar/runner/sonar-runner-dist',
  Stdlib::Absolutepath $installroot = '/usr/local',
  String $sonarqube_server = 'http://sonar.local:9000/',
  Hash $jdbc = {
    url      => 'jdbc:h2:tcp://localhost:9092/sonar',
    username => 'sonar',
    password => 'sonar',
  },
) {
  Exec {
    path => '/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin',
  }

  anchor { 'sonarqube::runner::begin': }
  -> class { '::sonarqube::runner::install':
    package_name => $package_name,
    version      => $version,
    download_url => $download_url,
    installroot  => $installroot,
  }
  -> class { '::sonarqube::runner::config':
    package_name     => $package_name,
    version          => $version,
    installroot      => $installroot,
    jdbc             => $jdbc,
    sonarqube_server => $sonarqube_server,
  }
  ~> anchor { 'sonarqube::runner::end': }
}
