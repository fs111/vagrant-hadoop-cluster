class spark() {
  $spark_version = "1.6.3"
  $spark_variant = "bin-hadoop2.6"
  $spark_home = "/opt/spark-${spark_version}-${spark_variant}"
  $spark_tarball = "spark-${spark_version}-${spark_variant}.tgz"

  exec { "download_spark":
    command => "/tmp/grrr /spark/spark-${spark_version}/spark-${spark_version}-${spark_variant}.tgz -O /vagrant/${spark_tarball} --read-timeout=5 --tries=0",
    timeout => 1800,
    path => $path,
    creates => "/vagrant/$spark_tarball",
    require => [ Package["openjdk-8-jdk-headless"], Exec["download_grrr"]]
  }

  exec { "unpack_spark" :
    command => "tar xf /vagrant/${spark_tarball} -C /opt",
    path => $path,
    creates => "${spark_home}",
    require => Exec["download_spark"]
  }

  file { "/etc/profile.d/spark-path.sh":
    content => template("spark/spark-path.sh.erb"),
    owner => ubuntu,
    group => root,
  }

}
