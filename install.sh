#!/bin/bash
#*******************************************************************************#
# Alex Moreno																	#
# 3/19/2018																		#
# This script insalls all apt-get app in addition to fstab and other settings	#
# Ver 2.0b - Started the script from scratch as I lost the original				#
# Ver 2.1b - Added conditional ststements to /etc/fstab nfs mounts				#
# Ver 2.2b - Created function "make_shortcut" to make shortcut for packages		#
# Notes: Android Development Studio Instant Run configuration					#
#        https://developer.android.com/studio/run/index.html#set-up-ir			#
#*******************************************************************************#

# Bash resources
#1.https://linuxacademy.com/blog/linux/conditions-in-bash-scripting-if-statements/


#*** Ubuntu 18.04 customizations for future 'new-ubuntu' script implementatioin ***#
# Nautilus: compact view
# test


clear

#********************** Function definitions starts ****************************#

function pause() {
   read -n 1 -s -r -p "Press any key to continue, or Ctrl + C to cancel."
}

function main_menu() {
	echo "#***********************************************************************#"
	echo "#				MENU:					#"
	echo "# Instructions: Choose one of the menu options by typing the items no:. #"
	echo "#									#"
	echo "# Select choice from 0-9						#"
	echo "# 1. Run all script.							#"
	echo "#    a) Adds keys (Google, Enpass, VirtualBox, Wine, etc...)		#"
	echo "#    b) Adds repositories (Google, Enpass, VirtualBox, Wine, etc...)	#"
	echo "#    c) Install application thru apt install				#"
	echo "#    d) Adds entries /etc/fstab entries for NFS shares.			#"
	echo "#    e) Downloads/installs thru wget (JDK, Android Development Studio,	#"
	echo "#       PyCharm, IntelliJ IDEA)						#"
	echo "# 2. Run current script test mode.					#"
	echo "# 3. Set MAC OS VirtualBox settings.					#"
	echo "# 9. Run test section of script.					#"
	echo "# 0. Exit script.							#"
	echo "#									#"
	echo "************************************************************************#"
	echo -n "Enter menu choice: "
	read menu_choice
} #main_menu

function second_menu() {
	echo "#***********************************************************************#"
	echo "#				MENU:					#"
	echo "# Instructions: Choose one of the menu options by typing the items no:. #"
	echo "#									#"
	echo "# Select choice from 0-6						#"
	echo "# 1) Run all script.							#"
	echo "# 2) Adds keys (Google, Enpass, VirtualBox, Wine, etc...)		#"
	echo "# 3) Adds repositories (Google, Enpass, VirtualBox, Wine, etc...)	#"
	echo "# 4) Install application thru apt install				#"
	echo "# 5) Adds entries /etc/fstab entries for NFS shares.			#"
	echo "# 6) Add custom settings.						#"
	echo "# 7) Downloads/installs thru wget (JDK, Android Development Studio,	#"
	echo "#    PyCharm, IntelliJ IDEA)						#"
	echo "************************************************************************#"
	echo -n "Enter menu choice: "
	read menu_choice2
} #second_menu

#***********************#
#***      Keys       ***#
#***********************#
function add_keys() {
	wget -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
	wget -O - https://dl.sinew.in/keys/enpass-linux.key | apt-key add -
	wget -nc https://dl.winehq.org/wine-builds/Release.key | apt-key add Release.key
	wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | apt-key add -
} #add_keys

#***********************#
#***   Repositories  ***#
#***********************#
function add_repos() {
	if [[ ! -e /etc/apt/sources.list.d/google-chrome.list ]]; then
		echo 'deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main' | tee /etc/apt/sources.list.d/google-chrome.list
	fi
	if [[ ! -e /etc/apt/sources.list.d/enpass.list ]]; then
		echo "deb http://repo.sinew.in/ stable main" > /etc/apt/sources.list.d/enpass.list
	fi
	if [[ ! -e /etc/apt/sources.list.d/virtualbox.list ]]; then
		echo "deb https://download.virtualbox.org/virtualbox/debian artful contrib" | tee /etc/apt/sources.list.d/virtualbox.list
	fi
	add-apt-repository -y ppa:webupd8team/gnome3  #This is for VLC
	add-apt-repository -y ppa:notepadqq-team/notepadqq
	add-apt-repository "https://dl.winehq.org/wine-builds/ubuntu/"
	apt -y update
	#https://launchpad.net/ubuntu/+ppas
} #add_repos

#***********************#
#***   apt install   ***#
#***********************#
function apt_install() {
	apt -y install google-chrome-stable \
		notepadqq \
		dconf-editor \
		nfs-common \
		enpass \
		virtualbox-5.2 \
		virtualbox-guest-additions-iso \
		gnome-tweak-tool \
		gimp \
		synaptic \
		usb-creator-gtk \
		libreoffice \
		chromium-browser \
		thunderbird \
		shotwell \
		ubuntu-restricted-extras \
		gnome-calendar \
		gnome-appfolders-manager \
		gnome-shell-extensions \
		gnome-contacts \
		vlc
	apt -y install --install-recommends winehq-stable
	#emacs
	#Qt - follow this link for instalation instructions: https://wiki.qt.io/Install_Qt_5_on_Ubuntu
	#gnome-appfolders-manager - https://www.omgubuntu.co.uk/2017/04/add-app-folders-gnome-shell-overview
	#gnome-shell-extensions - https://extensions.gnome.org/extension/21/workspace-indicator/ - Workspace Indicator
	#ubuntu-restricted-extras - contains decoders to play video
	#Qt Designer
} #apt_install

#***********************#
#***  fstab entries  ***#
#***********************#
function add_fstab() {
	#3/13/2018 NFS shares to Synology
	#3/26/2018 Added conditional
	#Added mkdir line -p to create dir and -p to ignore error if occurs
	changed=0
	my_date=`date +%Y%m%d%H%M%s`
	cp /etc/fstab /etc/fstab.$my_date
	if [[ ! -e fstab.log ]]; then
		rm fstab.log
		echo "deleted log file"
	fi
	if [[ ! -d  /mnt/myds ]]; then
		mkdir -p /mnt/myds
		echo "Mount point did not exist, created /mnt/myds" >> fatab.log
		echo "...continuing script." >> fatab.log
	else
		echo "Mount point "/mnt/myds" already exists, no action taken creating directory..." >> fatab.log
		echo "...continuing script." >> fatab.log
	fi
	if [[ $(grep "#Synology NFS shares" "/etc/fstab")=0 ]]
	then
	   echo "#Synology NFS shares" >> /etc/fstab
	   echo "Added Synology line comment to fstab" >> fatab.log
	   changed=1
	fi
	if [[ $(grep "10.0.0.5:/volume1/homes/alex2wr" "/etc/fstab")=1 ]]
	then
	   echo "10.0.0.5:/volume1/homes/alex2wr /mnt/myds/ \
	   nfs auto,nofail,noatime,nolock,intr,tcp,actimeo=1800 0 0" \
		>> /etc/fstab
	   echo "Added NFS mount point for 10.0.0.5:/volume1/homes/alex2wr" >> fatab.log
	   changed=1
	fi
	if [[ $(grep "10.0.0.5:/volume1/photo" "/etc/fstab")=1 ]]
	then
	    echo "10.0.0.5:/volume1/photo /home/alex2wr/Pictures \
	    nfs auto,nofail,noatime,nolock,intr,tcp,actimeo=1800 0 0" \
	    >> /etc/fstab
	    echo "Added NFS mount point for 10.0.0.5:/volume1/photo /home/alex2wr/Pictures" >> fatab.log
	    changed=1
	fi
	if [[ $(grep "10.0.0.5:/volume1/video    /home/alex/Pictures" "/etc/fstab")=1 ]]
	then
	    echo "10.0.0.5:/volume1/video /home/alex2wr/Videos \
	    nfs auto,nofail,noatime,nolock,intr,tcp,actimeo=1800 0 0" \
	    >> /etc/fstab
	    echo "Added NFS mount point for 10.0.0.5:/volume1/video /home/alex2wr/Videos" >> fatab.log
	    changed=1
	fi
	if [[ $changed=1 ]]
	then
	    echo "/etc/fstab has been modified" >> fatab.log
	elif [[ $changed=0 ]]
	then
		echo "*** NO CHANGES TO FSTAB ***" >> fatab.log
	fi
	mount -a
	#Note: mount -a throus an error becuase NFS tools are not installed at the time of runing this script for a new Ubuntu instalation.
} #add_fstab

#***********************#
#***    settings     ***#
#***********************#
function set_settings() {
	#Disable Wayland and only use Xorg source: https://askubuntu.com/questions/961304/how-do-you-switch-from-wayland-back-to-xorg-in-ubuntu-17-10
	. /etc/lsb-release
	if [[ $DISTRIB_RELEASE = 17.10 ]]
	then
		mkdir /usr/share/wayland-sessions/hidden
		dpkg-divert --rename \
			--divert /usr/share/wayland-sessions/hidden/ubuntu.desktop \
			--add /usr/share/wayland-sessions/ubuntu.desktop
	else
		echo "This version is not 17.10 thefore no Wayland settings are needed"
		echo "***** No changes to the default graphics server *****"
	fi
	#to revert changes run this command
	#dpkg-divert --rename --remove /usr/share/wayland-sessions/ubuntu.desktop

	#***** gsettings - dconf *****#
	#gsettings set org.gnome.shell.extensions.dash-to-dock dock-position BOTTOM
	#gsettings set org.gnome.shell.extensions.dash-to-dock show-apps-at-top true
	#gsettings set com.ubuntu.sound allow-amplified-volume true
	#gsettings set org.gnome.nautilus.desktop trash-icon-visible false
	#gsettings set org.gnome.nautilus.preferences default-folder-viewer 'list-view'
	#gsettings set org.gnome.nautilus.preferences executable-text-activation 'ask'
	#gsettings set org.gnome.nautilus.preferences
	#gsettings set org.gnome.nautilus.list-view default-visible-columns ['name', 'size', 'type', 'date_modified', 'owner', 'permissions']
	#gsettings set org.gnome.settings-daemon.peripherals.input-devices
	#check into this if then later
	#if $(gsettings get org.gnome.settings-daemon.peripherals.touchpad touchpad-enabled); then gsettings set org.gnome.settings-daemon.peripherals.touchpad touchpad-enabled false; else gsettings set org.gnome.settings-daemon.peripherals.touchpad touchpad-enabled true; fi
}

function set_vbox {
	echo "Entering VirtualBox settings for Mac OS virtual machine."
	pause
	VBoxManage modifyvm "Mac OS X Sierra" --cpuidset 00000001 000106e5 00100800 0098e3fd bfebfbff
	pause 'Press [Enter] key to continue...'
	VBoxManage setextradata "Mac OS X Sierra" "VBoxInternal/Devices/efi/0/Config/DmiSystemProduct" "iMac11,3"
	pause 'Press [Enter] key to continue...'
	VBoxManage setextradata "Mac OS X Sierra" "VBoxInternal/Devices/efi/0/Config/DmiSystemVersion" "1.0"
	pause 'Press [Enter] key to continue...'
	VBoxManage setextradata "Mac OS X Sierra" "VBoxInternal/Devices/efi/0/Config/DmiBoardProduct" "Iloveapple"
	pause 'Press [Enter] key to continue...'
	VBoxManage setextradata "Mac OS X Sierra" "VBoxInternal/Devices/smc/0/Config/DeviceKey" "ourhardworkbythesewordsguardedpleasedontsteal(c)AppleComputerInc"
	pause 'Press [Enter] key to continue...'
	VBoxManage setextradata "Mac OS X Sierra" "VBoxInternal/Devices/smc/0/Config/GetKeyFromRealSMC" 1
} #set_vbox

#***********************#
#***Package downloads***#
#***********************#
function wget_download_install() {
  #Java Working as of 3/31/2018 - 6:30PM
	#JDK - download and tar -xzvf
  # rm -r ~/IDEs/jdk
	if [[ ! -e /opt/jdk ]]; then
  	mkdir -p /opt/jdk
  	wget --no-check-certificate \
  	  --no-cookies \
  	  --header "Cookie: oraclelicense=accept-securebackup-cookie" \
  	  "http://download.oracle.com/otn-pub/java/jdk/10+46/76eac37278c24557a3c4199677f19b62/jdk-10_linux-x64_bin.tar.gz" \
  	  -O /opt/jdk.tar.gz
  	  tar -xzvf /opt/jdk.tar.gz -C /opt/jdk/
  	  rm /opt/jdk.tar.gz
		#JDK - system configuration
	fi
	#Android Development Studio
  echo "***** Starting Android Development instalation *****"
  if [[ ! -e ~/IDEs/android-studio ]]; then
    mkdir -p ~/IDEs/android-studio
  	wget --no-check-certificate \
  	  "https://dl.google.com/dl/android/studio/ide-zips/3.1.1.0/android-studio-ide-173.4697961-linux.zip" \
  	  -O ~/IDEs/android-studio.zip
  	  unzip ~/IDEs/android-studio.zip -d ~/IDEs/
  	  rm ~/IDEs/android-studio.zip
  fi
  echo "***** Finished Android Development instalation *****"
	#PyCharm
  echo "***** Starting PyCharm install *****"
  if [[ ! -e ~/IDEs/pycharm ]]; then
  	mkdir -p ~/IDEs/pycharm
  	wget --no-check-certificate \
  	  "https://download-cf.jetbrains.com/python/pycharm-community-2018.1.1.tar.gz" \
  	  -O ~/ides/pycharm-community.tar.gz
  	  tar -xzvf ~/IDEs/pycharm-community.tar.gz -C ~/IDEs/pycharm
  	  rm ~/IDEs/pycharm-community.tar
  fi
  echo "***** Finished PyCharm install *****"
	#IntelliJ IDEA
  echo "***** Starting IntelliJ IDEA install *****"
  if [[ ! -e ~/IDEs/intellij-idea ]]; then
  	mkdir -p ~/IDEs/intellij-idea
  	wget --no-check-certificate \
  	  "https://download-cf.jetbrains.com/idea/ideaIC-2018.1.1.tar.gz" \
  	  -O ~/IDEs/ideaIC.tar.gz
  	  tar -xzvf ~/IDEs/ideaIC.tar.gz -C ~/IDEs/intellij-idea
  	  rm ~/IDEs/ideaIC.tar
  fi
  echo "***** Finished IntelliJ IDEA install *****"
	#Synology -
	echo "***** Starting Synology install *****"
  wget "https://global.download.synology.com/download/Tools/SynologyDriveClient/1.0.2-10275/Ubuntu/Installer/x86_64/synology-drive-10275.x86_64.deb" \
  -O ~/Downloads/synology-drive-10275.x86_64.deb
  dpkg -i ~/Downloads/synology-drive-10275.x86_64.deb
  rm ~/Downloads/synology-drive-10275.x86_64.deb
  echo "***** Finished Synology install *****"
  chown -R alex2wr:alex2wr ~/IDEs
} #wget_downlaod_install

#********************** Function definitions ends ******************************#

#************************************************************************************************#
#***************************								*************************************#
#***************************		Main starts here		*************************************#
#***************************								*************************************#
#************************************************************************************************#


#Note: This line is from /etc/mtab from Ubnt v.16.10
#/dev/sdb1 /media/alex2wr/mSSD_120 ext4 rw,nosuid,nodev,relatime,data=ordered 0 0

if [ "$EUID" != 0 ]; then
	echo -n "Please run as root. "
	echo "Exiting script..."
else
	if [ $# != 0 ]; then
		echo "Argument passed, menu choice: $1"
		menu_choice=$1
	else
		main_menu
	fi

	if [[ $menu_choice = 1 ]]; then

		clear
		echo "#***********************************************************************#"
		echo "# New Ubuntu based installation script.					#"
		echo "# Run script for new Ubuntu based distros, this will install		#"
		echo "# applications by use of 'apt install' as well as web downloads using	#"
		echo "# 'wget' command to get files and the necesary keys.			#"
		echo "#***********************************************************************#"

		second_menu
		case "$menu_choice2" in
		"1")
			echo "This will run all the choices in the menu."
			pause; echo
			;&
		"1" | "2")
			echo "This will add the keys in this script file"
			echo "***** Adding keys... *****"
			add_keys
			;;&
		"1" | "3")
			echo "This will add the repos in this script file"
			echo "***** Adding repos... *****"
			add_repos
			dpkg --add-architecture i386	#WinHQ enables 32bit architecture
			;;&
		"1" | "4")
			echo "This will install the packages in this script file"
			echo "***** Installing packages with apt install... *****"
			apt_install
			;;&
		"1" | "5")
			echo "This will add entries to the fstab file"
			echo "***** Adding /etc/fstab entries... *****"
			add_fstab
			;;&
		"1" | "6")
			echo "This will set custom settings"
			echo "***** Setting settings... *****"
			set_settings
			;;&
		"1" | "7")
			echo "This will downlaod and install apps usign wget command"
			echo "***** Downlaoding applications and installing them... *****"
			wget_download_install
			;;&
		"*")
			echo "Nothing chosen, exiting script."
		esac

	elif [[ $menu_choice = 3 ]]; then
		set_vbox

	elif [[ $menu_choice = 4 ]]; then
		echo -e "Menu choice $menu_choice, nothing here... \nexiting script."
	elif [[ $menu_choice = 5 ]]; then
		echo -e "Menu choice $menu_choice, nothing here... \nexiting script."
	elif [[ $menu_choice = 6 ]]; then
		echo -e "Menu choice $menu_choice, nothing here... \nexiting script."
	elif [[ $menu_choice = 7 ]]; then
		echo -e "Menu choice $menu_choice, nothing here... \nexiting script."
	elif [[ $menu_choice = 8 ]]; then
		echo -e "Menu choice $menu_choice, nothing here... \nexiting script."


#************************************************************************************************#
#***************************								*************************************#
#***************************	Main ends, testing statrs	*************************************#
#***************************								*************************************#
#************************************************************************************************#
	#mSSD_UUID = 30068a2f-bb91-4e4c-9973-b4ec33b44ff6

	elif [[ $menu_choice = 9 ]]; then
		echo "*** Entering test mode. ***"

		if [ $# != 0 ]; then
			echo "Argument passed, test menu choice: $2"
			choice=$2
		else
			echo "Enter test choice no:. from 1-9"
			echo "1. Function1 - file_type"
			echo "2. Function2 - my_wget"
			echo "3. Function3 - pause()"
			echo "4. Array loop"
			echo "5. File command"
			echo "6. Test for wget instlation exists"
			echo "7. Add /etc/fstab"
			echo "8. Empty"
			echo "9. Empty"
			echo -n "Enter choice no.: "; read choice
		fi

		while [[ ! $choice =~ ^[0-9]+$ ]]
		do
			echo -n "Enter a number between 1-9: "
			read choice
		done

		if [ $choice = 1 ]; then
			#echo "$choice: Enter breif description here"
			echo "$choice: Testing function"
			function file_type {
				if [[ $file =~ \.t?gz$ ]]; then
					echo "This is gzipped "
				elif [[ $file =~ \.zip$ ]]; then
					echo "This file is zipped"
				else
					echo "I dont know what this file is"
				fi
			}

		elif [[ $choice = 2 ]]; then
			echo -e "Menu choice $choice, nothing here... exiting script."
			function my_wget {
				rm -r $1
				mkdir -p $1
				wget --no-check-certificate --no-cookies $3 -O $1/$2
				if [ ${file: -4} == ".zip" ]; then
					unzip $1/$2 -d $1/$1
				elif [ ${file: -3} == ".gz" ]; then
					tar -xzvf
				fi
				rm $1/$2
			}
		ANDROID_FILE=android-studio-ide-171.4443003-linux.zip
		ANDROID_PATH=/usr/local/android
		ANDOIRD_URL="https://dl.google.com/dl/android/studio/ide-zips/3.0.1.0/android-studio-ide-171.4443003-linux.zip"
		my_wget $ANDROID_PATH $ANDROID_FILE $ANDOIRD_URL

		elif [[ $choice = 3 ]]; then
			echo "testing pause() function here"
			pause; echo

		elif [[ $choice = 4 ]]; then
			echo -e "Loop thru array"
			app_list=("p1" "p2" "p3" "4th" "5")
			for i in "${app_list[@]}"
			do
				echo $i
			done

		elif [[ $choice = 5 ]]; then
			echo -e "File command."
			file -b t.run
			echo $?

		elif [[ $choice = 6 ]]; then
			if [[ -d /usr/local/java ]]; then
				echo -n "Instalation already exist, do you want to reinstall? "
				echo -n "Type yes/no to continue: "; read choice
				if [ $choice -eq 'yes']; then
					rm -r /usr/local/java
					mkdir -p /usr/local/java
					wget --no-check-certificate \
					  --no-cookies \
					  --header "Cookie: oraclelicense=accept-securebackup-cookie" \
					  "http://download.oracle.com/otn-pub/java/jdk/10+46/76eac37278c24557a3c4199677f19b62/jdk-10_linux-x64_bin.tar.gz" \
					  -O /usr/local/java/jdk-10_linux-x64_bin.tar.gz
					  tar -xzvf /usr/local/java/jdk-10_linux-x64_bin.tar.gz -C /usr/local/java
					  rm /usr/local/java/jdk-10_linux-x64_bin.tar.gz
				fi
				#JDK - system configuration
			fi
		elif [[ $choice = 7 ]]; then
			add_fstab

		elif [[ $choice = 8 ]]; then
			echo -e "Menu choice $choice, nothing here... exiting script."
		elif [[ $choice = 9 ]]; then
			echo -e "Menu choice $choice, nothing here... exiting script."
		else
			echo -n "You did not enter any of the choices in the menu from 0-9, "
			echo "exiting script..."

		fi #test area if
	fi #main menu if
fi #su check if



#EOF
