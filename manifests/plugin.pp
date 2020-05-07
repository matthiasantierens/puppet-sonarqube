# @summary Install a SonarQube plugin
#
# @param artifactid
#   Namevar. Specifies the name of the plugin.
#
# @param ensure
#   Specifies the ensure state for the plugin.
#   Default: `present`
#
# @param groupid
#   Specifies the groupid to use with maven.
#
# @param version
#   Specifies the version of the plugin.
#
define sonarqube::plugin (
  String $version,
  String $artifactid = $name,
  Enum['present','absent'] $ensure = present,
  String $groupid = 'org.codehaus.sonar-plugins',
) {
  $plugin_name = "${artifactid}-${version}.jar"
  $plugin      = "${sonarqube::plugin_dir}/${plugin_name}"

  # Install plugin
  if $ensure == present {
    # copy to a temp file as Maven can run as a different user and not have rights to copy to
    # sonar plugin folder
    maven { "/tmp/${plugin_name}":
      groupid    => $groupid,
      artifactid => $artifactid,
      version    => $version,
      before     => File[$plugin],
      require    => File[$sonarqube::plugin_dir],
    }
    ~> exec { "remove-old-versions-of-${artifactid}":
      command     => "/tmp/cleanup-old-plugin-versions.sh ${sonarqube::plugin_dir} ${artifactid} ${version}",
      path        => '/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin',
      refreshonly => true,
    }
    -> file { $plugin:
      ensure => $ensure,
      source => "/tmp/${plugin_name}",
      owner  => $sonarqube::user,
      group  => $sonarqube::group,
      notify => Service['sonarqube'],
    }
  } else {
    # Uninstall plugin if absent
    file { $plugin:
      ensure => $ensure,
      notify => Service['sonarqube'],
    }
  }
}
