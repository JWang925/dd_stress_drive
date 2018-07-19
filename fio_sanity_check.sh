#!/bin/bash
source ./disk_list


####################################
##get the current OS drive
####################################
echo "checking if OS drive is listed in disk_list"

#get a copy of lsblk output
lsblk>.temp;
#get the line number of the boot partition
#This is done by looking at the lsblk output. grep -n displays the line number at the front and head -c grabs the first partition with OS on it.
line_nb=$(grep -ni "boot" .temp | head -c 1);

while : 
do
	line_nb=$(expr $line_nb - 1)
	sed "${line_nb}q;d" .temp | grep -iq "disk";  ##get the line above "boot" where 
	if [ $? == 0 ]; then break;fi
	if [ $line_nb == 0 ]; then return 1; fi
done
#get the first word of line $line_nb and that is the name of the drive
OS_drive=$(sed -n "${line_nb}p" .temp  | cut -d ' ' -f 1) 
echo "OS drive detected: $OS_drive"


#at current line, look for keyword disk (e.g. TYPE=disk for disks, TYPE=part for partitions).
for i in "${disk_list[@]}"
do
	if [ "$OS_drive" = "$i" ]; then
		echo -e "\e[31m OS_drive is listed in file "disk_list"!!!! \e[0m"
		echo -e "\e[31m Remove $i from file disk_list!!! \e[0m"
		echo -e "\e[31m Program will not continue \e[0m"
		while :
		do
			read 
		done
	fi
done
echo "OS drive is not in the list of disks being destroyed"

