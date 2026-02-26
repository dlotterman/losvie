#!/bin/bash

setenforce 0
systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target
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
