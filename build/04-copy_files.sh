#!/bin/bash
cd /tmp/build
chmod 755 $(ls -1 /tmp/build/ | grep -v "^[0-9][0-9]-")
cp /tmp/build/unbound.conf /etc/unbound/unbound.conf
rm /etc/keepalived/*
cp /tmp/build/keepalived.conf /etc/keepalived/keepalived.conf
chmod 644 /etc/keepalived/keepalived.conf
cp /tmp/build/update-roothints.sh /root/update-roothints.sh
cp /tmp/build/update-applications.sh /root/update-applications.sh
cp /tmp/build/generate_ssh_keys.sh /etc/init.d/generate_ssh_keys.sh
