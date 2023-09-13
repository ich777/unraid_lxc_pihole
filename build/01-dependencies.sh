#!/bin/bash
apt-get update
apt-get -y install wget curl nano unbound keepalived iputils-ping openssh-server cron netctl
systemctl stop unbound keepalived ssh.service
systemctl disable keepalived
