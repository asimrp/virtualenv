# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
 config.vm.box = "bento/ubuntu-20.04"
  config.vm.hostname = "gpdb-ubuntu-20"

  # Create a private network, which allows host-only access to the machine
  config.vm.network "private_network", type: "dhcp"

  config.vm.provider "virtualbox" do |vb|
    vb.name = "gpdb-ubuntu-20-host"
    vb.memory = 8192
    vb.cpus = 3
    vb.customize ['modifyvm', :id, '--cableconnected1', 'on']
  end

  # Uncomment if you wish to share a folder between host and remote
  # assuming "/code" as location
  config.vm.synced_folder ENV['HOME'] + "/workspace", "/host-workspace", mount_options: ["dmode=777"]

  # Adjust the disksize of the /home folder in the remote
  # requires vagrant-disksize ($ vagrant plugin install vagrant-disksize )
  # config.disksize.size = '80GB'

  # Provision via ansible
  config.vm.define "gpdb-ubuntu-20" do |gpdbtest|
    config.vm.provision "ansible" do |a|
      a.playbook = "provision.yml"
      #a.verbose = 'vvvv'
    end
  end

end
