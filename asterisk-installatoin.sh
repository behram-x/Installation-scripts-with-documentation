#Asterisk installation

#! /bin/bash

#update the system first
echo "Updating system"
sudo apt update && sudo apt -y upgrade

#Install Asterisk 18 LTS dependencies

echo "installing Dependenices"

sudo apt -y install git curl wget libnewt-dev libssl-dev libncurses5-dev subversion  libsqlite3-dev build-essential libjansson-dev libxml2-dev  uuid-dev

#If you get an error for subversion package on Ubuntu like below:
#E: Package 'subversion' has no installation candidate
#Then add universe repository and install subversion from it:

sudo add-apt-repository universe
sudo apt update && sudo apt -y install subversion

#Download Asterisk 18 LTS tarball
#Download the latest release of Asterisk # LTS to your local system for installation.
cd /usr/src/

echo "Downloading Asterisk"
sudo curl -O http://downloads.asterisk.org/pub/telephony/asterisk/asterisk-18-current.tar.gz
echo "Extracting File"
sudo tar xvf asterisk-18-current.tar.gz
#Got to asterisk directory
cd asterisk-18.9.0

#Run the following command to download the mp3 decoder library into the source tree.

echo "Downloading mp3 decoder library into source tree"

sudo contrib/scripts/get_mp3_source.sh

echo "Ensuring all dependencies are resolved"

sudo contrib/scripts/install_prereq install

#You should get a success message at the end.

#Build and Install Asterisk

echo "Building and installing asterisk"

#Run the configure script to satisfy build dependencies.
sudo ./configure

#Setup menu options by running the following command

echo "Select menu options"

sudo make menuselect

#You can select configurations you see fit. When done, save and exit then install Asterisk with selected modules.

echo "Building asterisk"

sudo make

echo "Installing asterisk"

sudo make install

echo "Making progdocs"

sudo make progdocs

echo "Installing configs and samples"
sudo make samples
sudo make config
sudo ldconfig

echo "starting asterisk service"

systemctl start asterisk

#Create a separate user and group to run asterisk services, and assign correct permissions

echo "Creating a separate user and group to run asterisk services and assiging correct permissions"

sudo groupadd asterisk
sudo useradd -r -d /var/lib/asterisk -g asterisk asterisk
sudo usermod -aG audio,dialout asterisk
sudo chown -R asterisk.asterisk /etc/asterisk
sudo chown -R asterisk.asterisk /var/{lib,log,spool}/asterisk
sudo chown -R asterisk.asterisk /usr/lib/asterisk

echo "Edit the file with the following
#AST_USER="asterisk"
#AST_GROUP="asterisk"
"
sudo vim /etc/default/asterisk


echo "Edit the file with the following

#runuser = asterisk ; The user to run as.
#rungroup = asterisk ; The group to run as."

sudo vim /etc/asterisk/asterisk.conf

echo "Restarting asterisk service"

sudo systemctl restart asterisk

echo "Enabling asterisk service to start on boot"

sudo systemctl enable asterisk

echo "Checking service status to see if it is running."

systemctl status asterisk



echo -e "\n\n\n\n"
echo "**********************************************************"
echo "Installation done"
echo "**********************************************************"

echo "connecting to asterisk"

sudo asterisk -rvv

#If you have an active ufw firewall, open http ports and ports 5060,5061:

