#Asterisk installation

#! /bin/bash

# exit when any command fails
set -e

# keep track of the last executed command
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
# echo an error message before exiting
trap 'echo "\"${last_command}\" command filed with exit code $?."' EXIT

#update the system first
echo "Updating system"
apt update && sudo apt -y upgrade

#Install Asterisk 18 LTS dependencies

echo "installing Dependenices"

apt -y install git curl wget libnewt-dev libssl-dev libncurses5-dev subversion  libsqlite3-dev build-essential libjansson-dev libxml2-dev  uuid-dev
apt -y install lsof telnet tree screen htop sngrep

#If you get an error for subversion package on Ubuntu like below:
#E: Package 'subversion' has no installation candidate
#Then add universe repository and install subversion from it:

add-apt-repository universe
apt update && sudo apt -y install subversion

#Download Asterisk 18 LTS tarball
#Download the latest release of Asterisk # LTS to your local system for installation.
cd /usr/src/

echo "Downloading Asterisk"
curl -O http://downloads.asterisk.org/pub/telephony/asterisk/asterisk-18-current.tar.gz
echo "Extracting File"
tar xvf asterisk-18-current.tar.gz
#Got to asterisk directory
cd asterisk-18.*

#/Run the following command to download the mp3 decoder library into the source tree.

echo "Downloading mp3 decoder library into source tree"

contrib/scripts/get_mp3_source.sh

echo "Ensuring all dependencies are resolved"

contrib/scripts/install_prereq install

#You should get a success message at the end.

#Build and Install Asterisk

echo "Building and installing asterisk"

#Run the configure script to satisfy build dependencies.
./configure

#Setup menu options by running the following command

echo "Select menu options"

make menuselect

#You can select configurations you see fit. When done, save and exit then install Asterisk with selected modules.

echo "Building asterisk"

make -j3

echo "Installing asterisk"

make install

echo "Installing configs and samples"
make samples
make config
ldconfig

echo "starting asterisk service"

systemctl start asterisk

#Create a separate user and group to run asterisk services, and assign correct permissions

echo "Creating a separate user and group to run asterisk services and assiging correct permissions"

groupadd asterisk
useradd -r -d /var/lib/asterisk -g asterisk asterisk
usermod -aG audio,dialout asterisk
chown -R asterisk.asterisk /etc/asterisk
chown -R asterisk.asterisk /var/{lib,log,spool}/asterisk
chown -R asterisk.asterisk /usr/lib/asterisk

nano /etc/default/asterisk

echo "Edit the file with the following
#AST_USER="asterisk"
#AST_GROUP="asterisk"
"

nano /etc/asterisk/asterisk.conf

echo "Edit the file with the following

#runuser = asterisk ; The user to run as.
#rungroup = asterisk ; The group to run as."

echo "Configuring Start Script"

cd /usr/src/asterisk-18.*

cd /contrib/init.d

cp rc.debian.asterisk /etc/init.d/asterisk

echo "edit the copied rc.debian.asterisk file with.

#Full path to asterisk binary
#DAEMON=/usr/sbin/asterisk (type asterisk command is used to get the asterisk directory)
#ASTVARRUNDIR=/var/run/asterisk
#ASTETCDIR=/etc/asterisk
#TRUE=/bin/true."

nano /etc/init.d/asterisk

#To run asterisk type asterisk -r

echo "Enabling asterisk service to start on boot"

systemctl enable asterisk

echo -e "\n\n\n\n"
echo "**********************************************************"
echo "Installation done"
echo "**********************************************************"

echo "connecting to asterisk"

asterisk -rvv

#If you have an active ufw firewall, open http ports and ports 5060,5061:
