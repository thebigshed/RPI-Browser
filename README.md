# RPI-Browser

Automatic configuration of RPI to be a browser
opens in kiosk mode and goes to the defined address in the script.

use the RPI light image, do an update and install git

sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install git

git clone https://github.com/thebigshed/RPI-Browser.git

chmod +x browser.sh

use your favorite editor to change IP_ADDRESS and HOSTNAME for the site you are going to connect too.
Save your file and...

./browser.sh

Now you will have to wait........

once finished check for anything looking like an error then reboot

sudo reboot

when the RPI restarts the browser will open in full kiosk mode and be directed to your website / selected destination.
