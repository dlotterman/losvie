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
