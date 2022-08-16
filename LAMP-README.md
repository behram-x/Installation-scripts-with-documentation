CREATING A DEDICATED MYSQL USER AND GRANTING PRIVILEGES

In Ubuntu systems running MySQL 5.7 (and later versions), the root MySQL user is set to authenticate using the auth_socket plugin by default rather than with a password. This plugin requires that the name of the operating system user that invokes the MySQL client matches the name of the MySQL user specified in the command, so you must invoke mysql with sudo privileges to gain access to the root MySQL user:

mysql

Note: If you installed MySQL with another tutorial and enabled password authentication for root, you will need to use a different command to access the MySQL shell. The following will run your MySQL client with regular user privileges, and you will only gain administrator privileges within the database by authenticating:

mysql -u root -p

Once you have access to the MySQL prompt, you can create a new user with a CREATE USER statement. These follow this general syntax:

CREATE USER 'username'@'host' IDENTIFIED WITH authentication_plugin BY 'password';

After CREATE USER, you specify a username. This is immediately followed by an @ sign and then the hostname from which this user will connect. If you only plan to access this user locally from your Ubuntu server, you can specify localhost. Wrapping both the username and host in single quotes isn’t always necessary, but doing so can help to prevent errors

As an alternative, you can leave out the WITH authentication_plugin portion of the syntax entirely to have the user authenticate with MySQL’s default plugin, caching_sha2_password. The MySQL documentation recommends this plugin for users who want to log in with a password due to its strong security features.

Run the following command to create a user that authenticates with caching_sha2_password. Be sure to change sammy to your preferred username and password to a strong password of your choosing:

CREATE USER 'sammy'@'localhost' IDENTIFIED BY 'password';

Note: There is a known issue with some versions of PHP that causes problems with caching_sha2_password. If you plan to use this database with a PHP application  phpMyAdmin, for example  you may want to create a user that will authenticate with the older, though still secure, mysql_native_password plugin instead:

CREATE USER 'sammy'@'localhost' IDENTIFIED WITH mysql_native_password BY 'password';

If you aren’t sure, you can always create a user that authenticates with caching_sha2_plugin and then ALTER it later on with this command:

ALTER USER 'sammy'@'localhost' IDENTIFIED WITH mysql_native_password BY 'password';

After creating your new user, you can grant them the appropriate privileges. The general syntax for granting user privileges is as follows:

GRANT PRIVILEGE ON database.table TO 'username'@'host';

To illustrate, the following command grants a user global privileges to CREATE, ALTER, and DROP databases, tables, and users, as well as the power to INSERT, UPDATE, and DELETE data from any table on the server. It also grants the user the ability to query data with SELECT, create foreign keys with the REFERENCES keyword, and perform FLUSH operations with the RELOAD privilege. However, you should only grant users the permissions they need, so feel free to adjust your own user’s privileges as necessary.

You can find the full list of available privileges in the official MySQL documentation.

Run this GRANT statement, replacing sammy with your own MySQL user’s name, to grant these privileges to your user:

GRANT CREATE, ALTER, DROP, INSERT, UPDATE, DELETE, SELECT, REFERENCES, RELOAD on *.* TO 'sammy'@'localhost' WITH GRANT OPTION;

Note that this statement also includes WITH GRANT OPTION. This will allow your MySQL user to grant any permissions that it has to other users on the system.

Following this, it’s good practice to run the FLUSH PRIVILEGES command. This will free up any memory that the server cached as a result of the preceding CREATE USER and GRANT statements:

FLUSH PRIVILEGES;

In the future, to log in as your new MySQL user, you’d use a command like the following:

mysql -u behram -p

The -p flag will cause the MySQL client to prompt you for your MySQL user’s password in order to authenticate


SECURING MYSQL

sudo mysql_secure_installation

This will ask if you want to configure the VALIDATE PASSWORD PLUGIN.

Note: Enabling this feature is something of a judgment call. If enabled, passwords which don’t match the specified criteria will be rejected by MySQL with an error. It is safe to leave validation disabled, but you should always use strong, unique passwords for database credentials.

Answer Y for yes, or anything else to continue without enabling.

VALIDATE PASSWORD PLUGIN can be used to test passwords
and improve security. It checks the strength of password
and allows the users to set only those passwords which are
secure enough. Would you like to setup VALIDATE PASSWORD plugin?

Press y|Y for Yes, any other key for No:

If you answer “yes”, you’ll be asked to select a level of password validation. Keep in mind that if you enter 2 for the strongest level, you will receive errors when attempting to set any password which does not contain numbers, upper and lowercase letters, and special characters, or which is based on common dictionary words.

There are three levels of password validation policy:

LOW    Length >= 8
MEDIUM Length >= 8, numeric, mixed case, and special characters
STRONG Length >= 8, numeric, mixed case, special characters and dictionary              file

Please enter 0 = LOW, 1 = MEDIUM and 2 = STRONG: 1

Regardless of whether you chose to set up the VALIDATE PASSWORD PLUGIN, your server will next ask you to select and confirm a password for the MySQL root user. This is not to be confused with the system root. The database root user is an administrative user with full privileges over the database system. Even though the default authentication method for the MySQL root user dispenses the use of a password, even when one is set, you should define a strong password here as an additional safety measure. We’ll talk about this in a moment.

If you enabled password validation, you’ll be shown the password strength for the root password you just entered and your server will ask if you want to continue with that password. If you are happy with your current password, enter Y for “yes” at the prompt:

Estimated strength of the password: 100 
Do you wish to continue with the password provided?(Press y|Y for Yes, any other key for No) : y

For the rest of the questions, press Y and hit the ENTER key at each prompt. This will remove some anonymous users and the test database, disable remote root logins, and load these new rules so that MySQL immediately respects the changes you have made.

When you’re finished, test if you’re able to log in to the MySQL console by typing:

sudo mysql

This will connect to the MySQL server as the administrative database user root, which is inferred by the use of sudo when running this command. You should see output like this:

Output

Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 22
Server version: 8.0.19-0ubuntu5 (Ubuntu)

Copyright (c) 2000, 2020, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> 

To exit the MySQL console, type:

exit

CREATING A VIRTUAL HOST FOR YOUR WEBSITE


When using the Apache web server, you can create virtual hosts (similar to server blocks in Nginx) to encapsulate configuration details and host more than one domain from a single server. In this guide, we’ll set up a domain called your_domain, but you should replace this with your own domain name.

Note: In case you are using DigitalOcean as DNS hosting provider, you can check our product docs for detailed instructions on how to set up a new domain name and point it to your server.

Apache on Ubuntu 20.04 has one server block enabled by default that is configured to serve documents from the /var/www/html directory. While this works well for a single site, it can become unwieldy if you are hosting multiple sites. Instead of modifying /var/www/html, we’ll create a directory structure within /var/www for the your_domain site, leaving /var/www/html in place as the default directory to be served if a client request doesn’t match any other sites.

Create the directory for your_domain as follows:

sudo mkdir /var/www/your_domain

Next, assign ownership of the directory with the $USER environment variable, which will reference your current system user:

sudo chown -R $USER:$USER /var/www/your_domain

Then, open a new configuration file in Apache’s sites-available directory using your preferred command-line editor. Here, we’ll use nano:

sudo nano /etc/apache2/sites-available/your_domain.conf

This will create a new blank file. Paste in the following bare-bones configuration:

/etc/apache2/sites-available/your_domain.conf

<VirtualHost *:80>

    ServerName your_domain
    
    ServerAlias www.your_domain 
    
    ServerAdmin webmaster@localhost
    
    DocumentRoot /var/www/your_domain
    
    ErrorLog ${APACHE_LOG_DIR}/error.log
    
    CustomLog ${APACHE_LOG_DIR}/access.log combined
    
</VirtualHost>

Save and close the file when you’re done. If you’re using nano, you can do that by pressing CTRL+X, then Y and ENTER.

With this VirtualHost configuration, we’re telling Apache to serve your_domain using /var/www/your_domain as the web root directory. If you’d like to test Apache without a domain name, you can remove or comment out the options ServerName and ServerAlias by adding a # character in the beginning of each option’s lines.

You can now use a2ensite to enable the new virtual host:

sudo a2ensite your_domain

You might want to disable the default website that comes installed with Apache. This is required if you’re not using a custom domain name, because in this case Apache’s default configuration would overwrite your virtual host. To disable Apache’s default website, type:

sudo a2dissite 000-default

To make sure your configuration file doesn’t contain syntax errors, run:

sudo apache2ctl configtest

Finally, reload Apache so these changes take effect:

sudo systemctl reload apache2

Your new website is now active, but the web root /var/www/your_domain is still empty. Create an index.html file in that location so that we can test that the virtual host works as expected:

nano /var/www/your_domain/index.html

Include the following content in this file:

/var/www/your_domain/index.html

<html>
  <head>
    <title>your_domain website</title>
  </head>
  <body>
    <h1>Hello World!</h1>

    <p>This is the landing page of <strong>your_domain</strong>.</p>
  </body>
</html>

Now go to your browser and access your server’s domain name or IP address once again:

http://server_domain_or_IP


Apache virtual host test

If you see this page, it means your Apache virtual host is working as expected.

You can leave this file in place as a temporary landing page for your application until you set up an index.php file to replace it. Once you do that, remember to remove or rename the index.html file from your document root, as it would take precedence over an index.php file by default.

A Note About DirectoryIndex on Apache

With the default DirectoryIndex settings on Apache, a file named index.html will always take precedence over an index.php file. This is useful for setting up maintenance pages in PHP applications, by creating a temporary index.html file containing an informative message to visitors. Because this page will take precedence over the index.php page, it will then become the landing page for the application. Once maintenance is over, the index.html is renamed or removed from the document root, bringing back the regular application page.

In case you want to change this behavior, 

you’ll need to edit the /etc/apache2/mods-enabled/dir.conf file and modify the order in which the index.php file is listed within the DirectoryIndex directive:

sudo nano /etc/apache2/mods-enabled/dir.conf

/etc/apache2/mods-enabled/dir.conf

<IfModule mod_dir.c>

        DirectoryIndex index.php index.html index.cgi index.pl index.xhtml index.htm
        
</IfModule>

After saving and closing the file, you’ll need to reload Apache so the changes take effect:

sudo systemctl reload apache2

In the next step, we’ll create a PHP script to test that PHP is correctly installed and configured on your server.

TESTING PHP PROCESSING ON YOUR WEB SERVER

Now that you have a custom location to host your website’s files and folders, we’ll create a PHP test script to confirm that Apache is able to handle and process requests for PHP files.

Create a new file named info.php inside your custom web root folder:

nano /var/www/your_domain/info.php

This will open a blank file. Add the following text, which is valid PHP code, inside the file:

/var/www/your_domain/info.php
<?php
phpinfo();

When you are finished, save and close the file.

To test this script, go to your web browser and access your server’s domain name or IP address, followed by the script name, which in this case is info.php:

http://server_domain_or_IP/info.php


This page provides information about your server from the perspective of PHP. It is useful for debugging and to ensure that your settings are being applied correctly.

If you can see this page in your browser, then your PHP installation is working as expected.

After checking the relevant information about your PHP server through that page, it’s best to remove the file you created as it contains sensitive information about your PHP environment and your Ubuntu server. You can use rm to do so:

sudo rm /var/www/your_domain/info.php

You can always recreate this page if you need to access the information again later.
