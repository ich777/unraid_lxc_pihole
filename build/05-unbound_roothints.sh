#!/bin/bash
echo "Downloading initial root.hints from https://www.internic.net/domain/named.root"
cd /etc/unbound
wget -q -O /etc/unbound/root.hints "https://www.internic.net/domain/named.root"
