# Install KVM  

	apt-get install qemu-kvm libvirt-bin virtinst bridge-utils

# Install OS  

	virt-install --name trusty1404 --hvm --ram 1024 --vcpus 1 --disk path=/virt/disks/trusty1404.img,format=qcow2,size=10 \  
	--network network:default --accelerate --graphics vnc,listen=0.0.0.0,port=5911 \  
	--cdrom /virt/images/ubuntu-14.04.2-server-amd64.iso -d  

> use bridge network  

	virt-install --name trusty1404 --hvm --ram 1024 --vcpus 1 --disk path=/virt/disks/trusty1404.img,format=qcow2,size=10 \  
	--network bridge:br0 --accelerate --graphics vnc,listen=0.0.0.0,port=5911 \  
	--cdrom /virt/images/ubuntu-14.04.2-server-amd64.iso -d  

# Destroy Virtual Machine  
  
	virsh shutdown trusty1404 # Optional  
	virsh destroy trusty1404  
	virsh undefine trusty1404  

# Clone Virtual Machine  
  
	virt-clone --original=trusty1404 --name=clone0 --file=/virt/disks/clone0.img

# Operate Pool   

> create pool  

	virsh pool-create-as --name master_pool --type dir --target /virt/disks  

> view pool info    

	virsh pool-info master_pool  

> start pool  

	virsh pool-start master_pool  

> list pool  

	virsh pool-list  

# Operate Snapshot  

> create snapshot  

	virsh snapshot-create-as trusty1404 snapshot1  

> revert snapshot  

	virsh snapshot-revert trusty1404 snapshot1  

# Configure Bridged Network

> /etc/network/interface

	auto eth0
	iface eth0 inet manual

	auto br0
	iface br0 inet static
	address ...
	netmask ...
	gateway ...
	bridge_ports eth0
	bridge_stp off
	bridge_fd 0
	bridge_maxwait 0

	dns-nameservers ...

> then  

	reboot  
	brctl show  

# Random Mac Address
  
	echo $RANDOM | md5sum | sed 's/\(..\)/&:/g' | cut -c1-17

# Update Virtual Machine Config
  
	virsh edit trusty1404  

# Dump Virtual Machine Config  
  
	virsh dumpxml trusty1404 > /etc/libvirt/qemu/trusty1404-2.xml

# Resize disk space  

	virsh vol-resize your_volume_name.img 100G --pool master_pool  
	https://serverfault.com/questions/324281/how-do-you-increase-a-kvm-guests-disk-space  

# Mount CD-ROM  

	virsh attach-disk trusty1404 /your/path/xxx.iso hdc --type cdrom --mode readonly  

> then  

	virsh attach-disk trusty1404 "" hdc --type cdrom --mode readonly  
	
# Static IP Address

https://serverfault.com/questions/627238/kvm-libvirt-how-to-configure-static-guest-ip-addresses-on-the-virtualisation-ho

# NAT Forward Port

https://stackoverflow.com/questions/13772653/kvm-on-ubuntu-port-forwarding-to-a-guest-vm
