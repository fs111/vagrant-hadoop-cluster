#!/usr/bin/env bash

. /etc/profile

export HDFS_USER=hdfs
export YARN_USER=yarn
export HISTORY_SERVER_USER=mapred

su - $HDFS_USER -c "$HADOOP_PREFIX/bin/hdfs namenode -format"

# No idea, why this is needed...
su - $HISTORY_SERVER_USER -c "hadoop fs -chmod 777 /tmp"
su - $HISTORY_SERVER_USER -c "hadoop fs -chmod 777 /tmp/hadoop-yarn"
su - $HISTORY_SERVER_USER -c "hadoop fs -chmod 777 /tmp/hadoop-yarn/staging"
