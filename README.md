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
- Gravity Sync
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
5. [(optional) Configure Gravity sync](#optional-step-5-configure-gravity-sync)
6. [(optional) Confiure cron](#optional-step-6-configure-cron)
7. [(optional) Configure Unbound](#optional-step-7-configure-unbound)

## Step 1: Install Container archive

1. Go to the CA App and search for PiHole
2. Select the LXC template and install it

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

## (optional) Step 5: Configure Gravity sync

- TBD

## (optional) Step 6: Configure cron

By default the cron schedules for updates are:
- root.hints: every Sunday at 0:00
- PiHole and Gravity sync: every Sunday at 0:30

To change the crontab:
- Issue `crontab -e` from a container Terminal
- Select your prefered editor (in this example nano) by pressing 1 and ENTER
- Change the crontab accordingly and press "CTRL + X" followed by "Y" and ENTER to save the file

## (optional) Step 7: Configure Unbound
- The configuration from Unbound is located at `/etc/unbound/unbound.conf`(if you need for example IPv6 or your local subnets doesn't match)
- Don't forget to restart Unbound with `systemctl restart unbound`after editing the file or simply restart the container

## Finished
- Open up the PiHole WebUI by clicking on the container icon and select WebUI
