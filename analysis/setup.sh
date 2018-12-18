#!/usr/bin/bash
# RPi internet sharing setup

FLAG=$1

if [ -z "$FLAG" ]; then
  echo "You must submit parametr 'on' or 'off'!"
  exit
fi

if [ $FLAG == 'on' ]; then
  systemctl start dhcpd4@enp9s0
  sysctl net.ipv4.ip_forward=1
  iptables -t nat -A POSTROUTING -o wlp3s0 -j MASQUERADE

elif [ $FLAG == 'off' ]; then
  systemctl stop dhcpd4@enp9s0
  sysctl net.ipv4.ip_forward=0
  iptables -t nat -F
fi

