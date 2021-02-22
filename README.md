# RPI-Browser

Automatic configuration of RPI to be a browser
opens in kiosk mode and goes to the defined address in the script.

use the RPI light image, do an update and install git

sudo apt-get update

sudo apt-get upgrade -y

sudo apt-get install git

git clone https://github.com/thebigshed/RPI-Browser.git

cd RPI-Browser

chmod +x browser.sh

./browser.sh

the script will prompt you for (use your settings):

Current Password : raspberry
New Password (twice) : ?????
A host name for this machine I called mine: Browser
A host name for the device I am connecting to : Duet
An IP address (assumed to be static) to connect to : 192.168.1.1
A port on the device : 8080

the script will then do the updates, installs and configuration of your box and then reboot and go directly to the site you specified.

if you have issues then CRTL ALT with Backspace will kill the xserver and leave you at a command prompt.
