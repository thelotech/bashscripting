#!/bin/bash

# Script to practice bash loops
# Author: thelotech

# This is a quick introductory while loop

# while read line; do
#   echo "${line}"
# done < animalfile.txt

# echo All done

# # # # # # # # # # # # # # # # # # # # # 
# This is an example of a loop for reading line by line

# Declaring the arrays
declare -a dogname dogheight dogcity

# Looping through the file to add values to the array from the .txt file
index=0
while read line; do
  dogname[$index]=$(echo "${line}" | awk '{print $1}')
  dogheight[$index]=$(echo "${line}" | awk '{print $8}')
  dogcity[$index]=$(echo "${line}" | awk '{print $17}')
  ((index++))
done < <(cat animalfile.txt | grep "yellow")

# decrement the index to drop from the n+1 value to the actual last value
((index--))  

# Loop through the array values from the first value through the last value
# Echo each value of the array
seq 0 ${index} | while read offset; do
  echo "${dogname[$offset]}: ${dogheight[$offset]} inches tall and lives in ${dogcity[$offset]}"
done