$IP = "10.10.10.10"
$MaskBits = 29 # This means subnet mask = 255.255.255.0
$Gateway = "10.10.10.1"
$Dns = "1.1.1.1"
$IPType = "IPv4"
# Retrieve the network adapter that you want to configure
$adapter = Get-WmiObject Win32_NetworkAdapterConfiguration| where {$_.MACAddress -eq '52:54:00:65:fc:99'} | Get-NetAdapter
# Remove any existing IP, gateway from our ipv4 adapter
If (($adapter | Get-NetIPConfiguration).IPv4Address.IPAddress) {
 $adapter | Remove-NetIPAddress -AddressFamily $IPType -Confirm:$false
}
If (($adapter | Get-NetIPConfiguration).Ipv4DefaultGateway) {
 $adapter | Remove-NetRoute -AddressFamily $IPType -Confirm:$false
}
$adapter | Set-NetIPInterface -Dhcp Disabled
 # Configure the IP address and default gateway
$adapter | New-NetIPAddress `
 -AddressFamily $IPType `
 -IPAddress $IP `
 -PrefixLength $MaskBits `
 -DefaultGateway $Gateway
# Configure the DNS client server IP addresses
$adapter | Set-DnsClientServerAddress -ServerAddresses $DNS

Enable-NetFirewallRule -displayName "File and Printer Sharing (Echo Request - ICMPv4-In)"
