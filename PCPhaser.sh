#!/bin/bash

#Checking whether the arguments are correct
if [ $# -lt 5 ] || [ $# -gt 6 ]; then
	echo -e "Usage: ./PCPhaser.sh [INPUT_FOLDER] [OUTPUT_FOLDER] [OUTPUT_PREFIX] [WIDTH] [HEIGHT] [--silent]" >&2
	exit
else
	#Checking whether the paths end in '/'
	case $1 in
		*/)
			inputPath=$1
			;;
		*)
			inputPath=$1/
			;;
	esac
	case $2 in
		*/)
			outputPath=$2
			;;
		*)
			outputPath=$2/
			;;
	esac

	#Checking whether the folders exist
	if [ ! -d $inputPath ]; then
		echo -e "Folder $inputPath does not exist." >&2
		exit
	fi
	if [ ! -d $outputPath ]; then
		echo -e "Folder $outputPath does not exist." >&2
		exit
	fi
	
        #Checking whether the folders are different

	if [ $inputPath == $outputPath ]; then
		echo -e "Folder $inputPath is the same for input and output"
		exit
	fi

	outputPrefix=$3

	#Checking whether the fourth and fifth arguments are positive integers
	width="$4"
	if ! [[ "$width" =~ ^[0-9]+$ ]] || [[ "$width" -le 0 ]]; then
		echo -e "The value $width is not a postive integer." >&2
		exit
	fi
	height="$5"
	if ! [[ "$height" =~ ^[0-9]+$ ]] || [[ "$height" -le 0 ]]; then
		echo -e "The value $height is not a positive integer." >&2
		exit
	fi

	#Checking whether the silent option has been invoked
	if [ $# -eq 6 ] && [ $6 != "--silent" ]; then
		echo -e "The value $6 is not a valid option." >&2
		exit
	fi
	if [ $# -eq 6 ] && [ $6 == "--silent" ]; then
		silent=true
	else
		silent=false
	fi
fi

#Executing the subscripts to perform every individual task
./scripts/transformSPLIT_HAPLOTYPES.sh $inputPath $outputPath
./scripts/obtainPCA.sh $outputPath $inputPath $outputPath $outputPrefix
if $silent ; then
./scripts/obtainSEGMENT_PLOT.sh $outputPath$outputPrefix.evec $outputPath $width $height --silent
else
./scripts/obtainSEGMENT_PLOT.sh $outputPath$outputPrefix.evec $outputPath $width $height
fi
