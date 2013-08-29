#!/usr/bin/env bash

. /etc/profile

export HDFS_USER=hdfs

su - $HDFS_USER -c "$HADOOP_PREFIX/bin/hdfs namenode -format"
