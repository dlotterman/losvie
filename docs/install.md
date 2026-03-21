# Install the Bare Metal Operating System via install environment VM

6. The Operator uploads / downloads their install artifacts (`.iso`) to the "Bare Metal Server" running in live mode.
 - `/var/tmp/` has 16G free by default if the "Bare Metal" has sufficient RAM
 - You can also format a free drive to use as a staging ground and mount it, seen here often as `/mnt/`

7. Operator identifies the hardware device(s) they would like to passthrough:

In this case, the Operator wants to find the NIC that is currently NOT in use by the server, which is using one of its NICs to boot into losvie. By passing through a second / unused NIC, you can trick installers into seeing the hardware and installing the approriate drivers. You can also do this with any other "boot" required hardware.

* Note this isnt always needed. Often very common drivers will get installed by default, heavily depends on the OS.

```
root@localhost-live:~# virsh nodedev-list --tree | grep -B2 enp1s0f0
  |   +- pci_0000_01_00_0
  |   |   |
  |   |   +- net_enp1s0f0_90_5a_08_31_13_18
```

4. Determine chassis BIOS / UEFI state (directory existence instance EFI):

EFI:
```
# file /sys/firmware/efi/
/sys/firmware/efi/: directory
```

BIOS:
```
# file /sys/firmware/efi/
/sys/firmware/efi/: cannot open `/sys/firmware/efi/' (No such file or directory)
```

5. Identify OS boot disk:
```
# lsblk 
NAME    MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
loop0     7:0    0   1.7G  1 loop /run/rootfsbase
sda       8:0    0 447.1G  0 disk 
sdb       8:16   0 447.1G  0 disk 
nvme1n1 259:0    0   1.7T  0 disk /mnt
nvme0n1 259:1    0   1.7T  0 disk 
```

5. Operator begins OS installation:

UEFI:
```
virt-install \
    --graphics vnc,password=foobar,listen=0.0.0.0 \
    --memory 8192 \
    --vcpus 4 \
    --name W2k5 \
    --sound none \
    --os-variant win2k25 \
    --virt-type kvm \
    --autoconsole none \
    --network network=default,model=rtl8139 \
	  --disk /dev/sda \
	  --cdrom /mnt/26100.1742.240906-0331.ge_release_svc_refresh_SERVER_EVAL_x64FRE_en-us.iso \
    --machine q35 \
    --boot uefi
 ```
 
 BIOS
```
virt-install \
  --cpu host-passthrough,cache.mode=passthrough \
  --graphics vnc,password=foobar,listen=0.0.0.0 \
  --memory 12288 \
  --name nutanixce0 \
  --sound none \
  --os-variant linux2022 \
  --virt-type kvm \
  --autoconsole none \
  --network none \
  --cdrom /var/tmp/phoenix.x86_64-fnd_5.6.1_patch-aos_6.8.1_ga.iso \
  --machine q35 \
  --sysinfo host \
  --features apic.eoi=on,smm.state=on \
  --check disk_size=off \
	--disk /dev/sda,bus=scsi \
	--disk /dev/nvme0n1,bus=scsi \
	--disk /dev/nvme1n1,bus=scsi \
	--host-device=pci_0000_01_00_1 \
  --live \
  --boot cdrom
```
    
* Note, the `rtl8139` flag should only be needed for Windows, and is a paranoia choice by the author
 
 6. When OS installation is complete, installer will likely poweroff the install VM, Operator has two choices:
   - Is OS is ready to take over the Bare Metal host? If reboot the host from LiveOS state and it will reboot into the local disk
   - If further OS configuration is required (enabling services, modifying network configuration), start the VM again and make needed changes before poweroff of VM and rebooting the LiveOS host, which again should reboot into the host bootdisk.
