#!/bin/sh


# THIS IS THE INPUT PART
echo Hello, who am I talking to?
read varname

if [ "$varname" == "" ]; then
  echo "Not a valid username! Try again."
  sh ./system-details.sh
else
  echo "Hello $varname."

# THIS IS THE OUTPUT PART

# The name/handle entered by the user running the script
echo "You are now running the bash script \"system-details.sh\" to provide the following system details:"
echo ------------------------------------------------------
echo " "

# Current directory that the user is in
echo Currently, you are hanging out in the following directory: $PWD
echo " "

# Amount of RAM dedicated to the system
hwmemsize=$(free -g | grep MemTotal /proc/meminfo)

echo "This is how much RAM has been dedicated to this system:"
echo "${hwmemsize}"
echo " "

# Uptime of the system
systemuptime=$(uptime)

echo "The uptime of this system is: "
echo "${systemuptime}"
echo " "

# Hostname of the system
hostname=$(hostname)

echo "The system hostname is: ${hostname}"
echo " "

# IPv4 address of each network interface
ipv4addresses=$(ifconfig | grep inet | grep -v inet6 | tail -2 | head -1)

echo "The IPv4 address for the network interfaces are:" 
echo "${ipv4addresses}" | awk '{print $2;}'
echo " "

# MAC address of each network interface
macaddress=$(ifconfig | grep ether)

echo "The MAC address for the network interface is: " 
echo "${macaddress}"
echo " "

# LISTENing ports (hint: this can be found with the netstat program)
listenport=$(netstat -plnt)

echo "These are the LISTENing ports: "
echo " "
echo "${listenport}"

# Total number of processes running on the system
runningprocesses=$(ps aux | wc -l)

echo "Number of processes running on this system: ${runningprocesses}"
fi