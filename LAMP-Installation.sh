#LAMP installation

#! /bin/bash

# exit when any command fails
set -e

# keep track of the last executed command
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG


#update the system first
echo "Updating system"
apt update && sudo apt -y upgrade

#Install Apache with 

echo "Installing Apache 2"

apt install apache2 -y

#Once the installation is finished, you’ll need to adjust your firewall settings to allow HTTP traffic. UFW has different application profiles that you can leverage for accomplishing that. To list all currently available UFW application profiles, you can run:
#sudo ufw app list
#You’ll see output like this:

#Output
#Available applications:
 #Apache
 #Apache Full
 #Apache Secure
 #OpenSSH
#Here’s what each of these profiles mean:

#Apache: This profile opens only port 80 (normal, unencrypted web traffic).
#Apache Full: This profile opens both port 80 (normal, unencrypted web traffic) and port 443 (TLS/SSL encrypted traffic).
#Apache Secure: This profile opens only port 443 (TLS/SSL encrypted traffic).
#echo "Allowing Apache in firewall
#sudo ufw allow in "Apache"

#You can do a spot check right away to verify that everything went as planned by visiting your server’s public IP address in your web browser (see the note under the next heading to find out what your public IP address is if you do not have this information already):

#http://your_server_ip

#If you do not know what your server’s public IP address is, there are a number of ways you can find it. Usually, this is the address you use to connect to your server through SSH.

#There are a few different ways to do this from the command line. First, you could use the iproute2 tools to get your IP address by typing this:
#ip addr show eth0 | grep inet | awk '{ print $2; }' | sed 's/\/.*$//'

echo "Installing MySQL"
sudo apt install mysql-server -y

echo "Securing MySQL"

sudo mysql_secure_installation 

echo "Read LAMP-README.md file for futher details regarding Securing MySQL"

echo "Logging into MySQl Console"

mysql

echo "If you want to create a separate user check LAMP-README.md file"

echo "Installing PHP"

apt install php libapache2-mod-php php-mysql -y

echo "Checking PHP Version"

php -v

echo -e "\n\n\n\n"
echo "**********************************************************"
echo "Installation done"
echo "**********************************************************"

echo "Check The LAMP-README.md for creation of a Virtual Host for your Website"
