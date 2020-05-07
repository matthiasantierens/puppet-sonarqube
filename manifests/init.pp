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
  Stdlib::Absolutepath $installroot = '/usr/local',
  Hash $jdbc = {
    url => 'jdbc:h2:tcp://localhost:9092/sonar',
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
  Optional[String] $home = undef,
  Optional[String] $host = undef,
  Optional[String] $search_java_opts = undef,
  Optional[String] $web_java_opts = undef,
) inherits sonarqube::params {
  Exec {
    path => '/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin',
  }
  File {
    owner => $user,
    group => $group,
  }

  $package_name = 'sonarqube'

  if $home != undef {
    $real_home = $home
  } else {
    $real_home = '/var/local/sonar'
  }
  Sonarqube::Move_to_home {
    home => $real_home,
  }

  $extensions_dir = "${real_home}/extensions"
  $plugin_dir = "${extensions_dir}/plugins"

  $installdir = "${installroot}/${service}"
  $tmpzip = "${download_dir}/${package_name}-${version}.zip"
  $script = "${installdir}/bin/${arch}/sonar.sh"

  if $edition == 'community' {
    $source_url = "${download_url}/${package_name}-${version}.zip"
  } else {
    $source_url = "${download_url}/${package_name}-${edition}-${version}.zip"
  }

  if ! defined(Package[unzip]) {
    package { 'unzip':
      ensure => present,
      before => Exec[untar],
    }
  }

  user { $user:
    ensure     => present,
    home       => $real_home,
    managehome => false,
    system     => $user_system,
  }
  -> group { $group:
    ensure => present,
    system => $user_system,
  }
  -> archive { 'download-sonar':
    ensure => present,
    path   => $tmpzip,
    source => $source_url,
  }

  # ===== Create folder structure =====
  # so uncompressing new sonar versions at update time use the previous sonar home,
  # installing new extensions and plugins over the old ones, reusing the db,...

  # Sonar home
  -> file { $real_home:
    ensure => directory,
    mode   => '0700',
  }
  -> file { "${installroot}/${package_name}-${version}":
    ensure => directory,
  }
  -> file { $installdir:
    ensure => link,
    target => "${installroot}/${package_name}-${version}",
    notify => Service['sonarqube'],
  }
  -> sonarqube::move_to_home { 'data': }
  -> sonarqube::move_to_home { 'extras': }
  -> sonarqube::move_to_home { 'extensions': }
  -> sonarqube::move_to_home { 'logs': }
  # ===== Install SonarQube =====
  -> exec { 'untar':
    command => "unzip -o ${tmpzip} -d ${installroot} && chown -R \
      ${user}:${group} ${installroot}/${package_name}-${version} && chown -R ${user}:${group} ${real_home}",
    creates => "${installroot}/${package_name}-${version}/bin",
    notify  => Service['sonarqube'],
  }
  -> file { $script:
    mode    => '0755',
    content => template('sonarqube/sonar.sh.erb'),
  }
  -> file { "/etc/init.d/${service}":
    ensure => link,
    target => $script,
  }

  file { '/etc/systemd/system/sonar.service':
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => '0644',
    content => template("${module_name}/sonar.service.erb")
  }

  # Sonar configuration files
  if $config != undef {
    file { "${installdir}/conf/sonar.properties":
      source  => $config,
      require => Exec['untar'],
      notify  => Service['sonarqube'],
      mode    => '0600',
    }
  } else {
    file { "${installdir}/conf/sonar.properties":
      content => template('sonarqube/sonar.properties.erb'),
      require => Exec['untar'],
      notify  => Service['sonarqube'],
      mode    => '0600',
    }
  }

  file { '/tmp/cleanup-old-plugin-versions.sh':
    content => template("${module_name}/cleanup-old-plugin-versions.sh.erb"),
    mode    => '0755',
  }
  -> file { '/tmp/cleanup-old-sonarqube-versions.sh':
    content => template("${module_name}/cleanup-old-sonarqube-versions.sh.erb"),
    mode    => '0755',
  }
  -> exec { 'remove-old-versions-of-sonarqube':
    command     => "/tmp/cleanup-old-sonarqube-versions.sh ${installroot} ${version}",
    path        => '/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin',
    refreshonly => true,
    subscribe   => File["${installroot}/${package_name}-${version}"],
  }

  # The plugins directory. Useful to later reference it from the plugin definition
  file { $plugin_dir:
    ensure => directory,
  }

  service { 'sonarqube':
    ensure     => running,
    name       => $service,
    hasrestart => true,
    hasstatus  => true,
    enable     => true,
    require    => [ File["/etc/init.d/${service}"], File['/etc/systemd/system/sonar.service'] ]
  }
}
