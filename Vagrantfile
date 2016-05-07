# Using Vagrant version 2. No ifs or buts.
Vagrant.configure("2") do |config|
	# Number of nodes. On an i5 with 8Gb RAM I use 3.
	N = 1 

	# Iterate for nodes
	(1..N).each do |node_id|
		nid = (node_id - 1)
		
		# Define our node
		config.vm.define "vm#{nid}" do |n|
			n.vm.box = "debian/jessie64"
			n.vm.boot_timeout = 600
			n.vm.hostname = "dotfile#{nid}"
			n.vm.network "private_network", ip: "10.1.10.#{10 + nid}"

			n.vm.provider "virtualbox" do |vb|
				vb.name = "dotfile#{nid}"
				vb.memory = 512
			end

			# If this is our last node, lets provision all.
			if node_id == N
				n.vm.provision "ansible" do |a|
					a.limit = "all"
					a.verbose = "v"
					a.playbook = "provision.yml"
				end
			end
		end
	end
end
