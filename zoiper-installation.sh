#zoiper installation
#download the package form official website

#! /bin/bash

#In the Downloads folder, run the dpkg tool to install the package.
cd /Downloads
echo "unpacking zoiper"
dpkg -i zoiper5_5.*_x86_64.deb

#As you load up dpkg, keep in mind that dependencies may fail to install. To correct this issue, run the apt install command with the “f” switch.

echo "installing zoiper"
apt install -f

echo -e "\n\n\n\n\n\n\n\n"
echo "**********************************************************"
echo "Installation done"
echo "**********************************************************"
