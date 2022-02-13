#!/bin/bash

# Colors
GRN='\033[32m'
YLO='\033[1;33m'
RED='\033[31m'
RST='\033[0m'

while :
do
	echo -e "${GRN}1. Apache2"
	echo -e "2. Nginx"
	echo -e -n "[*] Which server you want to install: ${RST}"
	read SERVER

	if [[ ${SERVER} == 1 ]];
	then
		sudo apt install apache2 apache2-utils libapache2-mod-security 2> /dev/null
		echo -e "${GRN}[*] Installed apache2 and modsecurity.${RST}"
	
	elif [[ ${SERVER} == 2 ]];
	then 
		sudo apt install nginx apache2-utils 2> /dev/null
		echo -e "${GRN}[*] Installed nginx.${RST}"
	
	else
		echo -e "${RED}[!] Enter a valid input.${RST}"
		continue
	fi

	cd ${HOME}
	git clone https://github.com/CyberVarun/webserver-config.git

	echo -e "${RED}[!] Caution this should not be run on actual production server or your main computer.${RST}"

	if [[ ${SERVER} == 1 ]];
	then
		sudo cp -i webserver-config/apache2/apache2.conf /etc/apache2/ 

		if [[ $? == 0 ]];
		then
			echo -e "${GRN}[*] Replaced apache2 default configuration file with new configuration file.${RST}"
		else
			echo -e "${RED}[!] Unable to install new configuration.${RST}"
		fi

		echo -e "${GRN}[*] Installing modsecurity new rule set from owasp coreruleset.${RST}"
		git clone https://github.com/coreruleset/coreruleset.git

		echo -e "${YLO}[!] Taking backup of default modsecurity conf files.${RST}"
		sudo mv /usr/share/modsecurity-crs /usr/share/modsecurity-crs-backup
		echo -e "${GRN}[*] Backup is successfully taken. (/usr/share/modsecurity-crs-backup)${RST}"
		
		echo -e "${GRN}[*] Installing new modsecurity rule set."
		mv coreruleset/crs-setup.conf.example coreruleset/crs-setup.conf 
		sudo cp -r -i coreruleset /usr/share/modsecurity-crs

		if [[ $? == 0 ]];
		then
			echo -e "${GRN}[*] Installed new modsecurity rule set successfully.${RST}"
			break
		else
			echo -e "${RED}[!] Unable to install new modsecurity rule set"
			break
		fi 
	
	elif [[ ${SERVER} == 2 ]];
	then
		sudo cp -i webserver-config/nginx/nginx.conf /etc/nginx

		if [[ $? == 0 ]]
		then
			echo -e "${GRN}[*] Replaced nginx default configuration file with new configuration file.${RST}"
			break
		else
			echo -e "${RED}[!] Unable to install new configuration.${RST}"
			break
		fi
	fi

	echo -e -n "[*] Have you installed any firewall(y/n): "
	read FIREWALL

	if [[ ${FIREWALL} == y || ${FIREWALL} == Y ]];
	then
		echo -e "${YLO}[!] If you installed any firewall except fail2ban then please remove or disable it because it may overwrite firewall rules."
		break
	
	elif [[ ${FIREWALL} == n || ${FIREWALL} == N ]];
	then
		echo -e "${GRN}[*] Installing firewall (fail2ban) for secure logins.${RST}"
		sudo apt install fail2ban iptables > /dev/null 2>&1
		sudo cp -i webserver-config/fail2ban/jail.local /etc/fail2ban/
		sudo systemctl start fail2ban
		
		if [[ $? == 0 ]];
		then
			echo -e "${GRN}[*] Installed and started fail2ban successfully.${RST}"
			echo -e "${GRN}[*] By default fail2ban will only ban ip that does more than 3 wrong attempts for ssh. It will be baned for 1 day."
		else
			echo -e "${RED}[!] Failed to install or start to fail2ban.${RST}"
		fi
	fi

done