# OPNsense

OPNsense disables the WebUI on the WAN port by default, and wants access through the "LAN".

Use libvirt passthrough to passthrough the second NIC of a 2port box and wire up the second NIC for connectivity through another host on the network if possible so after installation management comes in via that interface. OPNsense allows VLAN tag creation on LAN inteface as part of installation configuration.

```
# virsh nodedev-list --tree | grep -B2 enp1s0f0
  |   +- pci_0000_01_00_0
  |   |   |
  |   |   +- net_enp1s0f0_90_5a_08_33_bc_82
  ```
  
  ```
# file /sys/firmware/efi/
/sys/firmware/efi/: directory
```

```
# lsblk 
NAME    MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
loop0     7:0    0   1.7G  1 loop /run/rootfsbase
nvme1n1 259:0    0 894.3G  0 disk /mnt
nvme0n1 259:1    0 894.3G  0 disk
```

```
virt-install \
    --graphics vnc,password=foobar,listen=0.0.0.0 \
    --memory 8192 \
    --vcpus 4 \
    --name opnsense1 \
    --sound none \
    --os-variant freebsd14.2 \
    --autoconsole none \
    --network network=default \
	  --disk /dev/nvme0n1 \
	  --cdrom /mnt/OPNsense-26.1.2-dvd-amd64.iso \
		--host-device=pci_0000_01_00_0 \
    --machine q35 \
    --boot uefi,firmware.feature0.name=secure-boot,firmware.feature0.enabled=no
 ```
