#!/usr/bin/env bash

. /etc/profile

export HISTORY_SERVER_USER=mapred

# No idea, why this is needed...
su - $HISTORY_SERVER_USER -c "hadoop fs -chmod 777 /tmp"
su - $HISTORY_SERVER_USER -c "hadoop fs -chmod 777 /tmp/hadoop-yarn"
su - $HISTORY_SERVER_USER -c "hadoop fs -chmod 777 /tmp/hadoop-yarn/staging"
