# Definition: plugin
#
# A puppet definition for Sonar plugin installation
#
define sonarqube::plugin(
  $version,
  $ensure     = present,
  $artifactid = $name,
  $groupid    = 'org.codehaus.sonar-plugins',
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
