#!/bin/bash
apt-get update
apt-get -y install wget curl nano unbound keepalived iputils-ping openssh-server cron
apt-get -y install --no-install-recommends network-manager
systemctl stop unbound keepalived ssh.service
systemctl disable keepalived
