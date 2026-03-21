# squashfs / unsquashfs SELinux errors

How that does `losvie` packaging work does not have to be SELinux enabled, but some errors are more likely on SELinux enabled hosts:

- Ensure destination filesystem is [attr](https://man7.org/linux/man-pages/man5/attr.5.html) aware (So yes `xfs` or `ext4`, no `FAT` or `rclone`)
- Look for SELinux errors and follow usual `audit2allow` [triage](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/10/html/using_selinux/troubleshooting-problems-related-to-selinux)
  - *EL9* hosts currently need an `audit2allow` for `mac_admin` when running as not root for example.

# scrubbing disks from previous install

`sgdisk` -Z can be used to clear the partition table and make the disk usable again.

If somehow a dm-raid device got picked up:

`mdadm --stop /dev/md127`

`sgdisk -Z /dev/sda`
`sgdisk -Z /dev/sdb`

# Tracking progress

It can be hard to have visibility into where a server is in its journey into losvie. 

Watching the HTTP / CDN logs can be a useful point of view.

# using libvirt VMs as tests

When trying to validate a losvie setup, you may want to sanity check that widgets are working and accessible. While losvie is meant for Bare Metal, it can also bootstrap into a VM fairly easily:

```
virt-install   
--memory 8192 \
--vcpus 2 \
--name ipxetest \    
--disk size=16 \     
--sound none \
--os-variant almalinux10 \
--graphics none \
--serial pty \
--console pty,target.type=virtio \
--network passt,portForward=3222:22 \
--boot kernel=/opt/losvie/export/vmlinuz,initrd=/opt/losvie/export/initrd.img,kernel_args="root=live:http://dl-w-p.b-cdn.net/losvie2/losvie.squashfs fw=192.168.50.0/24 sshpk=http://dl-w-p.b-cdn.net/losvie2/pk initrd=initrd.img rd.net.timeout.iflink=92 rd.net.timeout.ifup=92 rd.net.timeout.carrier=92 console=tty0 console=ttyS0 ro rd.live.image rd.lvm=0 rd.luks=0 rd.md=0 rd.dm=0 rd.multipath=0 consoleblank=0 rd.timeout=110 module_blacklist=usbnet netpoll.carrier_timeout=92 rd.auto=0 selinux=0 enforcing=0"
