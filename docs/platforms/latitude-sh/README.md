# Latitude.sh

LSH enables persistant DHCP on the 1st port of any Bare Metal instance launched with iPXE.

That DHCP service will offer the usual LSH /31 IP address and subnet.

This /31 is confusing to Windows's networking model, and Windows will refuse and error on DHCP release and renew.
