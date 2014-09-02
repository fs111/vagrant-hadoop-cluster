This cluster uses hadoop 2.4.0 and tez 0.5.0.

To bring up the cluster and install tez do this:

boot the cluster:

    vagrant up

start hadoop:

    vagrant ssh master
    sudo prepare-cluster.sh
    sudo start-all.sh

compile and deploy tez:

    tez deploy

`tez` is a script in `/opt/tools/bin` which will checkout tez 0.5.0 from git into `/vagrant/tez`, compile it with maven
(installed in `/opt/tools/apache-maven-3.2.3/bin/mvn`) and copy it onto HDFS in `/apps/tez-0.5.0`. Note that `/vagrant`
is the checkout directory of the cluster, so you can also compile tez on the host machine and simply run `tez upload` on
the cluster, if that is faster for you.

Now you should be read to go.

The cluster is already configured to use tez. You can cofirm that it works like so:

    hadoop jar /opt/hadoop-2.4.0/share/hadoop/mapreduce/hadoop-mapreduce-client-jobclient-2.4.0-tests.jar sleep -mt 1 -rt 1 -m 1 -r 1
