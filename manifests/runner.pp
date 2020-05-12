# @summary Install and configure SonarQube Runner
class sonarqube::runner (
  String $download_url,
  Stdlib::Absolutepath $installroot,
  Hash $jdbc,
  String $distribution_name,
  String $sonarqube_server,
  String $version,
) {
  Exec {
    path => '/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin',
  }

  anchor { 'sonarqube::runner::begin': }
  -> class { '::sonarqube::runner::install': }
  -> class { '::sonarqube::runner::config': }
  ~> anchor { 'sonarqube::runner::end': }
}
