# TrueNAS

```
# virsh nodedev-list --tree | grep -B2 enp5s0f1np1
  |   +- pci_0000_05_00_1
  |       |
  |       +- net_enp5s0f1np1_7c_c2_55_a8_2f_3f
```

```
virt-install \
    --graphics vnc,password=foobar,listen=0.0.0.0 \
    --memory 8192 \
    --vcpus 4 \
    --name truenas1 \
    --sound none \
    --os-variant linux2022 \
    --autoconsole none \
    --network network=default \
	  --disk /dev/nvme0n1 \
	  --cdrom /mnt/TrueNAS-SCALE-25.10.2.iso \
    --host-device=pci_0000_05_00_1 \
    --machine q35 \
    --boot uefi,firmware.feature0.name=secure-boot,firmware.feature0.enabled=no
```

## 
ISO does not appear to be UEFI aware?
