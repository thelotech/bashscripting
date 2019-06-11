# Discovering Loops and Arrays in Bash Script

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

Back to the drawing board! I wanted to be able to go through the standard output of `ip` and search for *all* of the network interfaces, IPv4 addresses and MAC addresses, not just a set number of them. So I would need to loop through array values...

## Basics of Loops

Bash loops can help to take certain commands and run them over and over again until a set condition is met. For example, looping through strings of an output until information is gathered and printed out... such as specific network details from an `ip` output.

I used a [Bash Scripting Tutorial](https://ryanstutorials.net/bash-scripting-tutorial/bash-loops.php) on Ryans Tutorials website for a quick introduction to loops.

### While Loops

A "while loop" says that while a particular expression is true, the loop should keep executing given commands.

Here is an example of a simple while loop, showing that while variable 'counter' is less than or equal to (`-le`) 10, it should echo the value of 'counter' +1 (`counter++`):

```bash
#!/bin/bash

counter=1
while [ $counter -le 10 ]
do
  echo $counter
  ((counter++))
done

echo All done
```

As you can see, the resulting output is as follows. This shows that once the variable value no longer meets the 'less than 10' test, the loop stops and 'All done' is echoed:

```bash
$ ./looppractice.sh
1
2
3
4
5
6
7
8
9
10
All done
```

## Practicing Arrays

An "array" is a variable that contains multiple values. You can use a while loop to read a file line by line and get certain information from each line to work with. 

I created a basic .txt file called 'animalfile.txt' (note I added an empty line at the bottom of the file):

```bash
Dog is black
Cat is orange
Dog is white
Dog is yellow
Cat is brown

```

I wanted to find a way to run through this file and pull out all of the colors for all of the animals. First, I created a read-while loop to know I was reading through the file line-by-line:

```bash
#!/bin/bash

while read line; do
  echo "${line}"
done < animalfile.txt
```
 
This produced the following output:

```bash
$ ./looppractice.sh
Dog is black
Cat is orange
Dog is white
Dog is yellow
Cat is brown
```

But I wanted the colors. So in came an array. I first declared the array with `declare -a color`, making "color" the name of the array. I wanted to start at the first line of the file I was reading, so `index=0` would do just that. 

I didn't want to echo just the lines, however. I wanted the color. So piping the lines into the `awk '{print #3}` command would grab the color each loop.

Then, it was just about looping through, each time increasing the index (with `((index++))`) for each new line as we looped. 

```bash
#!/bin/bash

declare -a color

index=0
while read line; do
  color[$index]=$(echo "${line}" | awk '{print $3}')
  ((index++))
done < animalfile.txt
```

So now I had these values stored in the array "color", but we needed to print them out.

I could use the following to do so:

```bash
#!/bin/bash

echo "${color[@]}"
```

This would print out the values in the array as such:

```bash
$ ./looppractice.sh
black orange white yellow brown
```

I wanted the values printed in the sequence collected in a vertical list though. This required a couple of commands. First, "index" retains the value from the previous loop, but it currently points to the color n+1. I used `((index--))` to decrement the index.

Next, using `seq 0 ${index}` would generate the list of number from 0 to the index variable (aka all of the items from the loop). That would be piped into a new read-while loop so we can output the list in sequential, vertical format:

```bash
#!/bin/bash

seq 0 ${index} | while read offset; do
  echo "${color[offset]}"
done
```

So as we loop through the "color" array, we echo each value, echoing the value at each number in the sequence up to the last index number.

The complete script looks like:

```bash
#!/bin/bash

# Declaring the array
declare -a color

# Looping through the file to add values to the array
index=0
while read line; do
  color[$index]=$(echo "${line}" | awk '{print $3}')
  ((index++))
done < animalfile.txt

# decrement the index to drop from the n+1 value to the actual last value
((index--))  

# Loop through the array values from the first value through the last value
# Echo each value of the array
seq 0 ${index} | while read offset; do
  echo "${color[offset]}"
done
```

The results?:

```bash
$ ./looppractice.sh
black
orange
white
yellow
brown
```

## Advanced Array Practice

Alright, so I learned a little bit about arrays and loops today. But what if I want to go in and gather additional information from each line? 

*Example* In a list of different dogs, we want to know only about the dogs with yellow fur. Display the following information in this exact format:

Ex) Rex: 15 inches tall and lives in Dallas.

My animalfile.txt:

```bash
Rex has a yellow coat and is 15 inches tall with blue eyes and lives in Dallas.
Rover has a brown coat and is 13 inches tall with green eyes and lives in Pflugerville.
Spot has a white coat and is 12 inches tall with brown eyes and lives in Georgetown.
Tahlia has a yellow coat and is 27 inches tall with black eyes and lives in Austin.
Hooch has a yellow coat and is 84 inches tall with gray eyes and lives in Buda.
```

Let's get arrayin' and loopin'! To start, we have a couple of things to consider. Not all of these dogs have yellow coats. So we don't want to loop through and gather details from every line in this file, do we? In order to just focus on the lines containing dogs with yellow coats, we can add some arguments while looping. 

And we can't just `grep` for "yellow" and print the whole line, because it won't meet our format, and it also contains unnecessary information like eye color.

Let's declare arrays to add values for the dog's name, the height, and the location of the dog. This would look like:

```bash
#!/bin/bash

declare -a dogname dogheight dogcity
```

Let's fill those arrays with some values! Loop time!

```bash
#!/bin/bash

declare -a dogname dogheight dogcity

index=0
while read line; do
  dogname[$index]=$(echo "${line}" | awk '{print $1}')
  dogheight[$index]=$(echo "${line}" | awk '{print $8}')
  dogcity[$index]=$(echo "${line}" | awk '{print $17}')
  ((index++))
done < animalfile.txt
```

Oops! This will collect those values for all line... we just want the data from lines involving yellow dogs! EDIT:

I tried updating the file output being fed into the loop by adding `done <<< $(cat animalfile.txt | grep "yellow")`, but then it only printed out values in the array from the first line with "yellow" in it, `Rex: 15 inches tall and lives in Dallas.`...

I used a little printf debugging as threw in a line to echo out what line was being read for every loop:

```bash
#!/bin/bash

index=0
while read line; do
  echo "Processing Line: $line"
  dogname[$index]=$(echo "${line}" | awk '{print $1}')
  dogheight[$index]=$(echo "${line}" | awk '{print $8}')
  dogcity[$index]=$(echo "${line}" | awk '{print $17}')
  ((index++))
done <<< $(cat animalfile.txt | grep "yellow")
```

It showed me the following:

```bash
$ ./looppractice.sh
Processing Line: Rex has a yellow coat and is 15 inches tall with blue eyes and lives in Dallas. Tahlia has a yellow coat and is 27 inches tall with black eyes and lives in Austin. Hooch has a yellow coat and is 84 inches tall with gray eyes and lives in Buda.
Rex: 15 inches tall and lives in Dallas.
```

So basically, I was just providing the loop with one line to "loop" through... of course it only spit out one value for each array!

So I thought to myself... how can I make it loop through and still give me the values from the arrays for any line with "yellow" in it? -.-

OMG PROCESS SUBSTITUTION! This is what I did:

```bash
#!/bin/bash

declare -a dogname dogheight dogcity

index=0
while read line; do
  dogname[$index]=$(echo "${line}" | awk '{print $1}')
  dogheight[$index]=$(echo "${line}" | awk '{print $8}')
  dogcity[$index]=$(echo "${line}" | awk '{print $17}')
  ((index++))
done < <(cat animalfile.txt | grep "yellow")

((index--))  

seq 0 ${index} | while read offset; do
  echo "${dogname[$offset]}: ${dogheight[$offset]} inches tall and lives in ${dogcity[$offset]}"
done
```

By using a stdin from the output of the command line in the parentheses. IT WORKED:

```bash
$ ./looppractice.sh
Rex: 15 inches tall and lives in Dallas.
Tahlia: 27 inches tall and lives in Austin.
Hooch: 84 inches tall and lives in Buda.
```

# Recap on Arrays and While Loops

I learned a lot about how to go through files (or stdout from commands) and loop through to gather specific values and assign them to arrays.

After gathering the array values, it was just about printing out the array values how I wanted them. YAYYYYY!
