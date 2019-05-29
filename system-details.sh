#!/bin/sh

# This script was made to practice bash scripting.

echo Hello, who am I talking to?

read varname

FILE_NAME=$(basename -- "$0")
echo " "
echo "Hello ${varname}!"
echo "You are now running the bash script ${FILE_NAME}. Here are some details about this system:"
echo ------------------------------------------------------
echo " "

echo "You are currently in directory $PWD."
echo " "

hwmemsize=$(free -g | grep MemTotal /proc/meminfo | awk '{print $2 " " $3}')
echo "This system has ${hwmemsize} of RAM dedicated to it."
echo " "

systemuptime=$(uptime -p | awk '{$1=""}1')
echo "This system has been in operation for${systemuptime}!"
echo " "

hostname=$(hostname)
echo "The system hostname is ${hostname}."
echo " "

ipv4=$(ip -br addr show | awk '{print $1 ": " $3}' | cut -d/ -f1)
ipv4a=$(ip -br addr show | awk '{print $1 " " $3}')
macaddress=$(ifconfig | grep ether | awk '{print $2}')
echo "Check out the IPv4 address(es) for network interface(s): "
echo "${ipv4}"
echo " "
echo "The MAC address is ${macaddress}." 
echo " "

lport1=$(sudo netstat -plunt | tail -n+3 | grep LISTEN | awk '{print $4}' | cut -d: -f2)
lport2=$()
echo "Services are listening on the following port(s): "
echo "$lport1"
echo " "

runningprocesses=$(ps aux | wc -l)
echo "There are ${runningprocesses} processes running on this system."
echo " "

freespace=$(df -hT /home | tail -n+2 | awk '{print $5}')
echo "There are $freespace of free space left in the root filesystem."
