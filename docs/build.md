# Build

## Requirements

1. A *"build host"* running a modern Linux distrobution with `squashfs-tools` tools installed, to be used as a build host. Likely options are:
  1. Locally hosted VM or OS Container
    - If build host is behind a firewall with no ability to expose a port to the internet, then a CDN will be required.
  2. Cloud hosted VM
    - If build host is a "Cloud" instance with a Public IP, then build artifacts can be hosted via that Cloud instanc

You will likely want a VNC client on your physical workstation if you need to engage with an interactive OS for the intended installer. If you cannot run a VNC client because of say corporate restrictions, you can use [Cockpit](docs/cockpit.md) as a vector to a hosted interactive session with the VM.

**WIP** 

1. On the *build host*, Operator downloads a [Rocky](https://rockylinux.org/download/)/[Alma](https://almalinux.org/download/)/[Fedora](https://getfedora.org/en/workstation/download/) LiveOS ISO of choice

2. On the same *build host*, Operator clones and installs [losvie](https://github.com/dlotterman/losvie)
  - `sudo` required because `install.sh` uses `unsquashfs` which writes `xattrs` (for SELinux). This is easiest with privilidges. 
```
git clone https://github.com/dlotterman/losvie.git
cd losvie
sudo ./install.sh -u dlotterman -e "http://dl-w-p.b-cdn.net/losvie2" -f "192.168.50.0/24" -d /opt/losvie -i /mnt/disk102_enc/share/installers/AlmaLinux-10-latest-x86_64-Live-GNOME.iso
```
* `-u dlotterman` tells the install script to chown the files back to this after likely creating as root (via sudo), user convenience
* `-e "http://dl-w-p.b-cdn.net/losvie2"` tells the installs script the expected public HTTP endpoint so that it can template the `ipxe` file as a convenience
* `-f "192.168.50.0/24"` tells the install script to template the firewall-hole punch into the `ipxe` file as a covenience
* `-d /opt/losvie` tells the install script to create and use the target directory as the build location for losvie artifacts
* `-i /mnt/disk102_enc/share/installers/AlmaLinux-10-latest-x86_64-Live-GNOME.iso` tells the install script where to find the LiveOS ISO locally on the *build host* so it can unpack mangle and repack.

5. Operator edits `losvie.ipxe` file

6. Operator writes `authorized_keys` file in losvie directory (`/opt/losvie/export` by default)

4. Operator uploads `export/` artifacts to CDN **OR** exposes folder with HTTP from workstation

Example of easy exposure via `podman` (replace with `docker` if needed)
```
podman run -d --rm --name http-server -p 5000:5000 -v /opt/losvie/export:/html:ro,z ghcr.io/patrickdappollonio/docker-http-server:v2
```

`firewalld`:
```
firewall-cmd --add-port=5000 --zone=public
firewall-cmd --add-port=5000 --zone=public --permanent
```
`ufw`:
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
    - Not working for some reason, still seeing RAID stuff I don't want
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
  - *Force mounting / and /usr (if it is a separate device) read-only.*

[losvie cmdline paramets](https://github.com/dlotterman/losvie/tree/main/squashfs_inserts)
- `fw=47.252.252.252`
  - Used by `losvie-firewall.sh` to punch holes in the firewall, presuming the connectivity is public internet and less access is preferred
    - Punches holes for ssh and VNC
    - Can be included multiplie times for multiple holes
- `sshpk=${base}/pk`
  - Used by `losvie-pubkeys.sh`, which preps the system and downloads a set of SSH public keys providing operator access
    - This is critical for automation
