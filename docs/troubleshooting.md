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
