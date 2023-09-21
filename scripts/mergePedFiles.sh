#!/bin/bash

#Este script recibe cuatro parámetros: dos directorios de entrada, un directorio de salida y un prefijo de salida.
#El script asume lo siguiente:
#ENTRADA
#1.1 El primer directorio de entrada contiene ficheros en formato ".ped".
#1.2 El segundo directorio de entrada contiene ficheros en formato ".map".
#1.3 Los ficheros ".ped" relativos a la misma población tienen todos el mismo nombre, excepto por un número del 1 al 22 justo antes de la extensión, indicando el cromosoma al que se refieren.
#1.4 Los ficheros ".map" tienen todos el mismo nombre, excepto por un número del 1 al 22 justo antes de la extensión, indicando el cromosoma al que se refieren.
#SALIDA
#En el directorio de salida se escribirá un único fichero ".ped" para todas las poblaciones.

#Se comprueba que los argumentos sean correctos
if [ $# -ne 4 ]; then
	echo -e "Usage: ./obtainPCA.sh [PED_FOLDER] [MAP_FOLDER] [OUTPUT_FOLDER] [OUTPUT_PREFIX]" >&2
	exit
else
	#Se comprueba que las rutas acaben en '/'
	case $1 in
		*/)
			pedPath=$1
			;;
		*)
			pedPath=$1/
			;;
	esac
	case $2 in
		*/)
			mapPath=$2
			;;
		*)
			mapPath=$2/
			;;
	esac
	case $3 in
		*/)
			outputPath=$3
			;;
		*)
			outputPath=$3/
			;;
	esac
	outputPrefix=$4
	#Se comprueba que los directorios existan
	if [ ! -d $pedPath ]; then
		echo -e "Folder $pedPath does not exist." >&2
		exit
	fi
	if [ ! -d $mapPath ]; then
		echo -e "Folder $mapPath does not exist." >&2
		exit
	fi
	if [ ! -d $outputPath ]; then
		echo -e "Folder $outputPath does not exist." >&2
		exit
	fi	
fi


#Se extraen los ficheros ".map"
mapFiles=($(ls -v $mapPath*.map))

#Se agrupan todos los ficheros de posiciones en un solo archivo
cat ${mapFiles[0]} > $outputPath$outputPrefix".map"
for ((i = 1; i < ${#mapFiles[@]}; i++))
do
	cat $outputPath$outputPrefix".map" ${mapFiles[$i]} | sponge $outputPath$outputPrefix".map"
done

#Se extraen las poblaciones de los nombres de los ficheros ".ped"
populationNames=($(ls -v $pedPath*.ped | sed 's/.*\///;s/\(.*[^0-9]\)[0-9]*.ped$/\1/' | uniq))


#Se crea el nombre del fichero de salida
outputName=$outputPath$outputPrefix


rm -f $outputName.ped

# Para cada población
for ((i = 0; i < ${#populationNames[@]}; i++))
do
echo Adding pop ${populationNames[i]} to file $outputName.ped
	#Se extraen los ficheros con el nombre de la población actual
	pedFiles=($(ls -v $pedPath${populationNames[i]}*.ped))
	#Se añade el nombre de la población al nombre de los ficheros de salida 
	outputName_pop=$outputName"_"${populationNames[i]}
#Se unen todos los ficheros ".ped" relativos a la población actual 
echo Pasting all ped files for all chromosomes
cp ${pedFiles[0]} $outputName_pop.ped
echo file ${pedFiles[0]}
	for ((j = 1; j < ${#pedFiles[@]}; j++))
	do
echo file ${pedFiles[$j]}
		paste -d ' ' $outputName_pop.ped <(cut -d ' ' -f 7- ${pedFiles[$j]}) | sponge $outputName_pop.ped

	done

#Se añade el nuevo ".ped" de la población actual al fichero .ped necesario para el análisis
echo Adding $outputName_pop".ped" to $outputName.ped
        cat $outputName_pop.ped >> $outputName.ped
rm $outputName_pop.ped
done	
	




