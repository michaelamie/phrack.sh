#!/bin/bash

#########################################################
# phrack.sh ## A script to download the phrack archives #
#########################################################
# Requires: wget                                        #
#########################################################

# The directory that the phrack text files will be downloaded into.
# The first argument passed by the user when executing the script will
# override the default directory name "phrack."
DESTDIR=${1:-"phrack"}

# The total number of of phrack issues to download. The second argument
# passed by the user when executing the script will override the default
# number (currently "hardcoded" to 67)
ISSUES=${2:-67}

#########################################################

# Set the field seperator string to be the newline char.
IFS=$'\n'

# Store absolute path ${DIR}
ROOTDIR=$(pwd)
DIR=${ROOTDIR}/${DESTDIR}

# The current number of editions of phrack. Too lazy to automatically
# determine this, and the site format is likely to change anyway. 
N=$(seq 1 ${ISSUES})

# Make directory if it doesn't exist
if [ -d ${DIR} ]; then 
    echo -n "Since the directory \"${DIR}\" already exists, "
    echo "the script cannot execute."
    IFS=${ORIGINAL_IFS}
    exit
else
    mkdir ${DIR}; cd ${DIR}
fi

# Download phrack tar.gz archives
for i in ${N}
do
    wget http://www.phrack.org/archives/tgz/phrack${i}.tar.gz
done

# Extract phrack tar.gz archives
for i in ${N}
do
    mkdir ${i}; tar -C ${i} --strip-components=1 -zxvf phrack${i}.tar.gz
    rm phrack${i}.tar.gz
done

# Concatenate text files and clean up dirs
for d in ${DIR}/*
do
    DIRNUM=$(basename ${d})
    FILENUM=0
    for f in ${d}/*
    do
	FILENUM=$[FILENUM+=1]
	FILENAME=${DIR}/"phrack${DIRNUM}".txt
	cat ${f} >> ${FILENAME}
	echo " " >> ${FILENAME}
	# Echo 80 col ASCII line break
	for i in {1..80}; do echo -n "-" >> ${FILENAME}; done
	echo "Issue: ${DIRNUM} Phile: ${FILENUM}" >> ${FILENAME}
	for i in {1..80}; do echo -n "-" >> ${FILENAME}; done
	echo " " >> ${FILENAME}
	rm ${f}
    done
    rmdir ${d}
done
