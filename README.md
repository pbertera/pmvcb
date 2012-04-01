Poor man VMware consolidated Backup
===================================

VMware offers a backup system for virtual machines: VCB (VMware consolidated Backup): http://www.vmware.com/products/vi/cb_overview.htm

When the VCB run it:

* execute a snapshot of VM
* clone virtual machine disks
* consolidates the snapshot (snapshot removing)

The advantages of this backup system are:

* full backup of a virtual machine
* no downtime
* the filesystem should be consistent

The disadvantages are:

* full backup of a virtual machine (read: no incremental or differential)
* is snapshot dependent (no RDM or indipendent devices)

Basically VCB is a good sistem for disaster recovery (whether the restrictions imposed by the use of snapshots ad not too restrictive).

With a lot of bash line is possible to implement a similar system by automating the snapshot, cloning and consolitation operations.

Lo script in questione è pmvcb: pmvcb esegue le operazioni sopra elencate su un host ESXi.
This is the goal of pvcb script.

Below the help of pvcb:

    Usage: ./pmvcb -v [VM] -d [DIR] -h [host] <options>
    
    options:
    	-v <vm>		Virtual machine to backup [*]
	-d <dir>	Remote directory to store backup [*]
	-h <host>	ESXi host [*]
	-u <user>	ESXi username (default: root)
	-f <opts>	vmkfstool optons (default: "-a lsilogic -d zeroedthick")
	-o		overwrite existent backups
	-q		use quiesce snapshot
	-s <opts>	ssh options (default: "-i /var/lib/bacula/.ssh/id_rsa")
	-L <cmd>	local command executed after backup of virtual disks, this command is executed on local machine
	-R <cmd>	remote command executed on ESXi host after local command execution
	-t <timeout>	snapshot creation timeout in minutes. (default 10)
	-U		use the snapshot_id syntax in snapshot.remove (default NO)
	

    [*] required options

The required options are: the name of VM to do backing-up (-v), the directory where pvcb store the cloned disks (-d) and the ESXi host (-h).
With -f option you can specify more options to vmkfstools command (the comamnd used by ESXi for cloning disks), with -q option you can use quiescent snapshot.
With -s option you can specify more options for ssh (for example using a RSA key).
-L and -R run commands on localhost and remote ESXi host. -t defines the timeout for snapshot creation. -U supports the snapshot_id in snapshot.remove.

**pmvcb deals with:**

1. verify that the virtual machine not have RDM or indipendent disks
2. verify that there are not snapshot in progress
3. executing the snapshot
4. disk cloning and copy .vmx file of virtual machine in the direcotry specified by -d option
5. consolidate the snapshot
6. executing command specified by -L option locally
7. executing command specified by -R option remotely

**really recommended to use rsa authentication with ssh (http://plone.lucidsolutions.co.nz/linux/vmware/esxi/enabling-ssh-with-public-key-authentication-on-vmware-esxi-4)**

**this script is tested on ESXi 4.0 / 4.1**
