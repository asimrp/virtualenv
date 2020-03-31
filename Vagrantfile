# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
 config.vm.box = "bento/ubuntu-19.04"
  config.vm.hostname = "gpdb-ubuntu"

  # Create a private network, which allows host-only access to the machine
  config.vm.network "private_network", type: "dhcp"

  config.vm.provider "virtualbox" do |vb|
    vb.name = "gpdb-ubuntu-19-host"
    vb.memory = 16384
    vb.cpus = 4
    vb.customize ['modifyvm', :id, '--cableconnected1', 'on']
  end

  # Uncomment if you wish to share a folder between host and remote
  # assuming "/code" as location
  # config.vm.synced_folder ENV['HOME'] + "/code", "/code", mount_options: ["dmode=777"]

  # Adjust the disksize of the /home folder in the remote
  # requires vagrant-disksize ($ vagrant plugin install vagrant-disksize )
  # config.disksize.size = '80GB'

  # Provision via ansible
  config.vm.define "gpdb-ubuntu" do |gpdbtest|
    config.vm.provision "ansible" do |a|
      a.playbook = "provision.yml"
      #a.verbose = 'vvvv'
    end
  end

end
