!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

Please ignore this README for now. Read the README-hadoop2.md instead.

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


# Vagrant + Cascading + Hadoop Cluster

Clone this project to create a 4 node [Apache Hadoop](http://hadoop.apache.org) 
cluster with the [Cascading SDK](http://www.cascading.org/sdk/) pre-installed.

The Cascading 2.2 SDK includes Cascading and many of its sub-projects:

* [Lingual](http://www.cascading.org/lingual/) - ANSI SQL Command Shell and JDBC Driver
* [Pattern](http://www.cascading.org/pattern/) - Machine Learning
* [Cascalog](http://cascalog.org) - Clojure DSL over Cascding
* [Scalding](https://github.com/twitter/scalding) - Scala DSL over Cascading
* [Multitool](http://www.cascading.org/multitool/) - Command line tool for managing large files
* [Load](http://www.cascading.org/load/) - Command line tool for load testing Hadoop

To make getting started as easy as possible does this setup include build
tools used by parts of the SDK:

* [gradle](http://www.gradle.org/) - build tool used by Cascading and its
  related projects
* [leiningen 2](http://leiningen.org/) - a popular build tool in the clojure
  community, which is used in the [cascalog](http://cascalog.org/) tutorial
  included in the SDK
* [sbt](http://www.scala-sbt.org/) - a popular build tool in the scala community, which is
  used in the [scalding](https://github.com/twitter/scalding/wiki) tutorial included in the SDK

This work is based on:
http://cscarioni.blogspot.co.uk/2012/09/setting-up-hadoop-virtual-cluster-with.html

## Deploying the cluster

First install both [Virtual Box](http://virtualbox.org) and
[Vagrant](http://vagrantup.com/) for your platform. 

Then simply clone this repository, change into the new cloned directory, and run
the following:

    $ vagrant box add cascading-hadoop-base http://files.vagrantup.com/precise64.box
    $ vagrant up

This will set up 4 machines - `master`, `hadoop1`, `hadoop2` and `hadoop3`. Each 
of them will have two CPUs and .5GB of RAM. If this is too much for your machine, 
adjust the `Vagrantfile`.

The machines will be deployed using [Puppet](http://puppetlabs.com/). All of them
will have hadoop (apache-hadoop-1.2.1) installed, ssh will be configured and
local name resolution also works. 

Hadoop is installed in `/opt/hadoop-1.2.1` and all tools are in the `PATH`.

The `master` machine acts as the namenode and jobtracker, the 3 others are data
nodes and task trackers.

### Starting the cluster

This cluster uses the `ssh-into-all-the-boxes-and-start-things-up`-approach,
which is fine for testing. Also for simplicity, everything is running as `root`
(patches welcome).

Once all machines are up and provisioned, the cluster can be started. Log into
the master, format hdfs and start the cluster.

     $ vagrant ssh master
     $ (master) sudo hadoop namenode -format
     $ (master) sudo start-all.sh

After a little while, all daemons will be running and you have a fully working
hadoop cluster.

### Stopping the cluster

If you want to shut down your cluster, but want to keep it around for later
use, shut down all the services and tell vagrant to stop the machines like this:

     $ vagrant ssh master
     $ (master) sudo stop-all.sh
     $ exit or Ctrl-D
     $ vagrant halt

When you want to use your cluster again, simply do this:

     $ vagrant up
     $ vagrant ssh master
     $ (master) sudo start-all.sh


### Getting rid of the cluster

If you don't need the cluster anymore and want to get your disk-space back do
this:

     $ vagrant destroy

This will only delete the VMs all local files in the directory stay untouched
and can be used again, if you decide to start up a new cluster.
     

## Interacting with the cluster

### Webinterface

The namenode webinterface is available under http://master.local:50070/dfshealth.jsp and the
jobtracker is available under http://master.local:50030/jobtracker.jsp

The cluster uses [zeroconf](http://en.wikipedia.org/wiki/Zero-configuration_networking) 
(a.k.a. bonjour) for name resolution. This means, that
you never have to remember any IP nor will you have to fiddle with your
`/etc/hosts` file.

Name resolution works from the host to all VMs and between all VMs as well.  If
you are using linux, make sure you have `avahi-daemon` installed and it is
running. On a Mac everything should just work (TM) witouth doing anything. 
(Windows testers and patches welcome).

The network used is `192.168.7.0/24`. If that causes any problems, change the
`Vagrantfile` and `modules/avahi/file/hosts` files to something that works for
you. Since everything else is name based, no other change is required.

### Command line

To interact with the cluster on the command line, log into the master and
use the hadoop command as `root`(again, patches welcome).

    $ vagrant ssh master
    $ (master) sudo -i
    $ (master) hadoop fs -ls /
    $ ...

You can access the host file system from `/vagrant`, which means you can drop
your hadoop job in there and run it on your own fully distributed hadoop
cluster.

## Performance

Since this is a fully virtualized environment running on your computer, it will
not be super-fast. This is not the goal of this setup. The goal is to have a fully
distributed cluster for testing and troubleshooting. 

To not overload the host machine, has each tasktracker a hard limit of 1 map task
and 1 reduce task at a time. 


## Cascading SDK

The project supports deploying the [Cascading SDK](http://cascading.org/sdk) on
the cluster as well.  Puppet will download the Cascading SDK 2.2-wip and put all SDK
tools into the `PATH`. The SDK itself can be found in `/opt/CascadingSDK`.

## Hacking & Troubleshooting

### Storage locations

The namenode stores the `fsimage` in `/srv/hadoop/namenode`. The datanodes  are
storing all data in `/srv/hadoop/datanode`.

### Puppet

If you change any of the puppet modules, you can simply apply the changes with
vagrants built-in provisioner.

    $ vagrant provision

### Hadoop download

In order to save bandwidth and time we try to download hadoop only once and
store it in the `/vagrant` directory, so that the other vms can reuse it. If the
download fails for some reason, delete the tarball and rerun `vagrant
provision`.

## Wishlist

- have it working on windows
- run as other user than root
- have a way to configure the names/ips in only one file
- have a way to define the hadoop version globally
