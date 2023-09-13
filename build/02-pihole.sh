#!/bin/bash
mkdir -p /etc/pihole
cp /tmp/build/setupVars.conf /etc/pihole/
chmod 755 /etc/pihole/setupVars.conf
export PIHOLE_SKIP_OS_CHECK=true
curl -sSL https://install.pi-hole.net | bash /dev/stdin --unattended
