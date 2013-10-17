# Vagrant hadoop 2 cluster

This is experimental, you have been warned. 

This vagrant hadoop setup is based on [hadoop
2.2.0](http://hadoop.apache.org/docs/r2.2.0/hadoop-project-dist/hadoop-common/releasenotes.html)

Hadoop itself is installed in `/opt/hadoop-2.2.0`.

## Getting started

To start and provision the VMs in the cluster, do this:

    $ vagrant box add cascading-hadoop-base http://files.vagrantup.com/precise64.box
    $ vagrant up
    
To start the various services in the cluster, do this:

    $ vagrant ssh master
    $ (master) sudo prepare-cluster.sh
    $ (master) sudo start-all.sh

* `prepare-cluster.sh` formats the namenode
* `start-all.sh` starts all services (local and remote) in the right oder as the
 right user. 

For some reason, the dfs is no longer creating the "home" directory of a user. You will
have to create that yourself with `hadoop fs -mkdir -p /user/vagrant`.

You can test the cluster by running the example apps: 
    hadoop jar /opt/hadoop-2.2.0/share/hadoop/mapreduce/hadoop-mapreduce-examples-2.2.0.jar

## Webinterfaces of the services

* The namenode is here: http://master.local:50070/dfshealth.jsp
* The new job-tracker thing is here: http://master.local:8088/cluster/
* The job history server is here: http://master.local:19888/jobhistory/


## Turning it off

To shut it all down:

    $ vagrant ssh master
    $ (master) sudo stop-all.sh
    $ vagrant halt or vagrant destroy -f

# Quickly resetting the cluster

The vagrant setup is based on puppet and you can rebuild the machines any time.
However this is a bit time consuming, so there is a faster way to reset your
cluster:

    $ vagrant ssh master
    $ (master) sudo stop-all.sh
    $ ^D
    $ for host in master hadoop1 hadoop2 hadoop3; do vagrant ssh $host --command 'sudo rm -rf /srv/hadoop' ; done
    $ vagrant provision

This shuts down all services, deletes the `/srv/hadoop` directory on all nodes
(where all data is kept) and re-creates all missing directories via puppet.


# Differences to the hadoop 1 version

In this version the services are no longer running as root, but as different
users. Everything that is related to `HDFS` (namenode, datanodes) runs as the user
`hdfs`. Everything related to `YARN` runs as the user `yarn`. The job history
server runs as the user `mapred`. All users are managed by puppet.

Hadoop no longer ships with the `start-all.sh` and `stop-all.sh` scripts, so
the one in this project are our effort, to make starting and stopping of hadoop
easier.

The Cascading SDK is currently not part of this setup.

# Open JIRA issues related to this

* https://issues.apache.org/jira/browse/HADOOP-9904
* https://issues.apache.org/jira/browse/HADOOP-9923
* https://issues.apache.org/jira/browse/HADOOP-9911
* <del>https://issues.apache.org/jira/browse/HADOOP-9910</del>

# Further reading

More info on how to run a hadoop 2 cluster, can be found at
[apache](http://hadoop.apache.org/docs/r2.2.0/hadoop-project-dist/hadoop-common/ClusterSetup.html).
