#!/bin/bash
mkdir -p /etc/pihole
cp /tmp/build/setupVars.conf /etc/pihole/
chmod 755 /etc/pihole/setupVars.conf
export PIHOLE_SKIP_OS_CHECK=true
curl -sSL https://install.pi-hole.net | bash /dev/stdin --unattended
sed -i 's/\<80\>/8080/g' /etc/lighttpd/lighttpd.conf
rm -f /etc/lighttpd/conf-enabled/99-unconfigured.conf
