#!/bin/bash
# -----------------------------------------------------------
# File: system-details.sh
# Author: int0x80
# Prompt the user for their name, then displays the user's 
# name along with certain attributes of the system.
#
# Search queries that were helpful:
#   bash read variable from user
#   bash only filename current script
#   bash current directory
#   bash system memory
#   bash how long system online
#   linux hostname
#   bash arrays howto
#   bash network interfaces ip address
#   bash network interfaces mac address
#   bash loops
#   bash increment variable
#   bash variable loop forgotten
#   bash array count
#   bash echo same line
#   bash print last column
#   bash sort results unique
#   bash replace newline
# -----------------------------------------------------------

# -----------------------------------------------------------
# Read user name and greet user
# -----------------------------------------------------------
read -p "Enter your name: " name
echo "Hello, ${name}. Here are your system details."

# -----------------------------------------------------------
# Display filesystem info of script name and current directory
# -----------------------------------------------------------
echo "This script is $(basename -- ${0})"
echo "You are currently in $(pwd)"

# -----------------------------------------------------------
# Display the amount of RAM available to the system, and uptime
# -----------------------------------------------------------
echo "This system has$(grep 'MemTotal' /proc/meminfo | awk '{$1=""}1') of RAM"
echo "The system has been online for$(uptime -p | awk '{$1=""}1')"

# -----------------------------------------------------------
# display some network details: hostname
# -----------------------------------------------------------
echo "The hostname is $(hostname)"

# -----------------------------------------------------------
# Display some network details: IP and MAC for each interface
# Since I know the details I want (interface name, IP, MAC),
# but don't know how many interfaces are on the system, I'm
# using three separate arrays -- one for each set of details
# -----------------------------------------------------------
echo "Currently the host has the following IPv4 interfaces:"
declare -a interface_name interface_ip interface_mac

# -----------------------------------------------------------
# Use the `ip` program to display a list of interfaces with
# IPv4 addresses, then read each line of the output into $line
# Use the variable $index to keep track of the offset in each
# Finally increment $index to move onto the next interface
# -----------------------------------------------------------
index=0
while read line; do
  interface_name[$index]=$(echo "${line}" | awk '{print $2}')
  interface_ip[$index]=$(echo "${line}" | awk '{print $4}' | awk -F '/' '{print $1}')
  ((index++))
done <<< $(ip -4 -o addr show)

# -----------------------------------------------------------
# Similar approach as above, but this time reading the MAC
# address for each interface that has an IPv4 address
# -----------------------------------------------------------
index=0
while read line; do
  interface_mac[$index]=$(echo "${line}" | awk '{print $17}')
  ((index++))
done <<< $(ip -4 -o link show)

# -----------------------------------------------------------
# Our arrays should look something like this:
#
# interface_name[0]='lo'    interface_ip[0]='127.0.0.1'         interface_mac[0]='00:00:00:00:00:00'
# interface_name[1]='eth0'  interface_ip[1]='192.168.174.230'   interface_mac[1]='00:0c:29:11:ba:24'
# interface_name[2]='eth1'  interface_ip[2]='10.137.152.219'    interface_mac[2]='00:0c:29:df:97:ca'
# interface_name[3]='eth2'  interface_ip[3]='172.16.44.176'     interface_mac[3]='00:0c:29:e7:8c:1f'
#
# Now we just need to loop over the results and display them
# -----------------------------------------------------------
((index--))   # index retains value from the previous loop, but currently points to interface n+1 so decrement index
seq 0 ${index} | while read offset; do
  echo "  ${interface_name[$offset]}: ${interface_ip[$offset]} with MAC address ${interface_mac[$offset]}"
done

# -----------------------------------------------------------
# Find ports that are listening, here's the breakdown
# netstat -ln                 List all listening sockets
# egrep '^(tcp|udp)'          Only consider tcp and udp services
# awk '{print $4}'            Parse the address and port for the service
# awk -F ':' '{print $NF}'    Using colon (instead of whitespace) as a delimiter, print the last column
#                             We do this because services using IPv6 can show up as ':::8888' for example
# sort -nu                    Sort the list of ports and remove duplicates 
# sed 's/$/, /g'              Replace the end of each line with a comma and a space
# tr -d '\n'                  Join all ports onto one line by deleting the newlines
# sed 's/, $/\n/'             Replace the trailing comma and space with a newline
# -----------------------------------------------------------
echo -n "Services are listening on the following ports: "       # the echo -n lets us write more on the same line
netstat -ln | egrep '^(tcp|udp)' | awk '{print $4}' | awk -F ':' '{print $NF}' | sort -nu | sed 's/$/, /g' | tr -d '\n' | sed 's/, $/\n/'

# -----------------------------------------------------------
# Count the number of running processes on a system
# -----------------------------------------------------------
echo "There are currently $(ps -ef | tail -n+2 | wc -l) processes running"