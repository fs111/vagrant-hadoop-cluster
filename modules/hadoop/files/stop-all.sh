#!/usr/bin/env bash

. /etc/profile

export HDFS_USER=hdfs
export YARN_USER=yarn
export HISTORY_SERVER_USER=mapred

su - $HISTORY_SERVER_USER -c "$HADOOP_PREFIX/sbin/mr-jobhistory-daemon.sh stop historyserver --config $HADOOP_CONF_DIR"

su - $YARN_USER -c "$HADOOP_YARN_HOME/sbin/yarn-daemon.sh stop proxyserver --config $HADOOP_CONF_DIR"

for slave in $(cat $HADOOP_CONF_DIR/slaves); do
  ssh $slave "su - $YARN_USER -c \"$HADOOP_YARN_HOME/sbin/yarn-daemon.sh --config $HADOOP_CONF_DIR stop nodemanager\""
done

su - $YARN_USER  -c "$HADOOP_YARN_HOME/sbin/yarn-daemon.sh --config $HADOOP_CONF_DIR stop resourcemanager"

for slave in $(cat $HADOOP_CONF_DIR/slaves); do
 ssh $slave "su - $HDFS_USER -c \"$HADOOP_PREFIX/sbin/hadoop-daemon.sh --config $HADOOP_CONF_DIR --script hdfs stop datanode\"";
done

su - $HDFS_USER -c "$HADOOP_PREFIX/sbin/hadoop-daemon.sh --config $HADOOP_CONF_DIR --script hdfs stop namenode"
