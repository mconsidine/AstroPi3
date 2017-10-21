#!/bin/bash
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "Welcome to the KStars/INDI Linux Script"
echo "This will create udev rules that will allow multiple devices based on serial/tty communications to have consistent names when they are connected."
echo "This script will place a rule in /lib/udev/rules.d/99-<device name>.rules so that when you connect this device to this computer, it can be accessed via a symlink name like /dev/moonlite instead of having to use /dev/ttyusb0"
echo "Please Plug in only the device for which you want to make a udev rule."
read -p "Hit [Enter] when you are ready" ready

#This will ask the user for a long name for the device
echo "Please type a descriptive name for this device.  For Example:  MoonLite Focuser "
read -p "Descriptive name: " longName
#This will ask the user for the symlink name for the device
echo "Please type a unique short name for this device that will be used to make the symlink as well as for the name of the udev rule file. It should have no spaces or special characters.  For example: focuser or moonlite.  But you might want to check that you don't have any other udev rules with the same name in /lib/udev/rules.d/"
read -p "symlink name: " symlink


#This will get the vendor id of the device
vendor=$(udevadm info -a -n /dev/ttyUSB0 | grep '{idVendor}' | head -n1)

#This will get the product identifier of the device
product=$(udevadm info -a -n /dev/ttyUSB0 | grep '{idProduct}' | head -n1)

#This will get the serial number of the device
serial=$(udevadm info -a -n /dev/ttyUSB0 | grep '{serial}' | head -n1)

echo "Here is the information that was collected for your $longName."
echo $vendor
echo $product
echo $serial
read -p "Do you wish to symlink the device with this information as /dev/$symlink y/n?" save

if [ "$save" != "y" ]
then
	exit
fi

# This will create the udev rule file
sudo cat > /lib/udev/rules.d/99-$symlink.rules <<- EOF
# $longName udev rule                                                                                                                                                                                                                     
SUBSYSTEMS=="usb", $vendor, $product, $serial, MODE="0666", SYMLINK+="$symlink"
EOF

echo "Script finished.  You should now have a udev rule file located at /lib/udev/rules.d/99-$symlink.rules.  And you should now have a symlink called /dev/$symlink that will identify your device.  You may need to restart for this to take effect."