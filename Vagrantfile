# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("1") do |config|
  config.vm.box = "cascading-hadoop-base"

  config.vm.define :hadoop1 do |hadoop1_config|
    hadoop1_config.vm.network :hostonly, "192.168.7.12"
    hadoop1_config.vm.host_name = "hadoop1.local"
    hadoop1_config.vm.provision :puppet do |hadoop1_puppet|
      hadoop1_puppet.manifest_file = "datanode.pp"
      hadoop1_puppet.manifests_path = "manifests"
      hadoop1_puppet.module_path = "modules"
    end
  end
  
  config.vm.define :hadoop2 do |hadoop2_config|
    hadoop2_config.vm.network :hostonly, "192.168.7.13"
    hadoop2_config.vm.host_name = "hadoop2.local"
    hadoop2_config.vm.provision :puppet do |hadoop2_puppet|
      hadoop2_puppet.manifest_file = "datanode.pp"
      hadoop2_puppet.manifests_path = "manifests"
      hadoop2_puppet.module_path = "modules"
    end
  end
  
  config.vm.define :hadoop3 do |hadoop3_config|
    hadoop3_config.vm.network :hostonly, "192.168.7.14"
    hadoop3_config.vm.host_name = "hadoop3.local"
    hadoop3_config.vm.provision :puppet do |hadoop3_puppet|
      hadoop3_puppet.manifest_file = "datanode.pp"
      hadoop3_puppet.manifests_path = "manifests"
      hadoop3_puppet.module_path = "modules"
    end
  end
  
   config.vm.define :master do |master_config|
    master_config.vm.network :hostonly, "192.168.7.10"
    master_config.vm.host_name = "master.local"
    master_config.vm.provision :puppet do |master_puppet|
      master_puppet.manifest_file = "master.pp"
      master_puppet.manifests_path = "manifests"
      master_puppet.module_path = "modules"
    end
  end

end

Vagrant.configure("2") do |config|
    config.vm.provider :virtualbox do |vb|
        vb.customize ["modifyvm", :id, "--memory", "512"]
    end
end
