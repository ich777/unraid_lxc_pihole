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

(please note that IPv6 is disabled by default)

## LXC Distribution Infromation

- debian
- bookworm
- amd64

## Table of Contents

1. [Install container](#step-1-install-container-archive)
2. [Set root password](#step-2-set-root-password)
3. [Set a static IP](#step-3-set-a-static-ip)
4. [Configure keepalived](#step-4-configure-keepalived)
5. [Configure Gravity sync](#step-5-configure-gravity-sync)
6. [Confiure cron](#step-6-configure-cron)

## Step 1: Install Container archive

  1. Go to the CA App and search for PiHole
  2. Select the LXC template and install it

## Step 2: Set root password

  - Open up a Terminal from the PiHole container (click the container icon and select "Terminal")
  - Type in `passwd`
  - Type in your prefered password twice (no output is displayed) and press ENTER


## Step 3: Set a static IP

You have multiple options here:

  1. Set a static IP for the container in your DHCP server:
  - Visit the configuration page from your Router/Firewall and assign a static IP and stop/start the container once
    (restarting the container could lead that the old IP is keeped until you fully stop and start the container once)
  2. Set a static IP in the container itself (recommended):
  - Type in `nmtui` and press ENTER
  - Highlight "Edit Connection" and press ENTER
  - Highlight "Wired Connection" and navigate with the arrow keys to "Edit..." and press ENTER
  - Navigate to the line "IPv4 CONFIGURATION", press ENTER and select "Manual" and press ENTER
  - Navigate to show and press ENTER
  - Navigate to the line "ADDRESSES", highlight "Add..." and hit ENTER
  - Enter the prefered static IP address
  - Navigate to the line "Gateway" and enter the IP address from your Gateway
  - Navigate to the line "DNS Servers" and add your DNS server(s)
  - (do the same for IPv6 if needed)
  - Navigate to "OK" at the bottom and press ENTER
  - Navigate to "Back" and press ENTER
  - Navigate to "Quit" and press ENTER
  - Stop/Start the container once
    (restarting the container could lead that the old IP is keeped until you fully stop and start the container once)

## Step 4: Configure keepalived

  - Type in `nano /etc/keepalived/keepalived.conf`
  - Change the "state" to MASTER or BACKUP depending which instance you are configuring (only one MASTER but multiple BACKUP instances are allowed)
  - (change the "virtual_router_id" if you have multiple keepalived instances in your network and you want to use for each instance a separate router)
  - Change the "priority" depending if it's a MASTER or BACKUP instance
    (the MASTER interface shoudl be set to 100 and the BACKUP instance(s) from 1 to 99 <- higher priority is prefered first)
  - Change the password "superstrongpassword" at "auth_pass" (must be the same on all MASTER and BACKUP instances for the current virtual_router_id)
  - Change "x.x.x.x" at "virtual_ipaddress" to the IPv4 address which should have high availability
  - (if you need IPv6 too, then uncomment the lines as specified in the configuration and specify a static IPv6)
  - Save the file by pressing "CTRL + X" followed by "Y" and ENTER
  - Enable keepalived on start from the container with `systemctl enable keepalived`
  - To start keepalived restart the container or issue `systemctl start keepalived` 

## Step 5: Configure Gravity sync

  - TBD

## Step 6: Configure cron

By default the cron schedules for updates are:
  - root.hints: every Sunday at 0:00
  - PiHole and Gravity sync: every Sunday at 0:30

To change the crontab:
- Issue `crontab -e` from a container Terminal
- Select your prefered editor (in this example nano) by pressing 1 and ENTER
- Change the crontab accordingly and press "CTRL + X" followed by "Y" and ENTER to save the file
