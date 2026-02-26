#!/bin/bash

firewall-cmd --remove-service=ssh --zone=public
firewall-cmd --remove-service=ssh --zone=public --permanent
firewall-cmd --remove-service=cockpit --zone=public
firewall-cmd --remove-service=cockpit --zone=public --permanent
firewall-cmd --add-port=5900/tcp --zone=external
firewall-cmd --add-port=5900/tcp --zone=external --permanent
firewall-cmd --add-port=5901/tcp --zone=external
firewall-cmd --add-port=5901/tcp --zone=external --permanent

for ENTRY in $(cat /proc/cmdline); do
    #echo $ENTRY
    if [[ $ENTRY == "fw="* ]]; then
        FW=${ENTRY#fw=}
        echo $FW
        firewall-cmd --zone=external --add-source=$FW
        firewall-cmd --zone=external --add-source=$FW --permanent
    fi
done

systemctl start sshd.service
