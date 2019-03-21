#!/bin/bash
#
# About: Install Unattended automatically
# Author: liberodark
# License: GNU GPLv3

#=================================================
# CHECK UPDATE
#=================================================

  update_source="https://raw.githubusercontent.com/liberodark/Unattended-Debian/master/install.sh"
  version="0.0.3"

  echo "Welcome on Unattended Install Script $version"

  # make update if asked
  if [ "$1" = "noupdate" ]; then
    update_status="false"
  else
    update_status="true"
  fi ;

  # update updater
  if [ "$update_status" = "true" ]; then
    wget -O $0 $update_source
    $0 noupdate
    exit 0
fi ;

#=================================================
# CHECK ROOT
#=================================================

if [[ $(id -u) -ne 0 ]] ; then echo "Please run as root" ; exit 1 ; fi

#=================================================
# RETRIEVE ARGUMENTS FROM THE MANIFEST AND VAR
#=================================================

distribution=$(cat /etc/*release | head -n +1 | awk '{print $1}')

apt=/etc/apt/apt.conf.d/02periodic

unattended='/ Control parameters for cron jobs by /etc/cron.daily/apt-compat //\n
\n
\n
// Enable the update/upgrade script (0=disable)\n
APT::Periodic::Enable "1";\n
\n
\n
// Do "apt-get update" automatically every n-days (0=disable)\n
APT::Periodic::Update-Package-Lists "1";\n
\n
\n
// Do "apt-get upgrade --download-only" every n-days (0=disable)\n
APT::Periodic::Download-Upgradeable-Packages "1";\n
\n
\n
// Run the "unattended-upgrade" security upgrade script\n
// every n-days (0=disabled)\n
// Requires the package "unattended-upgrades" and will write\n
// a log in /var/log/unattended-upgrades\n
APT::Periodic::Unattended-Upgrade "1";\n
\n
\n
// Do "apt-get autoclean" every n-days (0=disable)\n
APT::Periodic::AutocleanInterval "21";\n
\n
\n
// Send report mail to root\n
//     0:  no report             (or null string)\n
//     1:  progress report       (actually any string)\n
//     2:  + command outputs     (remove -qq, remove 2>/dev/null, add -d)\n
//     3:  + trace on\n
APT::Periodic::Verbose "2";'


#==============================================
# INSTALL Unattended Debian
#==============================================
echo "Install Unattended Updates"

  # Check OS & unattended

  which nrpe &> /dev/null

  if [ $? != 0 ]; then

    if [[ "$distribution" =~ .Ubuntu || "$distribution" = Ubuntu ]]; then
      apt install -y unattended-upgrades apt-listchanges &> /dev/null
      echo -e $unattended > $apt
    
    elif [[ "$distribution" =~ .Debian || "$distribution" = Debian ]]; then
      apt install -y unattended-upgrades apt-listchanges &> /dev/null
      echo -e $unattended > $apt
      
    fi
fi
