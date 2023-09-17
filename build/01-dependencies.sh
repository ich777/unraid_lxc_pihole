#!/bin/bash
apt-get update
apt-get -y install wget curl nano unbound keepalived iputils-ping openssh-server cron
systemctl stop unbound keepalived ssh.service
systemctl disable keepalived
sed -i "s/#DNSStubListener=yes/DNSStubListener=no/g" /etc/systemd/resolved.conf && \
systemctl restart systemd-resolved
