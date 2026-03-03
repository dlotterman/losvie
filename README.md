# Losvie - "Live OS Virtual Install Environment"
## An OS provisioning toolkit for operationally constrained Bare Metal

**WIP**

losvie is a collection of widgets that provide a novel OS installation platform suited for "constrained" environments like "Bare Metal Clouds" or "Edge Sites". 

losvie is three chapters of a story:

1. **Build**: Repackge an Enterprise Linux ISO with the contents of [squashfs_inserts](squashfs_inserts/)
  - Host those artifacts via HTTP
2. **Boot**: Boot a "Bare Metal Server" into losvie via the hosted artifacts
  - Leaving its hardware (e.g boot disk) as available
3. **Install**: Use a [libvirt](https://libvirt.org/) VM as a sort of "outside-in" OOB, providing the CD-ROM, KVM and hardware passthrough to the installer
  - Host reboots into boot disk and the OS that was installed via the VM

<p align="center">
    <img src="https://raw.githubusercontent.com/dlotterman/losvie/refs/heads/main/assets/losvie.png" alt="losvie diagram" width="750">
  </a>
</p>

### Why?

The following constraints routinely challenge Operators of "Bare Metal" compute who simply "want to install an OS":

1. Limited physical access to the hardware
2. Wide variety of hardware or hardware where drivers are a challenge
3. No access to untagged broadcast domains across servers (ARP/DHCP -> PXE)
4. No or limited OOB access
8. Licensing and Support agreements
5. Difficult or blocked paths to automation

These constraints often reflect the requirements of their circumstance; Bare Metal Clouds may restrict access to OOB's for security and isolate broadcast domains for scaleability, while "Edge Sites" may suffer from "A ticket and 7 day waits for someone to move the IP-KVM" type problems.

Despite these challenges, Operators will want to install an OS to a piece of hardware over a network where these or other challenges make that difficult, losvie is meant for these scenarios.

losvie started as an "exploration of a bad idea for fun", and instead of being a bad idea, turned out to be a perpetually useful tool in the toolbelt for a small number of Operators. Credit to [enkelprifti98/metal-isometric-xepa](https://github.com/enkelprifti98/metal-isometric-xepa) as most adjacent inspiration.

# Documentation
- [Getting Started](docs/getting_started.md)
- [Build](docs/build.md)
- [Boot]()
- [Install]()
- [Troubleshooting](docs/troubleshooting.md)
