#!/bin/bash
ln -s /etc/init.d/runonce.sh /etc/rc.local

rm -f /etc/ssh/*_key /etc/ssh/*.pub
sed -i "/#PermitRootLogin prohibit-password/c\PermitRootLogin yes" /etc/ssh/sshd_config
