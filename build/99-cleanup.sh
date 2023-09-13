#!/bin/bash
apt clean
rm -rf /var/cache/apt/archives/*
rm -f /etc/ssh/*_key /etc/ssh/*.pub
find /var/log -type f -mtime +30 -exec rm {} \;
