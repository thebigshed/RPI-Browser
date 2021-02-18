#!/bin/bash
# raspi-config changes
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


# insert/update hosts entry for the default site
ip_address="192.168.xxx.xxx"
host_name="duet3"


# find existing instances in the host file and save the line numbers
matches_in_hosts="$(grep -n $host_name /etc/hosts | cut -f1 -d:)"
host_entry="${ip_address} ${host_name}"

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
    echo "$host_entry" | sudo tee -a /etc/hosts > /dev/null
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
        sed -e "${line_number}s/duet3/${host_name}/" /etc/xdg/openbox/autostart

    done <<< "$matches_in_autostart"
fi
# not working at present....
echo '[[ -z $DISPLAY && $XDG_VTNR -eq 1 ]] && startx --' >> ~/.bash_profile

