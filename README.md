# Losvie - "Live OS Virtual Install Environment"
## An OS provisiong environment for constrained Bare Metal deployments

**WIP**

losvie is a collection of widgets that provide a novel OS installation environment suited for "constrained" deploments like "Bare Metal Clouds" or "Edge Sites". 

losvie is three chapters of a story:

1. Build: Take an Enterprise Linux LiveOS ISO, unpackage it and repackage it with the contents of this repo
  - Then host those as losvie artifacts via HTTP
2. Boot: Boot a computer into the *losvie* LiveOS via those hosted artifacts, leaving its hardware (e.g boot disk) as available
3. Install: Use a [libvirt](https://libvirt.org/) VM as a sort of "outside-in" OOB, providing the CD-ROM, KVM and hardware passthrough to the installer

<p align="center">
    <img src="https://raw.githubusercontent.com/dlotterman/losvie/refs/heads/main/assets/losvie.png" alt="losvie diagram" width="500">
  </a>
</p>

### Why?

The following constraints routinely challenge Operators of "Bare Metal" compute:

1. Limited physical access to the hardware
2. Wide variety of hardware or hardware where drivers are a challenge
3. No access to untagged broadcast domains across servers
4. No or limited OOB access
5. Difficult widgets to automate
8. Licensing and Support agreements

These constraints often reflect the requirements of their circumstance. Bare Metal Clouds may restrict access to OOB's for security and isolate broadcast domains for scaleability, while "Edge Sites" may suffer from "A ticket and 7 day waits for someone to move the IP-KVM" type problems.

Despite these challenges,Operators will want to install an OS to a piece of hardware over a network where these or other challenges make that difficult, and losvie can be a critical pinch-hitting tool in these scenarios.

losvie started as an "exploration of a bad idea for fun", and as an idea has become a perpetually useful tool in the toolbelt for a small number of Operators. Credit to [enkelprifti98/metal-isometric-xepa](https://github.com/enkelprifti98/metal-isometric-xepa) as most adjacent inspiration.

# Documentations
- [Getting Started]()
- [Build]()
- [Boot]()
- [Install]()
## losvie as an Operators story:

### Build



### Boot

5. Operator boots a "Bare Metal Server" into the losvie environment which is a LiveOS running out of memory (not touching the boot disk)
  - `losvie-pubkeys.service` downloads an `authorized_keys` file and prepares the system
  - `losvie-firewall.service` punches holes in the firewall and starts `sshd.service`
  - `losvie-restart-network.service` covers edges cases in passing through "all NICss" to the the VM when needing network access.


### Install the Bare Metal Operating System via install environment VM

6. The Operator uploads / downloads their install artifacts to the "Bare Metal Server"

7. Operator identifies the hardware device(s) they would like to passthrough:
```
root@localhost-live:~# virsh nodedev-list --tree | grep -B2 enp1s0f0
  |   +- pci_0000_01_00_0
  |   |   |
  |   |   +- net_enp1s0f0_90_5a_08_31_13_18
```

4. Determine chassis BIOS / UEFI state (directory existance instance EFI):
```
# file /sys/firmware/efi/
/sys/firmware/efi/: directory
```

5. Identify OS boot disk:
```
lsblk 
NAME    MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
loop0     7:0    0   1.7G  1 loop /run/rootfsbase
sda       8:0    0 447.1G  0 disk 
sdb       8:16   0 447.1G  0 disk 
nvme1n1 259:0    0   1.7T  0 disk /mnt
nvme0n1 259:1    0   1.7T  0 disk 
```

5. Operator begins OS installation:
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
    --network network=default,model=e1000 \
		--host-device=pci_0000_81_00_0 \
	  --disk /dev/sda \
	  --cdrom /mnt/26100.1742.240906-0331.ge_release_svc_refresh_SERVER_EVAL_x64FRE_en-us.iso \
    --machine q35 \
    --boot uefi
 ```
 
 6. When OS installation is complete, installer will likely poweroff the install VM, Operator has two choices:
   - Is OS is ready to take over the Bare Metal host? If reboot the host from LiveOS state and it will reboot into the local disk
   - If further OS configuration is required (enabling services, modifying network configuration), start the VM again and make needed changes before poweroff of VM and rebooting the LiveOS host, which again should reboot into the host bootdisk.



# Troubleshooting
Please see [docs/troubleshooting.md](docs/troubleshooting.md)
