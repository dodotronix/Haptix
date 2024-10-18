#!/usr/bin/env sh

# config network on belzebub
ip link set up dev enp0s31f6
ip addr add 10.0.0.2/24 dev enp0s31f6

# NOTE rigol network configuration in /etc/dhcpcd.conf
# option subnet-mask 255.255.255.0;
# subnet 10.0.0.0 netmask 255.255.255.0 {
#   range 10.0.0.0 10.0.0.20;
# }

# host rigol_scope{
#   hardware ethernet 00:19:AF:34:26:A3;
#   fixed-address 10.0.0.14;
# }

# start dhcpd
systemctl start dhcpd4@enp0s31f6
