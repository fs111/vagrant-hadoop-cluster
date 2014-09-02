include base

class{ 'hadoop':
  slaves_file => "puppet:///modules/hadoop/slaves-single",
  hdfs_site_file => "puppet:///modules/hadoop/hdfs-site-single.xml"
}

#include hbase
include avahi
#include cascading
include tezdev
