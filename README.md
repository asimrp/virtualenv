# Create a virtual dev server for greenplum

Ansible and serverspec for my ubuntu based dev server for Greenplum. It provides
the basic packages needed to work on the Greenplum code as well as specific user
preferences.

Should possibly be extended to other OS's later.

You should be able to run this from OS X.
Requires or has been tested with:

	* Vagrant 2.2.2
	* ansible 2.7.5
	* virtualbox 6.0

Once the machine is up and running, you should be able to connect via:

	ssh <ipv4> -l <user> -A

Information regarding <ipv4> will be printed on the stdout via ansible, example:

	"Access your user on 172.16.254.1"

Alternatively you can request the information from the remote via ansible,
example:

	ansible  -i  <path>/vagrant_ansible_inventory -m setup -a 'filter=ansible_all_*addresses' <box_name>

# Vagrantfile

The initial Vagrantfile has been taken via:
	
	vagrant init ubuntu/bionic64

And then slightly modified to mount shared folders set up and provision via
ansible.

Use via:
	
	vagrant up - to start your vm
	vagrant halt - to halt
	vagrant provision - to apply ansible changes if needed

When making changes to Vagrantfile, validate before applying them:
	
	vagrant validate vagrant reload --provision

## Shared folders

To add or update shared folders use:
    
	config.vm.synced_folder
in Vagrantfile

## Disksise

The /home directory on the host has been resized to 80Gb using a vagrant
pluggin. If you don't require to resize you can remove the relevant line from
the Vagrantfile. Otherwise you have to install vagrant-disksize.

	vagrant plugin install vagrant-disksize

# Ansible

If changes are made, then reprovision

	vagrant provision

## Roles

Ansible has been split into:
	
	- vmsetup:
		Contains the packages that need to be installed
	- develop:
		Contains user info

You can add your user on `roles/develop/defaults/main.yml` and then populate
`roles/develop/files/<user>/` with your desired files. Additional required
packages for your environment should be added in the `develop` role main tasks.

