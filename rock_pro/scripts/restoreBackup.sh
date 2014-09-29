#!/bin/bash

##########################################################################################################
# Paths and variables
##########################################################################################################

scriptdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd ${scriptdir}
cd ..
basedir=$(pwd)
kerneldir=${basedir}/kernel_rockchip
tooldir=${basedir}/tools
backupdir=${basedir}/backups

export ARCH=arm
export CROSS_COMPILE=arm-linux-gnueabihf-

today=$(date +"%Y_%m_%d")
partition=" "
offset=0xA000
size=0xEF0000

##########################################################################################################
# functions
##########################################################################################################

function getParameterFile {
	cd ${tooldir}/rkflashtool
	# if there is already a backupfile, delete old one first!
	rm -f parameter_${today}
	./rkflashtool p > ${backupdir}/parameter_${today}
}

function readPartitionData {
	partitioninfo=$(cat ${backupdir}/parameter_${today} | grep -o -e "0x[0-9a-fA-F]\{8\}\@0x[0-9a-fA-F]\{8\}("$1")" -e "-\@0x[0-9a-fA-F]\{8\}("$1")")
	offset=$(echo "${partitioninfo}" | grep -o "0x[0-9a-fA-F]\{8\}(" | grep -o "0x[0-9a-fA-F]\{8\}")
	size=$(echo "${partitioninfo}" | grep -o ".*\@" | grep -o -e "-" -e "0x[0-9a-fA-F]\{8\}")
	if [ "${size}" == "-" ]; then 
		size=0xEF0000
	fi
	echo "Partition: offset = ${offset}, size = ${size}"
}


##########################################################################################################
# program
##########################################################################################################

backupdir=${backupdir}/2014_09_28

while true; do
	read -p "Is radxa connected in loader mode? [y]es, or [n]o, abort backup!" yn
	case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * )     echo "connect radxa in loader mode and confirm with [y] or abort with [n]o!";;
        esac
done

cd ${tooldir}/rkflashtool
./rkflashtool w ${offset} ${size} < ${backupdir}/linuxroot_2014_09_28.img

exit
