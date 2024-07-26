# PiHole LXC container archive for unRAID

## Prerequisites

- unRAID server
- Properly configured and installed LXC plugin for unRAID
- Basic understanding of command line usage

## Container archive contents

- Unbound
- keepalived
- Cron
- PiHole
- LANCache (optional)
- OpenSSH Server

(please note that IPv6 is disabled by default)

## LXC Distribution Infromation

- debian
- bookworm
- amd64

## Table of Contents

1. [Install container](#step-1-install-container-archive)
2. [Set root password](#step-2-set-root-password)
3. [Set a static IP](#step-3-set-a-static-ip)
4. [(optional) Configure keepalived](#optional-step-4-configure-keepalived)
5. [(optional) Configure LANCache](#optional-step-5-configure-lancache)
6. [(optional) Confiure cron](#optional-step-6-configure-cron)
7. [(optional) Configure Unbound](#optional-step-7-configure-unbound)

## Step 1: Install Container archive

1. ~~Go to the CA App and search for PiHole~~ <- not implemented currently
2. ~~Select the LXC template and install it~~ <- not implemented currently

   
Currently only available by manually downloading and installing the template
1. Open a Unraid terminal and execute `wget -O /tmp/lxc_container_template.xml https://raw.githubusercontent.com/ich777/unraid_lxc_pihole/main/lxc_container_template.xml`
2. Navigate to `http://<YourunRAIDIP>/LXCAddTemplate`
3. Make your changes if necessary
4. Click Apply
5. Wait for the Done button

## Step 2: Set root password

- Open up a Terminal from the PiHole container (click the container icon and select "Terminal")
- Type in `passwd`
- Type in your prefered password twice (no output is displayed) and press ENTER


## Step 3: Set a static IP

This step is highly recommended but not necessary. Usually, it is sufficient for your container to be assigned a random IP address from your DHCP server because the virtual IP address for your DNS should be static and is set in the [configure keepalived](#step-4-configure-keepalived) section.  
It is also recommended to change the hostname from the container with the command: `hostnamectl set-hostname <HOSTNAME>`(replace <HOSTNAME> with your prefered Hostname).

You have multiple options here:

1. Set a static IP for the container in your DHCP server:
- Visit the configuration page from your Router/Firewall and assign a static IP and stop/start the container once
  (restarting the container could lead to unexpected behaviour like that the old IP is keeped until you fully stop and start the container once)
2. Set a static IP in the container itself (recommended):
- Type in `nano /etc/systemd/network/eth0.network` and press ENTER
- Replace the line `DHCP=true` with the following code block by copy-paste:
```
Address=x.x.x.x/24
#Address=xxxx:xxxx:xxxx:x:x:x:x 

Gateway=x.x.x.x
#Gateway=xxxx:xxxx:xxxx:x:x:x:x  

DNS=x.x.x.x
#DNS=xxxx:xxxx:xxxx:x:x:x:x
```
- Replace "x.x.x.x" at "Address" with your prefered IP address
- Replace "x.x.x.x" at "Gateway" with your Gateway IP address
- Replace "x.x.x.x" at "DNS" with your favourite public DNS server or from your Router
- (optional) If you need IPv6 uncomment the IPv6 lines and replace them with your IPv6 addresses
- Save and close the file with "CTRL + X" followed by "Y" and press ENTER
- Stop/Start the container once
  (restarting the container could lead to unexpected behaviour like that the old IP is keeped until you fully stop and start the container once)

## (optional) Step 4: Configure keepalived

- Type in `nano /etc/keepalived/keepalived.conf`
- Change the "state" to MASTER or BACKUP depending which instance you are configuring (only one MASTER but multiple BACKUP instances are allowed)
- (optional) change the "virtual_router_id" if you have multiple keepalived instances in your network and you want to use for each instance a separate router
- Change the "priority" depending if it's a MASTER or BACKUP instance
  (the MASTER interface should be set to 100 and the BACKUP instance(s) from 1 to 99 <- higher priority is prefered first)
- Change the password "superstrongpassword" at "auth_pass" (must be the same on all MASTER and BACKUP instances for the current virtual_router_id)
- Change "x.x.x.x" at "virtual_ipaddress" to the IPv4 address which should have high availability and you want to use for DNS requests (must be the same on all MASTER and BACKUP instances)
- (optional) if you need IPv6, uncomment the lines as specified in the configuration and specify a static IPv6
- Save the file by pressing "CTRL + X" followed by "Y" and ENTER
- Enable keepalived for automatic start from the container with `systemctl enable keepalived`
- To start keepalived restart the container or issue `systemctl start keepalived` 

## (optional) Step 5: Configure LANCache

The container ships with a script located at `/root/update-lancache.sh` that is not enabled by default.

Before you start and run this script, it is strongly recommended that you use a SSD/NVME (without RAID/Mirror) for the LANCache and mount it to the container, to do so please stop the LXC container, edit the config (you'll find the container config in your LXC direcotry -> container name -> config eg: `/mnt/cache/lxc/CONTAINERNAME/config`, you can get the full container config path by showing the container config on the LXC page too) and add these lines:
```
# Mount host directory
lxc.mount.entry = /mnt/disks/LANCache mnt/lancache none bind 0 0
```
In this example a disk is mounted through Unassigned devices with the label: LANCache and the path `/mnt/disks/LANCache` on Unraid (please note that the path `mnt/lancache` is the path inside the container and the missing `/` at the start is not a typo!).

You can of course mount a path else where for example on the cache where the entry needs to look something like that:
`lxc.mount.entry = /mnt/cache/LANCache mnt/lancache none bind 0 0`

After mounting the path from the Host you can run this script. On the first run it will install Docker, after that LANCache is pulled from DockerHub and started, the default values for the cache itself are: CACHE_SIZE=1000g (1TB) and CACHE_INDEX_SIZE=250m

If you need other values then please edit the file `/root/update-lancache.sh` and audjust the values to your preferences (please note if you exceed the disk size for the value from CACHE_SIZE the container will not start and will be stuck in a restart loop)

Please also run `/root/update-lancachedomains.sh YOURIP` once to generate dnsmasq files which will then be used by PiHole to make use of your LANCache (please replace `YOURIP` with the IP from your PiHole or keepalived IP address <- this applies also to the crontab if you enable that schedule).

To enable frequent updates from lancache remove the `#` from the last line in the crontab, see [(optional) Confiure cron](#optional-step-7-configure-cron) for more information.

## (optional) Step 6: Configure cron

By default the cron schedules for updates are:
- root.hints: every Sunday at 0:00
- PiHole and Gravity sync: every Sunday at 0:30
- (optional) LANCache: every Sunday at 0:45)

To change the crontab:
- Issue `crontab -e` from a container Terminal
- Select your prefered editor (in this example nano) by pressing 1 and ENTER
- Change the crontab accordingly and press "CTRL + X" followed by "Y" and ENTER to save the file

## (optional) Step 7: Configure Unbound
- The configuration from Unbound is located at `/etc/unbound/unbound.conf`(if you need for example IPv6 or your local subnets doesn't match)
- Don't forget to restart Unbound with `systemctl restart unbound`after editing the file or simply restart the container

## Finished
- Open up the PiHole WebUI by clicking on the container icon and select WebUI
