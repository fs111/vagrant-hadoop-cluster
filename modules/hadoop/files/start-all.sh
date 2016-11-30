#!/usr/bin/env bash

. /etc/profile

set +x

export HDFS_USER=hdfs
export YARN_USER=yarn
export HISTORY_SERVER_USER=mapred

su - $HDFS_USER -c "$HADOOP_PREFIX/sbin/hadoop-daemon.sh --config $HADOOP_CONF_DIR --script hdfs start namenode"

for slave in $(cat $HADOOP_CONF_DIR/slaves); do
 ssh $slave "su - $HDFS_USER -c \"$HADOOP_PREFIX/sbin/hadoop-daemon.sh --config $HADOOP_CONF_DIR --script hdfs start datanode\"";
done

su - $YARN_USER -c "$HADOOP_YARN_HOME/sbin/yarn-daemon.sh --config $HADOOP_CONF_DIR start resourcemanager"

for slave in $(cat $HADOOP_CONF_DIR/slaves); do
  ssh $slave "su - $YARN_USER -c \"$HADOOP_YARN_HOME/sbin/yarn-daemon.sh --config $HADOOP_CONF_DIR start nodemanager\""
done

# XXX is optional and it is totally unclear from the docs, that the correct
# config is, to get this running
su - $YARN_USER -c "$HADOOP_YARN_HOME/sbin/yarn-daemon.sh start proxyserver --config $HADOOP_CONF_DIR"

# give the namenode some time to come up
sleep 20
# work around https://issues.apache.org/jira/browse/HADOOP-9923
NEEDS_STAGING_DIR=$(hadoop fs -test -d /tmp/hadoop-yarn/staging > /dev/null 2>&1)
if $NEEDS_STAGING_DIR; then
    su - $YARN_USER -c "hadoop fs -mkdir -p /tmp/hadoop-yarn/staging/history/done"
    su - $YARN_USER -c "hadoop fs -chmod -R 777 /tmp/"
fi

su - $HISTORY_SERVER_USER -c "$HADOOP_PREFIX/sbin/mr-jobhistory-daemon.sh start historyserver --config $HADOOP_CONF_DIR"

su - ubuntu -c "$HADOOP_PREFIX/bin/hadoop fs -mkdir -p /user/ubuntu"
