#! /bin/bash

# This will be the bash script for setting up users and networking on Ubuntu devices

# Setting up users
read -p "Would you like to set up a new user? (y or n): " newUser
if [ $newUser = y ];
then
	read -p "Enter a username for a new local admin account: " username
	read -p "Enter the password for the account ${username}: " password
	hashedPass=$(openssl passwd -1 $password)
	useradd -m $username -p $hashedPass -s /bin/bash 
	usermod -aG sudo $username
fi

# Changing the hostname
read -p "Would you like to change the hostname? (y or n): " newHostname
if [ $newHostname = 'y' ];
then
	read -p "Enter the new hostname: " hostname
	hostname $hostname
	cd /etc/cloud
	sed -i "s|preserve_hostname: false|preserve_hostname: true|I" cloud.cfg
	hostnamectl set-hostname $hostname
	cd /etc
	sed -i '2d' hosts
	sed -i "2i 127.0.1.1 ${hostname}" hosts
	#sed -i "1d" hostname
	#sed -i "1i ${hostname}" hostname
	echo "Please restart your system to allow the change to take affect."
fi

# Setting up Networking
read -p "Would you like to set up networking? (y or n): " changeNetworking
if [ $changeNetworking = y ];
then
	read -p " Would you like to use DHCP? (y or n): " dhcp
	if [ $dhcp = y ];
	then
		rm /etc/netplan/00-installer-config.yaml
		touch /etc/netplan/00-installer-config.yaml
		filepath=/etc/netplan/00-installer-config.yaml
		ens=$(ls /sys/class/net | grep ens)
		echo "network:" >> $filepath
		echo "  version: 2" >> $filepath
		echo "  renderer: networkd" >> $filepath
		echo "  ethernets:" >> $filepath
		echo "    $ens:" >> $filepath
		echo "      dhcp4: true" >> $filepath
		netplan apply
	else
		read -p "Enter the IP address with CIDR notation: " ipAddress
		read -p "Enter the default gateway address: " gateway
		read -p "Enter the DNS search domain: " domain
		read -p "Enter the DNS server addresss: " dns
		rm /etc/netplan/00-installer-config.yaml
		touch /etc/netplan/00-installer-config.yaml
		filepath=/etc/netplan/00-installer-config.yaml
		ens=$(ls /sys/class/net | grep ens)
		echo "network:" >> $filepath
		echo "  version: 2" >> $filepath
		echo "  ethernets:" >> $filepath
		echo "    $ens:" >> $filepath
		echo "      addresses:" >> $filepath
		echo "      - $ipAddress" >> $filepath
		echo "      gateway4: $gateway" >> $filepath
		echo "      nameservers:" >> $filepath
		echo "        search: [$domain]" >> $filepath
		echo "        addresses:" >> $filepath
		echo "        - $dns" >> $filepath
		echo "      dhcp4: false" >> $filepath
		netplan apply

	fi
fi
