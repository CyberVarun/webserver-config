#!/bin/bash

# Colors
GRN='\033[32m'
YLO='\033[1;33m'
RED='\033[31m'
CYN='\033[36m'
RST='\033[0m'

FIREWALL_INSTALL (){
        echo -e "${GRN}[*] Installing firewall (fail2ban) for secure logins.${RST}"
        sudo apt install fail2ban iptables -y 2> /dev/null
        sudo cp -i fail2ban/jail.local /etc/fail2ban/
        echo -e "${GRN}[*] Starting fail2ban and enabling.\n"
        sudo systemctl start fail2ban && sudo systemctl enable fail2ban
                
        if [[ $? == 0 ]];
        then
                echo -e "\n${GRN}[*] Installed and started fail2ban successfully.${RST}"
                echo -e "${GRN}[*] By default fail2ban will only ban ip that does more than 3 wrong attempts for ssh. It will be baned for 1 day.${CYN}\n"
                sudo fail2ban-client status sshd
        else
                echo -e "${RED}[!] Failed to install or start to fail2ban.${RST}\n"
        fi
}

while :
do	
	echo -e "${RED}[!] Caution this should not be run on actual production server or your main computer.${RST}\n"

	echo -e "${GRN}[*]1. Apache2"
	echo -e "[*]2. Nginx"
	echo -e -n "[*] Which server you want to install: ${RST}"
	read SERVER

	if [[ ${SERVER} == 1 ]];
	then
		echo -e "\n${GRN}[*] Updating system & installing apache2, libapache2-mod-security${RST}"
		sudo apt update > /dev/null 2>&1
		sudo apt install apache2 apache2-utils libapache2-mod-security2 -y 2> /dev/null
		echo -e "${GRN}[*] Installed apache2 and modsecurity.${RST}\n"
	
	elif [[ ${SERVER} == 2 ]];
	then 
		echo -e "${GRN}[*] Updating system & nginx${RST}"
		sudo update > /dev/null 2>&1
		sudo apt install nginx apache2-utils -y 2> /dev/null
		echo -e "${GRN}[*] Installed nginx.${RST}\n"
	
	else
		echo -e "${RED}[!] Enter a valid input.${RST}\n"
		continue
	fi

	if [[ ${SERVER} == 1 ]];
	then
		echo -e "${YLO}[!] Taking backup of defautl apache2 conf file.(/etc/apache2/apache2.conf.backup)${RST}\n"
		sudo cp /etc/apache2/apache2.conf /etc/apache2/apache2.conf.backup
		echo -e "${GRN}[*] Installing new configuration files.${RST}"
		sudo cp -i apache2/apache2.conf /etc/apache2/ && sudo cp -i apache2/000-default.conf /etc/apache2/sites-available/
		
		if [[ $? == 0 ]];
		then
			echo -e "${GRN}[*] Installed new configuration files successfully${RST}\n"
		else
			echo -e "${RED}[!] Unable to install new configuration.${RST}\n"
		fi

		echo -e "${GRN}[*] Installing modsecurity new rule set from owasp coreruleset.${RST}\n"
		git clone https://github.com/coreruleset/coreruleset

		echo -e "${YLO}[!] Taking backup of default modsecurity conf files.${RST}\n"
		sudo mv /usr/share/modsecurity-crs /usr/share/modsecurity-crs-backup

		if [[ $? == 0 ]];
		then
			echo -e "${GRN}[*] Backup is successfully taken. (/usr/share/modsecurity-crs-backup)${RST}\n"
		else
			echo -e "${RED}[!] Unable to create backup.${RST}"
		fi

		suod rm -rf /usr/share/modsecurity-crs > /dev/null 2>&1
		
		echo -e "${GRN}[*] Installing new modsecurity rule set.\n"
		mv coreruleset/crs-setup.conf.example coreruleset/crs-setup.conf 
		sudo mv coreruleset /usr/share/modsecurity-crs && sudo cp apache2/modsecurity.conf /etc/modsecurity/

		if [[ $? == 0 ]];
		then
			echo -e "${GRN}[*] Installed new modsecurity rule set successfully.${RST}\n"
		else
			echo -e "${RED}[!] Unable to install new modsecurity rule set\n"
			break
		fi 
	
	elif [[ ${SERVER} == 2 ]];
	then
		sudo cp -i nginx/nginx.conf /etc/nginx/

		if [[ $? == 0 ]]
		then
			echo -e "${GRN}[*] Replaced nginx default configuration file with new configuration file.${RST}\n"
			break
		else
			echo -e "${RED}[!] Unable to install new configuration.${RST}\n"
			break
		fi
	fi

	echo -e -n "${YLO}[*] Have you installed any firewall(y/N): "
	read FIREWALL

	if [[ ${FIREWALL} == y || ${FIREWALL} == Y ]];
	then
		echo -e "${YLO}[!] If you installed any firewall except fail2ban then please remove or disable it because it may overwrite firewall rules.\n"
		echo -e -n "${GRN}[*] Disable/uninstall the firewall and type "y/Y" and enter: "
		read ANS

		if [[ ${ANS} == Y || ${ANS} == y ]];
		then
			FIREWALL_INSTALL
			break
		else
			echo -e "${RED}[!] Not installed any firewall."
			break
		fi
		
	elif [[ ${FIREWALL} == n || ${FIREWALL} == N ]];
	then
		FIREWALL_INSTALL
		break
	fi

done
