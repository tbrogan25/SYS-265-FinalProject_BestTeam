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
