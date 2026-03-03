# FreeBSD

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
    --name freebsd1 \
    --sound none \
    --os-variant freebsd14.2 \
    --virt-type kvm \
    --autoconsole none \
    --network network=default \
	  --disk /dev/nvme0n1 \
	  --cdrom /mnt/FreeBSD-15.0-RELEASE-amd64-disc1.iso \
    --host-device=pci_0000_05_00_1 \
    --machine q35 \
    --boot
```

## UEFI

Default ISO needs work to make UEFI.

https://wiki.freebsd.org/UEFI
https://freebsdfoundation.org/freebsd-uefi-secure-boot/
