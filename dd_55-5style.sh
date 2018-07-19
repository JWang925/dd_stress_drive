#!/bin/bash
source ./disk_list

echo "***************************"
echo "dd stress ( and DESTROY) all the drives simulaneously"
echo "time stamp:" $(date)
echo "Disks to be tested:"
echo ${disk_list[*]}
echo "***************************"


./fio_sanity_check.sh

#create a folder to contain the result for this disk; if prior results exists, inform and then remove the folder
if [ -d "./Results/dd_stress" ]; then
	echo -e "\e[31m Old results exists in directory ./Results/dd_stress, it will be deleted. \e[0m"
	read -p "Press 'enter' to continue"
	rm -rf ./Results/dd_stress
fi
mkdir -p ./Results/dd_stress


for i in "${disk_list[@]}"
do
        mkdir -p ./Results/dd_stress/$i/
done

#####################################
# 55 MIN READ TEST
#####################################
dd_pid=();
for i in "${disk_list[@]}"
do
        #produce the dd script
	echo "dd if=/dev/$i of=/dev/null" > ./Results/dd_stress/$i/dd_read.sh
	#Run the dd command
	chmod 755 ./Results/dd_stress/$i/dd_read.sh;
	dd if=/dev/$i of=/dev/null 2>> ./Results/dd_stress/$i/dd_read_result& pid=$!
	#Add the PID to list
	dd_pid+=($pid);
done

#display PIDs for the DD writes
echo "The PIDs for the DD writes are:"
echo ${dd_pid[@]}

#Test Run Time
echo "Tests are now running for 3300 seconds"
sleep 3300;

for i in "${dd_pid[@]}"
do
	#the return from kill switch is stderr, so 2>&1 redirect stderr to stdout. And tee only works with stdout.
	kill -USR1 $i
	sleep 0.1
	kill $i
done


##################################
# 5 MIN WRITE TEST
#################################
#re-initialize dd_pid parameter.
dd_pid=();
for i in "${disk_list[@]}"
do
        #produce the dd script
	echo "dd if=/dev/urandom of=/dev/$i" > ./Results/dd_stress/$i/dd_write.sh
	#Run the dd command
	chmod 755 ./Results/dd_stress/$i/dd_write.sh;
	dd if=/dev/urandom of=/dev/$i 2>> ./Results/dd_stress/$i/dd_write_result& pid=$!
	#Add the PID to list
	dd_pid+=($pid);
done

#display PIDs for the DD writes
echo "The PIDs for the DD writes are:"
echo ${dd_pid[@]}

#Test Run Time
echo "Tests are now running for 300 seconds"
sleep 300;

for i in "${dd_pid[@]}"
do
	#the return from kill switch is stderr, so 2>&1 redirect stderr to stdout. And tee only works with stdout.
	kill -USR1 $i
	sleep 0.1
	kill $i
done

sleep 5
echo "dd Test done"
echo "Results are at ./Results/dd_stress/sdx/"
