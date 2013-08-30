# Vagrant hadoop 2 cluster quick start

    $ vagrant box add cascading-hadoop-base http://files.vagrantup.com/precise64.box
    $ vagrant up
    
    $ vagrant ssh master
    $ (master) sudo prepare-cluster.sh
    $ (master) sudo start-all.sh
    $ (master) sudo fix-permissions.sh

The namenode is here: http://master.local:50070/dfshealth.jsp

The new job-tracker thing is here: http://master.local:8088/cluster/

and the job history server is here: http://master.local:19888/jobhistory/

To shut it all down:

   $ vagrant ssh master
   $ (master) sudo stop-all.sh
   $ vagrant halt


