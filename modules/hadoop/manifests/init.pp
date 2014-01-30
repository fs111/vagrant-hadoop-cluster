class hadoop {
  $hadoop_version = "1.2.1"
  $hadoop_home = "/opt/hadoop-${hadoop_version}"
  $hadoop_tarball = "hadoop-${hadoop_version}.tar.gz"
  $hadoop_tarball_checksums = "${hadoop_tarball}.mds"

  file { ["/srv/hadoop/",  "/srv/hadoop/namenode", "/srv/hadoop/datanode/"]:
    ensure => "directory"
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

  exec { "hadoop_conf_permissions" :
    command => "chown -R vagrant ${hadoop_home}/conf",
    path => $path,
    require => Exec["unpack_hadoop"]
  }

  file {
    "${hadoop_home}/conf/slaves":
      source => "puppet:///modules/hadoop/slaves",
      mode => 644,
      owner => vagrant,
      group => root,
      require => Exec["unpack_hadoop"]
  }

  file {
    "${hadoop_home}/conf/masters":
      source => "puppet:///modules/hadoop/masters",
      mode => 644,
      owner => vagrant,
      group => root,
      require => Exec["unpack_hadoop"]
  }

  file {
    "${hadoop_home}/conf/core-site.xml":
      source => "puppet:///modules/hadoop/core-site.xml",
      mode => 644,
      owner => vagrant,
      group => root,
      require => Exec["unpack_hadoop"]
  }

  file {
    "${hadoop_home}/conf/mapred-site.xml":
      source => "puppet:///modules/hadoop/mapred-site.xml",
      mode => 644,
      owner => vagrant,
      group => root,
      require => Exec["unpack_hadoop"]
  }

  file {
    "${hadoop_home}/conf/hdfs-site.xml":
      source => "puppet:///modules/hadoop/hdfs-site.xml",
      mode => 644,
      owner => vagrant,
      group => root,
      require => Exec["unpack_hadoop"]
  }

  file {
    "${hadoop_home}/conf/hadoop-env.sh":
      source => "puppet:///modules/hadoop/hadoop-env.sh",
      mode => 644,
      owner => vagrant,
      group => root,
      require => Exec["unpack_hadoop"]
  }

  file { "/etc/profile.d/hadoop-path.sh":
    content => template("hadoop/hadoop-path.sh.erb"),
    owner => root,
    group => root,
  }

}
