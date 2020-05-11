# @summary Install and configure SonarQube and additional components
#
# @param arch
#   Specifies the architecture of the installation archive that should be
#   downloaded.
#   Default: Automatically selected depending on the OS architecture.
#
# @param ce_java_opts
#   Optional JVM options for the Compute Engine.
#
# @param ce_workercount
#   The number of workers in the Compute Engine.
#
# @param config
#   Allow to specify an alternative SonarQube configuration, effectively
#   replacing all contens of `sonar.properies`.
#
# @param context_path
#   Specifies the context path for the application.
#
# @param crowd
#   Specifies whether the Crowd plugin should be enabled.
#   Default: `false`
#
# @param download_dir
#   The directory where the SonarQube installation archive should be stored.
#
# @param download_url
#   The URL from which the SonarQube installation archive should be downloaded.
#
# @param edition
#   Specifies the edition of SonarQube that should be installed.
#   Default: `community`
#
# @param group
#   The group for the SonarQube application.
#
# @param home
#   SonarQube's data directory.
#
# @param host
#   Specifies the listen address for SonarQube.
#
# @param http_proxy
#   Specifies the HTTP Proxy that should be used for SonarQube's Update Center.
#
# @param https
#   Specifies the required configuration to enable HTTPS support.
#
# @param installroot
#   Specifies the base directory where SonarQube should be installed. A new
#   subdirectory for each version of SonarQube will be created.
#
# @param jdbc
#   Specifies the database configuration for SonarQube.
#
# @param ldap
#   Specifies the required configuration to enable LDAP authentication.
#
# @param log_folder
#   Specifies the log directory for SonarQube.
#
# @param package_name
#   Specifies the basename of the SonarQube archive.
#
# @param pam
#   Specifies the required configuration to enable PAM authentication.
#
# @param port
#   Specifies the TCP port for SonarQube.
#
# @param portajp
#   Specifies the port to use for the AJP communication protocol.
#
# @param profile
#   Specifies wether profiling should be enabled for SonarQube.
#
# @param search_host
#   Specifies the IP/hostname of the Elasticsearch server.
#
# @param search_java_opts
#   Optional JVM options for the Elasticsearch server.
#
# @param search_port
#   Specifies the TCP port of the Elasticsearch server.
#
# @param service
#   Specifies the name of the SonarQube system service.
#
# @param updatecenter
#   Specifies whether to enable the Update Center.
#
# @param user
#   The user for the SonarQube application.
#
# @param user_system
#   Specifies whether the SonarQube user should be a system user.
#
# @param version
#   Specifies the version of SonarQube that should be installed/updated.
#
# @param web_java_opts
#   Optional JVM options for SonarQube's web server.
#
class sonarqube (
  # required parameters
  String $arch = $sonarqube::params::arch,
  String $context_path = '/',
  Hash $crowd = {},
  String $download_url = 'https://binaries.sonarsource.com/Distribution/sonarqube',
  String $edition = 'community',
  String $group = 'sonar',
  Hash $http_proxy = {},
  Hash $https = {},
  String $home = '/var/local/sonar',
  Stdlib::Absolutepath $installroot = '/usr/local',
  Hash $jdbc = {
    url => 'jdbc:h2:tcp://127.0.0.1:9092/sonar',
    username => 'sonar',
    password => 'sonar',
    max_active => '50',
    max_idle => '5',
    min_idle => '2',
    max_wait => '5000',
    min_evictable_idle_time_millis => '600000',
    time_between_eviction_runs_millis => '30000',
  },
  Hash $ldap = {},
  # ldap and pam are mutually exclusive. Setting $ldap will annihilate the setting of $pam
  Stdlib::Absolutepath $log_folder = '/var/local/sonar/logs',
  String $package_name = 'sonarqube',
  Hash $pam = {},
  Integer $port = 9000,
  Integer $portajp = -1,
  Boolean $profile = false,
  String $search_host = '127.0.0.1',
  Integer $search_port = 9001,
  String $service = 'sonar',
  Stdlib::Absolutepath $download_dir = '/usr/local/src',
  Boolean $updatecenter = true,
  String $user = 'sonar',
  Boolean $user_system = true,
  String $version = '4.5.5',
  # optional parameters
  Optional[String] $ce_java_opts = undef,
  Optional[Integer] $ce_workercount = undef,
  Optional[String] $config = undef,
  Optional[String] $host = undef,
  Optional[String] $search_java_opts = undef,
  Optional[String] $web_java_opts = undef,
) inherits sonarqube::params {
  Exec {
    path => '/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin',
  }
  File {
    owner => $sonarqube::user,
    group => $sonarqube::group,
  }

  $extensions_dir = "${sonarqube::home}/extensions"
  $plugin_dir = "${extensions_dir}/plugins"

  $installdir = "${sonarqube::installroot}/${sonarqube::service}"
  $tmpzip = "${sonarqube::download_dir}/${sonarqube::package_name}-${sonarqube::version}.zip"
  $script = "${installdir}/bin/${sonarqube::arch}/sonar.sh"

  class { 'sonarqube::install': }
  -> class { 'sonarqube::config': }
  -> class { 'sonarqube::service': }
}
