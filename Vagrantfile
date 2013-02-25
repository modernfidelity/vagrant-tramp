#
# CUSTOM VAGRANTFILE FOR USE WITH VAGRANT SYSTEM (+VIRTUALBOX)
# 
# This will generate a standard web production environment, consisting of a 
# load balancer (NGINX + VARNISH), 2x web server (APACHE+PHP+MEMCACHE) and a database (MYSQL). 
#
# Dependencies -> Vagrant, Virtualbox and Ruby. 
#                 Internet connection is also required for the specifc updates calls
#
#

Vagrant::Config.run do |config|


  # LOAD BALANCER
  # --------------------------------------

  config.vm.define :lb do |config|
    
    config.vm.box = "lucid64"
    config.vm.box_url = "http://files.vagrantup.com/lucid64.box"
    
    config.vm.host_name = "lb.local"
    config.vm.network :hostonly, "33.33.33.30"
    config.vm.forward_port(80,3030)

    config.vm.customize ["modifyvm", :id, "--memory", 128]
    
    

    # Set the Timezone to something useful
    # config.vm.provision :shell, :inline => "echo \"Europe/London\" | sudo tee /etc/timezone && dpkg-reconfigure --frontend noninteractive tzdata"
    
    # Update the server
    config.vm.provision :shell, :inline => "apt-get update --fix-missing"

   
    config.vm.provision :puppet, :module_path => "puppet/modules" do |puppet|
      puppet.manifests_path = "puppet/manifests"
      puppet.manifest_file = "lb.pp"
    end

  end


  # WEB SERVER (1)
  # --------------------------------------

  config.vm.define :web1 do |config|
    
    config.vm.box = "lucid64"
    config.vm.box_url = "http://files.vagrantup.com/lucid64.box"
    
    config.vm.host_name = "web1.local"
    config.vm.network :hostonly, "33.33.33.31"
    config.vm.forward_port(80,3031)

    config.vm.customize ["modifyvm", :id, "--memory", 256]

    # Set the Timezone to something useful
    # config.vm.provision :shell, :inline => "echo \"Europe/London\" | sudo tee /etc/timezone && dpkg-reconfigure --frontend noninteractive tzdata"
    
    # Update the server
    config.vm.provision :shell, :inline => "apt-get update --fix-missing"

    #config.vm.share_folder("v-root", "/vagrant/www", ".", :nfs => true)
      
    config.vm.provision :puppet, :module_path => "puppet/modules" do |puppet|
      puppet.manifests_path = "puppet/manifests"
      puppet.manifest_file = "web.pp"
    end

  end


  # WEB SERVER (2)
  # --------------------------------------

  config.vm.define :web2 do |config|
    
    config.vm.box = "lucid64"
    config.vm.box_url = "http://files.vagrantup.com/lucid64.box"
    
    config.vm.host_name = "web2.local"
    config.vm.network :hostonly, "33.33.33.32"
    config.vm.forward_port(80,3032)

    config.vm.customize ["modifyvm", :id, "--memory", 256]  
    

    # Set the Timezone to something useful
    # config.vm.provision :shell, :inline => "echo \"Europe/London\" | sudo tee /etc/timezone && dpkg-reconfigure --frontend noninteractive tzdata"
    
    # Update the server
    config.vm.provision :shell, :inline => "apt-get update --fix-missing"

   
    config.vm.provision :puppet, :module_path => "puppet/modules" do |puppet|
      puppet.manifests_path = "puppet/manifests"
      puppet.manifest_file = "web.pp"
    end

  end

  
  # DATABASE SERVER
  # --------------------------------------

  config.vm.define :db do |config|
    
    config.vm.box = "lucid64"
    config.vm.box_url = "http://files.vagrantup.com/lucid64.box"
    
    config.vm.host_name = "db.local"
    config.vm.network :hostonly, "33.33.33.33"
    config.vm.forward_port(3306,3033)

    config.vm.customize ["modifyvm", :id, "--memory", 256]


    # Set the Timezone to something useful
    # config.vm.provision :shell, :inline => "echo \"Europe/London\" | sudo tee /etc/timezone && dpkg-reconfigure --frontend noninteractive tzdata"
    
    # Update the server
    # config.vm.provision :shell, :inline => "apt-get update --fix-missing"

   
    config.vm.provision :puppet, :module_path => "puppet/modules" do |puppet|
      puppet.manifests_path = "puppet/manifests"
      puppet.manifest_file = "db.pp"
    end

  end


end