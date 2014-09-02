class tezdev{
 
  file { ["/opt/tools/", "/opt/tools/bin"]:
        ensure => "directory"
  }

  exec { "download_maven":
    command => "/tmp/grrr maven/maven-3/3.2.3/binaries/apache-maven-3.2.3-bin.tar.gz -O /tmp/maven.tgz",
    timeout => 1800,
    path => $path,
    creates => "/tmp/maven.tgz",
    require => [ Package["openjdk-7-jdk"], Exec["download_grrr"] ]
  }

  exec { "unpack_maven" :
    command => "tar xf /tmp/maven.tgz -C /opt/tools",
    path => $path,
    require => [ Exec["download_maven"], File["/opt/tools"] ],
    unless => "ls /opt/tools/ | grep maven",
  }

  package { [ "vim", "git", "protobuf-compiler" ]:
    ensure => "installed",
    require => Exec['apt-get update']
  }

  file { "/etc/profile.d/maven.sh":
    source => "puppet:///modules/tezdev/maven.sh",
    owner => root,
    group => root,
  }

  file { "/opt/tools/bin/tez" :
    source => "puppet:///modules/tezdev/tez",
    owner => vagrant,
    group => root,
    mode => 755,
    require => File["/opt/tools/bin"]
  }
}
