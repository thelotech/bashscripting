# Discovering Arrays in Bash Script

When I was attempting to write my bash script for gathering system details, [system-details.sh](https://github.com/thelotech/bashscripting/blob/master/system-details.sh), I realized there was one thing I should have learned: arrays.

## Oh, How Wrong I Was...

This is how I attempted to output the network interface names with the IPv4 addresses and MAC addresses:

```bash
#!/bin/bash

ipv4=$(ip -br addr show | awk '{print $1 ": " $3}' | cut -d/ -f1)
ipv4a=$(ip -br addr show | awk '{print $1 " " $3}')
macaddress=$(ifconfig | grep ether | awk '{print $2}')
echo "Check out the IPv4 address(es) for network interface(s): "
echo "${ipv4}"
echo " "
echo "The MAC address is ${macaddress}." 
```

### Why it isn't *quite* right

In my script (using the Kali Linux VM output example) I used the following to display the IPv4 addresses and MAC addresses, with the following results:

```bash
$ ip -br addr show | awk '{print $1 ": " $3}' | cut -d/ -f1  #IPv4
lo: 127.0.0.1
eth0: 10.0.2.15

$ ifconfig | grep ether | awk '{print $2}'  #MAC
08:00:27:al:aa:bb
```

But looking at my script, I don't think it would work to display potentially more networks on other systems. Additionally, there should be a MAC address for each network interface.

Back to the drawing board! I wanted to be able to go through the standard output of `ip` and search for *all* of the network interfaces, IPv4 addresses and MAC addresses, not just a set number of them. ARRAY TIME!

## Basics of Arrays

**Array:** An array is a variable containing multiple values.

As I was already familiar with the basic concept of variables, this was just a new way to use that concept. Time to start practicing Arrays!

I located the following resources:
* https://stackoverflow.com/questions/8880603/loop-through-an-array-of-strings-in-bash
* https://access.redhat.com/sites/default/files/attachments/rh_ip_command_cheatsheet_1214_jcs_print.pdf

