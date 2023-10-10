#!/bin/bash
dpkg-reconfigure openssh-server

rm /etc/init.d/runonce.sh
update-rc.d generate_ssh_keys.sh remove
