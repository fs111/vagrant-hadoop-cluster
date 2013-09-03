class hadoop {
  $hadoop_version = "2.1.0-beta"
  $hadoop_home = "/opt/hadoop-${hadoop_version}"
  $hadoop_tarball = "hadoop-${hadoop_version}.tar.gz"
  $hadoop_tarball_checksums = "${hadoop_tarball}.mds"
  $hadoop_conf_dir = "${hadoop_home}/etc/hadoop"
  $hadoop_logs_basedir = "$hadoop_home/logs"
  $hadoop_log_dir  = "${hadoop_logs_basedir}/hadoop"
  $yarn_log_dir  = "${hadoop_logs_basedir}/yarn"
  $mapred_log_dir  = "${hadoop_logs_basedir}/mapred"

  file { ["/srv/hadoop/",  "/srv/hadoop/namenode", "/srv/hadoop/datanode/"]:
    ensure => "directory",
    owner => "hdfs",
    group => "hadoop"
  }
  
  exec { "download_grrr":
    command => "wget --no-check-certificate http://raw.github.com/fs111/grrrr/master/grrr -O /tmp/grrr && chmod +x /tmp/grrr",
    path => $path,
    creates => "/tmp/grrr",
  }

  exec { "download_hadoop":
    command => "/tmp/grrr /hadoop/common/hadoop-${hadoop_version}/$hadoop_tarball -O /vagrant/$hadoop_tarball --read-timeout=5 --tries=0",
    timeout => 1800,
    path => $path,
    creates => "/vagrant/$hadoop_tarball",
    require => [ Package["openjdk-6-jdk"], Exec["download_grrr"]]
  }

  exec { "download_checksum":
    command => "/tmp/grrr /hadoop/common/hadoop-${hadoop_version}/$hadoop_tarball_checksums -O /vagrant/$hadoop_tarball_checksums --read-timeout=5 --tries=0",
    timeout => 1800,
    path => $path,
    unless => "ls /vagrant | grep ${hadoop_tarball_checksums}",
    require => Exec["download_grrr"],
  }
  
  file { "/tmp/verifier":
      source => "puppet:///modules/hadoop/verifier",
      mode => 755,
      owner => root,
      group => root,
  }

  exec{ "verify_tarball":
    command =>  "/tmp/verifier /vagrant/${hadoop_tarball_checksums}", 
    path => $path,
    require => [File["/tmp/verifier"], Exec["download_hadoop"], Exec["download_checksum"]]
  }

  exec { "unpack_hadoop" :
    command => "tar xf /vagrant/${hadoop_tarball} -C /opt",
    path => $path,
    creates => "${hadoop_home}",
    require => Exec["verify_tarball"]
  }
  
  file{ $hadoop_logs_basedir:
    ensure => "directory",
    group => "hadoop",
    require => Exec["unpack_hadoop"] 
  }

  file {$hadoop_log_dir:
    ensure => "directory",
    owner => "hdfs",
    group => "hadoop",
    require => File[$hadoop_logs_basedir] 
  }

  file {$yarn_log_dir:
    ensure => "directory",
    owner => "yarn",
    group => "hadoop",
    require => File[$hadoop_logs_basedir] 
  }

  file {$mapred_log_dir:
    ensure => "directory",
    owner => "mapred",
    group => "hadoop",
    require => File[$hadoop_logs_basedir] 
  }
  
  file { "${hadoop_conf_dir}":
    ensure => "directory",
    require => Exec["unpack_hadoop"]
  }

  file {
    "${hadoop_conf_dir}/slaves":
      source => "puppet:///modules/hadoop/slaves",
      mode => 644,
      owner => root,
      group => root,
      require => File["${hadoop_conf_dir}"]
  }

  file {
    "${hadoop_home}/bin/start-all.sh":
      source => "puppet:///modules/hadoop/start-all.sh",
      mode => 755,
      owner => root,
      group => root,
      require => Exec["unpack_hadoop"]
  }
  
  file {
    "${hadoop_home}/bin/prepare-cluster.sh":
      source => "puppet:///modules/hadoop/prepare-cluster.sh",
      mode => 755,
      owner => root,
      group => root,
      require => Exec["unpack_hadoop"]
  }
  file {
    "${hadoop_home}/bin/stop-all.sh":
      source => "puppet:///modules/hadoop/stop-all.sh",
      mode => 755,
      owner => root,
      group => root,
      require => Exec["unpack_hadoop"]
  }

  file {
    "${hadoop_conf_dir}/masters":
      source => "puppet:///modules/hadoop/masters",
      mode => 644,
      owner => root,
      group => root,
      require => File["${hadoop_conf_dir}"]
  }

  file {
    "${hadoop_conf_dir}/core-site.xml":
      source => "puppet:///modules/hadoop/core-site.xml",
      mode => 644,
      owner => root,
      group => root,
      require => File["${hadoop_conf_dir}"]
  }

  file {
    "${hadoop_conf_dir}/mapred-site.xml":
      source => "puppet:///modules/hadoop/mapred-site.xml",
      mode => 644,
      owner => root,
      group => root,
      require => File["${hadoop_conf_dir}"]
  }

  file {
    "${hadoop_conf_dir}/hdfs-site.xml":
      source => "puppet:///modules/hadoop/hdfs-site.xml",
      mode => 644,
      owner => root,
      group => root,
      require => File["${hadoop_conf_dir}"]
  }

  file {
    "${hadoop_conf_dir}/yarn-site.xml":
      source => "puppet:///modules/hadoop/yarn-site.xml",
      mode => 644,
      owner => root,
      group => root,
      require => File["${hadoop_conf_dir}"]
  }

  file {
    "${hadoop_conf_dir}/hadoop-env.sh":
      source => "puppet:///modules/hadoop/hadoop-env.sh",
      mode => 644,
      owner => root,
      group => root,
      require => File["${hadoop_conf_dir}"]
  }

  file {
    "${hadoop_conf_dir}/yarn-env.sh":
      source => "puppet:///modules/hadoop/yarn-env.sh",
      mode => 644,
      owner => root,
      group => root,
      require => File["${hadoop_conf_dir}"]
  }

  file { "/etc/profile.d/hadoop-path.sh":
    content => template("hadoop/hadoop-path.sh.erb"),
    owner => root,
    group => root,
  }
  group { "hadoop":
      ensure => "present",
  }
  user { "hdfs":
      ensure     => "present",
      managehome => "true",
      groups => "hadoop"
  }
  user { "yarn":
      ensure  => "present",
      managehome => "true",
      groups => "hadoop"
  }
  user { "mapred":
      ensure  => "present",
      managehome => "true",
      groups => "hadoop"
  }
}
