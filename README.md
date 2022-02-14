# <span style="color: red;">Disclaimer</span>

These files are not created for production server. This are created for understanding basic server security. So don't use these files in production server and also don't test this files on main system as you may lock down your own system.

<hr>

## Summary

These are web server config file to sercure web servers and understanding basics of web server security. These only provide basic level like firewall, cronjobs and secure ssh.

<hr>

# Note 
By default it will create backups of your default configuration files.
But it will still ask for overwrite permission. So if want you want create backup manually You will get a chance to do that. 
<hr>

## Installation

Directly download release from <a href="https://github.com/CyberVarun/webserver-config/releases/download/v0.1/install.sh">here</a>

or 
```
git clone https://github.com/CyberVarun/webserver-config
cd webserver-config
bash setup.sh
```
<hr>

## Owasp coreruleset
Modsecurity default rule set will be replaced with owasp coreruleset for apache2 only. You can get more about owasp coreruleset <a href="https://github.com/coreruleset/coreruleset">here</a> 

<hr>

## Apache2
By default script will install apache2 with modsecurity. And the default rule set of modsecurity will be replaced by owasp coreruleset to give more security.

## Nginx
Nginx will have its default but modified configuration.

<hr>

## Fail2ban
It's highly recommend to have a firewall so this will install fail2ban. And by default fail2ban is configured to block ssh connections. If anyone attempts to brute force ssh login or if anyone fails to authenticate more than 3 times it will ban its IP for 1 day. 

<hr>

## Virtual host
By default virtual files will not be installed. So if want install it just copy the following file into:

###### Apache2 
site.com.conf > /etc/apache2/sites-available/
###### Nginx
site.com > /etc/nginx/sites-available/

And enable them with command:<br>
`sudo a2ensite filename` 

make sure that you have disabled the default files(000-default.conf). If you haven't then use command:<br>
`sudo a2dissite filename` 

do disable 
