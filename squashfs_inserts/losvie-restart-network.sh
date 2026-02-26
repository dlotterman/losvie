#!/bin/bash

if [[ $(virsh list  --uuid --state-shutoff) ]]; then
    if [ -f /tmp/losvie-restart-network.touch ]; then
        logger "already restarted"
        exit 0
    fi
    echo "shutoff VM detected, restarting network"
    systemctl restart NetworkManager.service
    systemctl stop losvie-restart-network.timer
    touch /tmp/losvie-restart-network.touch
else
    echo "no shutoff VM detected"
fi
