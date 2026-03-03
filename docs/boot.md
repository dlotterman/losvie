### Boot

"Bare Metal Server" is booted into the losvie environment which is a LiveOS running out of memory (not touching the boot disk)
  - `losvie-pubkeys.service` downloads an `authorized_keys` file and prepares the system
  - `losvie-firewall.service` punches holes in the firewall and starts `sshd.service`
  - `losvie-restart-network.service` covers edges cases in passing through "all NICss" to the the VM when needing network access.

  
  ## TODO
  This needs expansion o
