# OpenBSD

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
    --name openbsd1 \
    --sound none \
    --os-variant openbsd7.6 \
    --autoconsole none \
    --network network=default \
	  --disk /dev/nvme0n1 \
	  --cdrom /mnt/install78.iso \
    --host-device=pci_0000_05_00_1 \
    --machine q35 
```

## 
ISO does not appear to be UEFI aware?
