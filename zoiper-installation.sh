#!/bin/bash
# exit when any command fails
set -e

# keep track of the last executed command
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
# echo an error message before exiting
trap 'echo "\"${last_command}\" command filed with exit code $?."' EXIT

#zoiper installation
#Download the package form official website

echo "unpacking zoiper"
dpkg -i Zoiper5_5.5.9_x86_64.deb

#As you load up dpkg, keep in mind that dependencies may fail to install. To correct this issue, run the apt install command with the “f” switch.

echo "installing zoiper"
apt install -f

echo -e "\n\n\n\n"
echo "**********************************************************"
echo "Installation done"
echo "**********************************************************"
