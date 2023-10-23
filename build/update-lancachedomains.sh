#!/bin/bash
# Show help if no argument is found
if [ -z "$1" ]; then
  echo "ERROR: No IP specified, please run for example:"
  echo "       ./update-lancachedomains.sh 192.168.1.10"
  echo
  echo "Replace 192.168.1.10 with the IP from your container or keepalived IP address"
  exit 1
elif [ "$1" == "-q" ]; then
  echo "ERROR: please use the following syntax for no questions:"
  echo "       ./update-lancachedomains.sh 192.168.1.10 -q"
  exit 1
fi

# Show help for quiet usage
if [ "$2" != "-q" ]; then
  echo "This process will start generating all necessary dnsmasq files for LANCache so that"
  echo "it properly interacts with PiHole and redirects all requests to your LANCache"
  echo "IP address: ${1}"
  echo
  echo "ATTENTION: The container will restart after the process is finished!"
  echo -n "Start (y/N)? "
  read -n 1 answer
  if [[ ${answer,,} =~ ^[Yy]$ ]]; then
    echo "Starting..."
  else
    echo "Abort!"
    exit 1
  fi
fi

# Clone repository
git clone https://github.com/uklans/cache-domains /tmp/cache-domains

# Generate config for cache-domains
echo '{
	"ips": {
		"generic":	"SEDREPLACEME"
	},
	"cache_domains": {
		"default": 	"generic"
	}
}' > /tmp/cache-domains/scripts/config.json

# Change directory
cd /tmp/cache-domains/scripts

# Inject IP address to config file
sed -i "s/SEDREPLACEME/${1}/g" /tmp/cache-domains/scripts/config.json

# Generate files
bash /tmp/cache-domains/scripts/create-dnsmasq.sh > /dev/null 2&>1

# Copy generated files to /etc/dnsmasq.d/
cp /tmp/cache-domains/scripts/output/dnsmasq/* /etc/dnsmasq.d/

# Remove temporary directory
rm -rf /tmp/cache-domains

# Reboot container
echo "Restarting container, please wait...!"
/usr/sbin/reboot
