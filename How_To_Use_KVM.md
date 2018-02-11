# Install KVM  

	apt-get install qemu-kvm libvirt-bin virtinst bridge-utils
	
> add bridging network card **br0**  

	auto eth0
	iface eth0 inet manual

	auto br0
	iface br0 inet static
	address 172.17.0.100
	netmask 255.255.0.0
	gateway 172.17.0.1
	bridge_ports eth0
	bridge_stp off
	bridge_fd 0
	bridge_maxwait 0

> enable ip forward

	/etc/sysctl.conf:
	net.ipv4.ip_forward = 1
	
	sudo sysctl -p /etc/sysctl.conf
	
	sudo reboot

# Install OS  

	virt-install --name trusty1404 --hvm --ram 1024 --vcpus 1 --disk path=/virt/disks/trusty1404.img,format=qcow2,size=10 \  
	--network network:default --accelerate --graphics vnc,listen=0.0.0.0,port=5911 \  
	--cdrom /virt/images/ubuntu-14.04.2-server-amd64.iso -d  

> use bridge network  

	virt-install --name trusty1404 --hvm --ram 1024 --vcpus 1 --disk path=/virt/disks/trusty1404.img,format=qcow2,size=10 \  
	--network bridge:br0 --accelerate --graphics vnc,listen=0.0.0.0,port=5911 \  
	--cdrom /virt/images/ubuntu-14.04.2-server-amd64.iso -d  

> install windows 10

	virt-install --name windows-10 --hvm --ram 32768 --vcpus 8 --os-type=windows --os-variant=win8.1 \
	--disk path=/virt/disks/windows-10.img,format=qcow2,size=200 --network bridge:br0 --accelerate \
	--graphics vnc,listen=0.0.0.0,port=5911 --cdrom /virt/images/Win10_1709_Chinese\(Simplified\)_x64.iso -d

> processor affinities

	apt-get install numactl
	numactl -H
	numastat
	numastat -c qemu-system-x86
	virsh emulatorpin trusty1404
	
> cpu tuning

	virsh edit trusty1404

	<cputune>
		<vcpupin vcpu="0" cpuset="1-4,^2"/>
		<vcpupin vcpu="1" cpuset="0,1"/>
		<vcpupin vcpu="2" cpuset="2,3"/>
	</cputune>
	
	virsh vcpuinfo trusty1404

# Domain XML format

[https://libvirt.org/formatdomain.html](https://libvirt.org/formatdomain.html)  

# Destroy Virtual Machine  
  
	virsh shutdown trusty1404 # Optional  
	virsh destroy trusty1404  
	virsh undefine trusty1404  
	virsh vol-delete --pool master_pool trusty1404.img

# Clone Virtual Machine  
  
	virt-clone --original=trusty1404 --name=clone0 --file=/virt/disks/clone0.img

# Offline migrating KVM guests

	scp /virt/disks/trusty1404.img ubuntu:1.2.3.4:/virt/disks
	virsh dumpxml trusty1404 > trusty1404.xml
	scp trusty1404.xml ubuntu:1.2.3.4:/home/ubuntu
	
> log in to 1.2.3.4

	virsh define trusty1404.xml

# Operate Pool   

> create pool (https://serverfault.com/questions/840519/how-to-change-the-default-storage-pool-from-libvirt/840520)  

	virsh pool-define-as --name master_pool --type dir --target /virt/disks  
	virsh pool-autostart master_pool  

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
