# Build

**WIP** 

1. In a [cloud_dev_env](../TODO.md), Operator downloads a [Rocky](https://rockylinux.org/download/)/[Alma](https://almalinux.org/download/)/[Fedora](https://getfedora.org/en/workstation/download/) LiveOS ISO of choice

2. In same [cloud_dev_env](http://todo), Operator clones and installs losvie
  - `sudo` required because `install.sh` uses `unsquashfs` which writes `xattrs` (for SELinux). This is easiest with privilidges. 
```
git clont https://
cd losvie
sudo ./install.sh -d /opt/losvie -i /mnt/disk102_enc/share/installers/AlmaLinux-10-latest-x86_64-Live-GNOME.iso
```

5. Operator edits `losvie.ipxe` file

6. Operator writes `authorized_keys` file in losvie directory (`/opt/losvie/export` by default)

4. Operator uploads `export/` artifacts to CDN or exposes folder with HTTP from workstation
```
podman run -d --rm --name http-server -p 5000:5000 -v /opt/losvie/export:/html:ro,z ghcr.io/patrickdappollonio/docker-http-server:v2
firewall-cmd --add-port=5000 --zone=public
firewall-cmd --add-port=5000 --zone=public --permanent
```
or alternate`ufw` commands:
```
ufw allow 5000
ufw route allow in on enp1s0 out on podman0 to any port 5000
```

### cmdline options explained

[Kernel cmdline native](https://www.kernel.org/doc/html/v4.14/admin-guide/kernel-parameters.html) options:
- `netpoll.carrier_timeout=92`
  - *[NET] Specifies amount of time (in seconds) that netpoll should wait for a carrier. By default netpoll waits 4 seconds.*
    - This is set very high to cover networks missing portfast configurations or where connectivity takes time after link state
- `module_blacklist=usbnet`
  - *[KNL] Do not load a comma-separated list of modules.  Useful for debugging problem modules.*
    - Recently many OEM's have started trying to deliver lifecycle functions over an internal USB plumbing. It's awful and makes LiveOS networking hard so we blacklist the driver at bootime.
- `consoleblank=0`
  - *[KNL] The console blank (screen saver) timeout in seconds. Defaults to 10x60 = 10mins. A value of 0 disables the blank timer.*
    - If you want to see what happened on a screen, it's no use if that screen went dark especially if you can't wake it
- `console=tty0 console=ttyS0`
  - Documentation too long to C+V, controls where "console" I/O goes, where last listed gets "primary"
    - This sends output to first serial (common) and first video

[Dracut cmdline parameters](https://man7.org/linux/man-pages/man7/dracut.cmdline.7.html)
- `ip=dhcp`
  - Too long to document, critical feature for static / DHCP / VLAN configuration, see dracut docs.
- `rd.net.timeout.iflink=92`
  - *Wait <seconds> until link shows up. Default is 60 seconds.*
    - We set this high for surviveability
- `rd.net.timeout.ifup=92`
  - *Wait <seconds> until link has state "UP". Default is 20 seconds.*
    - We set this high for surviveability
- `rd.net.timeout.carrier=92`
  - *Wait <seconds> until carrier is recognized. Default is 10 seconds.*
    - Dracut version of kernel's carrier_timeout, we set to same
- `rd.lvm=0`
  - *disable LVM detection*
    - We do not want to pickup or get stuck on LVM trash on disk
- `rd.luks=0`
  - *disable crypto LUKS detection*
    - We do not want to pick up LUKs trash
- `rd.md=0`
  - *disable MD RAID detection*
    - We do not want to pick up MDRAID trash
- `rd.dm=0`
  - *disable MD RAID detection*
    - We do not want to pick up MDRAID trash pt2
- `rd.multipath=0`
  - *disable multipath detection*
    - We do not want multipaths in the middle
- `root=live:${distrobase}/losvie.squashfs`
  - *Boots a live image retrieved from <url>.*
    - This is how we get our modifications into the bootchain, as the `squashfs` file is a build artifact of this repo.
- `rd.live.image`
  - Too long to document, instructs kernel to mount correctly for a squashfs based LiveOS
- `ro`
  - *orce mounting / and /usr (if it is a separate device) read-only.*

[losvie cmdline paramets](https://github.com/dlotterman/losvie/tree/main/squashfs_inserts)
- `fw=47.252.252.252`
  - Used by `losvie-firewall.sh` to punch holes in the firewall, presuming the connectivity is public internet and less access is preferred
    - Punches holes for ssh and VNC
    - Can be included multiplie times for multiple holes
- `sshpk=${base}/pk`
  - Used by `losvie-pubkeys.sh`, which preps the system and downloads a set of SSH public keys providing operator access
    - This is critical for automation
