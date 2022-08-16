#Jenkins Installation

#! /bin/bash

# exit when any command fails
set -e

# keep track of the last executed command
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
# echo an error message before exiting
trap 'echo "\"${last_command}\" command filed with exit code $?."' EXIT

#It is recommended that you install OpenJDK from the default repositories. Open a terminal window and enter the following:
#Jenkins will not get installed if the JDK is missing
echo "Installing JDK"

apt update
apt install openjdk-11-jdk -y

#Add the Jenkins Repository

echo "Adding Jenkins Repository"

#1. Start by importing the GPG key:

curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null

#2. Next, add the Jenkins software repository to the sources list and provide the key for authentication:

echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

#Install Jenkins

echo "Installing jenkins"

apt update
apt install jenkins -y

echo -e "\n\n\n\n\n"
echo "**********************************************************"
echo "Installation done"
echo "**********************************************************"
echo "Verifying Jenkins Status"
echo "Press Q to Exit after verification"
systemctl status jenkins
echo "Set up Jenkins"
echo "To launch and set up Jenkins, open a web browser, and navigate to the IP address of your server
for eg. http://ip_address_or_domain:8080"
echo "You should see a page that prompts you to Unlock Jenkins. use this password"
cat /var/lib/jenkins/secrets/initialAdminPassword

