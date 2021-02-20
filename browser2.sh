#!/bin/bash
# raspi-config changes

#ip address checking routine
function valid_ip()
{
    local  ip=$1
    local  stat=1

    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        OIFS=$IFS
        IFS='.'
        ip=($ip)
        IFS=$OIFS
        [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 \
            && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
        stat=$?
    fi
    return $stat
}


# Localisation Options: Select your preferred locale (we simply keep the default en_GB.UTF-8), timezone, and keyboard layout.
sudo raspi-config nonint do_wifi_country gb

# Expand file syatem
sudo raspi-config nonint do_expand_rootfs

# Change User Password
passwd

# Network Options: Configure WiFi as needed.

# Boot Options: Select “Desktop / CLI” and then “Console Autologin”. We’ll come back to this later.
sudo raspi-config nonint do_boot_behaviour B2

# set splash screen off to speed up the boot
sudo raspi-config nonint do_boot_splash 1

# Interfacing Options: Enable SSH access if needed.
sudo raspi-config nonint do_ssh 0

# Advanced Options: Disable “Overscan” if the Pi’s output does not fill your screen completely.
sudo raspi-config nonint do_boot_behaviour B2

# update before we start

sudo apt-get update
sudo apt-get upgrade -y

# install an xserver
sudo apt-get install --no-install-recommends xserver-xorg x11-xserver-utils xinit openbox -y
# and now the browser
sudo apt-get install --no-install-recommends chromium-browser -y

# get a hostname for this device

read -p "This Device Hostname :" this_hostname
sudo raspi-config nonint do_hostname ${this_hostname}

# set destination Hostname
read -p "Destination Hostname :" dest_host_name

# Get a valid ip address

while :
do
  read -p "Destination IP Address :" ip_address
  valid_ip $ip_address
    if [ $? -eq 0 ]
        then
                echo "Address Valid"
                break
        else
                echo "Invalid Address - Please Try Again"
    fi
done

# insert/update hosts entry for the default site

# find existing instances in the host file and save the line numbers
matches_in_hosts="$(grep -n $dest_host_name /etc/hosts | cut -f1 -d:)"
echo $matches_in_hosts
host_entry="${ip_address} ${dest_host_name}"
echo $host_entry
echo "Please enter your password if requested."

if [ ! -z "$matches_in_hosts" ]
then
    echo "Updating existing hosts entry."
    # iterate over the line numbers on which matches were found
    while read -r line_number; do
        # replace the text of each line with the desired host entry
        sudo sed -i "${line_number}s/.*/${host_entry} /" /etc/hosts
    done <<< "$matches_in_hosts"
else
    echo "Adding new hosts entry."
    echo "$dest_host_entry" | sudo tee -a /etc/hosts > /dev/null
fi

sudo cp autostart.txt /etc/xdg/openbox/autostart

matches_in_autostart="$(grep -n duet3 /etc/xdg/openbox/autostart | cut -f1 -d:)"

if [ ! -z "$matches_in_autostart" ]
then
    echo "Updating existing Autostart hostname."
    # iterate over the line numbers on which matches were found
    while read -r line_number; do
        # replace the text of each line with the desired host entry
        #sudo sed -i "${line_number}s/.*/'chromium-browser --disable-infobars --kiosk http://${host_name}' " /etc/xdg/openbox/autostart
        sed -e "${line_number}s/duet3/${dest_host_name}/" /etc/xdg/openbox/autostart

    done <<< "$matches_in_autostart"
fi
# use the profile to do the auto start of the browser 
echo '[[ -z $DISPLAY && $XDG_VTNR -eq 1 ]] && startx --' >> ~/.bash_profile

