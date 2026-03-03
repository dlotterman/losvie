#!/bin/bash

setenforce 0
sysctl -w net.ipv4.ip_forward=1
echo 1 > /proc/sys/net/ipv4/ip_forward
systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target
dnf install dnf-plugins-core -y
# We want to do this before big package installs in case we get stuck behind a mirror with suboptimal reachability
cat > /etc/dnf/dnf.conf << EOL
[main]
gpgcheck=1
installonly_limit=3
clean_requirements_on_remove=True
best=True
skip_if_unavailable=False
max_parallel_downloads=10
fastestmirror=True
EOL
dnf update --refresh
dnf install -y bridge-utils virt-top libguestfs-tools bridge-utils virt-viewer qemu-kvm libvirt virt-manager virt-install edk2-ovmf edk2-tools gdisk
systemctl start libvirtd

for ENTRY in $(cat /proc/cmdline); do
    #echo $ENTRY
    if [[ $ENTRY == "sshpk="* ]]; then
        SSH_PUBKEYS=${ENTRY#sshpk=}
        echo $SSH_PUBKEYS
        mkdir /home/liveuser/.ssh
        wget -O /home/liveuser/.ssh/authorized_keys $SSH_PUBKEYS
        chown -R liveuser:liveuser /home/liveuser/.ssh
        chmod -R 0700 /home/liveuser/.ssh
        break
    fi
done
