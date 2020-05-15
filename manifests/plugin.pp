# @summary Manage SonarQube plugins: download, install, remove.
#
# @param artifactid
#   Namevar. Specifies the name of the plugin.
#
# @param ensure
#   Specifies the ensure state for the plugin.
#   Default: `present`
#
# @param ghid
#   Specifies a combination of a GitHub username and project name,
#   for example `myuser/sonar-exampleplugin`. This is used to generate
#   the download URL.
#
# @param groupid
#   Specifies the groupid to use with maven.
#
# @param url
#   A direct download URL that points to the .jar file for the specified plugin.
#   The filename must match the values of `$name` and `$version`, otherwise the
#   cleanup script may malfunction.
#
# @param version
#   Specifies the version of the plugin. This is also required to find
#   and purge old plugin versions.
#
define sonarqube::plugin (
  String $version,
  String $artifactid = $name,
  Enum['present','absent'] $ensure = present,
  Boolean $legacy = false,
  String $groupid = 'org.codehaus.sonar-plugins',
  Optional[String] $ghid = undef,
  Optional[String] $url = undef,
) {
  include '::sonarqube'

  $plugin_name = "${artifactid}-${version}.jar"
  $plugin_tmp  = "${sonarqube::plugin_tmpdir}/${plugin_name}"
  $plugin      = "${sonarqube::plugin_dir}/${plugin_name}"

  # Install plugin
  if $ensure == present {

    # Use direct download URL for installation
    if $url {
      archive { "download sonarqube plugin ${plugin_name}":
        ensure => present,
        path   => $plugin_tmp,
        source => $url,
        before => File[$plugin],
        notify => [
          File[$plugin],
          Exec["remove old versions of ${artifactid}"],
        ],
      }
    # Use GitHub project URL for installation
    } elsif $ghid {
      # Compose GitHub download URL. If the project does not use this
      # pattern, then the direct download method should be used.
      $_ghurl = "https://github.com/${ghid}/releases/download/${version}/${artifactid}-${version}.jar"

      archive { "download sonarqube plugin ${plugin_name} from GitHub":
        ensure => present,
        path   => $plugin_tmp,
        source => $_ghurl,
        before => File[$plugin],
        notify => [
          File[$plugin],
          Exec["remove old versions of ${artifactid}"],
        ],
      }
    # Install from SonarSource
    } elsif ($legacy == false) and $version {
      # Compose SonarSource download URL. Let's hope that they stick to
      # this pattern for years to come.
      $_sonarurl = "https://binaries.sonarsource.com/Distribution/${artifactid}/${artifactid}-${version}.jar"

      archive { "download sonarqube plugin ${plugin_name} from SonarSource":
        ensure => present,
        path   => $plugin_tmp,
        source => $_sonarurl,
        before => File[$plugin],
        notify => [
          File[$plugin],
          Exec["remove old versions of ${artifactid}"],
        ],
      }
    # Legacy method: install using Maven. May not work with recent versions.
    } elsif ($legacy == true) and $version {
      maven { "/tmp/${plugin_name}":
        groupid    => $groupid,
        artifactid => $artifactid,
        version    => $version,
        before     => File[$plugin],
        require    => File[$sonarqube::plugin_dir],
        notify     => [
          File[$plugin],
          Exec["remove old versions of ${artifactid}"],
        ],
      }
    } else {
      fail("Unable to install plugin ${artifactid}: usage error. Missing parameters")
    }

    # Copy plugin from tmp location to plugin directory.
    file { $plugin:
      ensure => $ensure,
      source => "/tmp/${plugin_name}",
      owner  => $sonarqube::user,
      group  => $sonarqube::group,
      notify => Class['sonarqube::service'],
    }
    # Cleanup old version of this plugin
    ~> exec { "remove old versions of ${artifactid}":
      command     => "/tmp/cleanup-old-plugin-versions.sh ${sonarqube::plugin_dir} ${artifactid} ${version}",
      path        => ['/bin', '/sbin', '/usr/bin', '/usr/sbin', '/usr/local/bin', '/usr/local/sbin'],
      refreshonly => true,
    }
  } else {
    # Uninstall plugin
    file { $plugin:
      ensure => $ensure,
      notify => Class['sonarqube::service'],
    }
  }
}
