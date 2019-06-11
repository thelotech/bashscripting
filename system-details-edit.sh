#!/bin/bash

# OBJECTIVE: Create a bash script that asks the user for their name, then 
# displays the user's name along with certain attributes of the system.
# 
# FILE: system-details.sh
# AUTHOR: thelotech

# ------------------------------------------------------------------
# INPUT: The following is the only time the user will enter text.
# ------------------------------------------------------------------

# Using the read command to prompt the user for their name
read -p "Please enter your username: " UNAME

# ------------------------------------------------------------------
# OUTPUT: The rest of the script is what is output when the script is run
# ------------------------------------------------------------------

# Greeting the user with the input from the variable assigned by the read command 
echo "Hello, ${UNAME}. Here are your system details."

# Displaying the name of the bash script file
echo "This script is $(basename -- "$0")"

# Displaying the current working directory
echo "You are currently in $(pwd)"

# Display the amount of RAM available to the system
hwmemsize=$(free -g | grep MemTotal /proc/meminfo | awk '{print $2 " " $3}')
echo "This system has ${hwmemsize} of RAM dedicated to it."

# Display the uptime for the system
echo "The system has been online for $(uptime -p | awk '{$1=""}1')"

# Display the system's hostname
echo "The hostname is $(hostname)"

# Display details of the network, such as IPv4 and the corresponding
# MAC addresses for the network interfaces.
ipv4=$(ip -br addr show | awk '{print $1 ": " $3}' | cut -d/ -f1)
ipv4a=$(ip -br addr show | awk '{print $1 " " $3}')
macaddress=$(ifconfig | grep ether | awk '{print $2}')
echo "Check out the IPv4 address(es) for network interface(s): "
echo "${ipv4}"
echo " "
echo "The MAC address is ${macaddress}." 
echo " "

lport1=$(sudo netstat -plunt | tail -n+3 | grep LISTEN | awk '{print $4}' | cut -d: -f2)
lport2=$(sudo netstat -plunt | tail -n+3 | awk '{print $4}' | cut -d: -f2)
echo "Services are listening on the following port(s): "
if [ -z "$lport1" ]
then
      echo "$lport2"
else
      echo "$lport1"
fi

echo " "

runningprocesses=$(ps aux | wc -l)
echo "There are ${runningprocesses} processes running on this system."
echo " "

freespace=$(df -hT /home | tail -n+2 | awk '{print $5}')
echo "There are $freespace of free space left in the root filesystem."
