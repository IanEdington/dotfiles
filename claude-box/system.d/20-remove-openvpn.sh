#!/usr/bin/env bash
set -euo pipefail

# The first droplet doubled as a personal OpenVPN server. A box that runs an
# agent on untrusted web content should not also route other devices'
# traffic, so remove every piece the openvpn-install script left behind.

systemctl disable --now openvpn-server@server.service 2> /dev/null || true

if dpkg -s openvpn &> /dev/null || dpkg -s easy-rsa &> /dev/null; then
    DEBIAN_FRONTEND=noninteractive apt-get purge -y -q --autoremove openvpn easy-rsa
fi
rm -rf /etc/openvpn /var/log/openvpn
rm -f /etc/sysctl.d/99-openvpn.conf
sysctl -q -w net.ipv4.ip_forward=0

# Firewall: the VPN port, its NAT block, and the forward policy it opened.
while ufw status | grep -q '^1194/udp'; do
    ufw --force delete allow 1194/udp > /dev/null
done
sed -i '/^# START OPENVPN NAT/,/^# END OPENVPN NAT/d' /etc/ufw/before.rules
sed -i 's/^DEFAULT_FORWARD_POLICY="ACCEPT"/DEFAULT_FORWARD_POLICY="DROP"/' /etc/default/ufw
iptables -t nat -D POSTROUTING -s 10.8.0.0/24 -o eth0 -j MASQUERADE 2> /dev/null || true
ufw reload > /dev/null

# Client profiles embed each device's private key.
rm -f /home/*/*.ovpn /root/*.ovpn
