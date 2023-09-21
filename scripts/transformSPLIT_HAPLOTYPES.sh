#!/bin/bash

#Este script recibe dos parámetros: un directorio de entrada y un directorio de salida.
#El script asume lo siguiente:
#ENTRADA
#1.1 El directorio de entrada contiene ficheros en formato ".ped".
#SALIDA
#2.1 En el directorio de salida se escribirán tantos ficheros ".ped" como ficheros ".ped" originales haya en el directorio de entrada, con el mismo nombre.
#2.2 Los ficheros .ped de salida contendrán dos individuos por cada uno que contengan los ficheros ".ped" originales.
#2.3 En la segunda columna se escribirá la ID del individuo original, seguida de "_1" o "_2" según si es el primer o el segundo individuo generado (para que la ID del individuo sea única).
#2.4 Para cada individuo original, el primer individuo creado sobrescribirá su haplotipo derecho con su izquierdo, y viceversa para el segundo, de la siguiente forma:
#     INDIVIDUO ORIGINAL ---> 2427 19909 0 0 2 ASW 1i 1d 2i 2d 3i 3d 4i 4d
#     INDIVIDUO IZQUIERDO --> 2427 19909_1 0 0 2 ASW 1i 1i 2i 2i 3i 3i 4i 4i
#     INDIVIDUO DERECHO ----> 2427 19909_2 0 0 2 ASW 1d 1d 2d 2d 3d 3d 4d 4d

#Se comprueba que los argumentos sean correctos
if [ $# -ne 2 ]; then
	echo -e "Usage: ./transformSPLIT_HAPLOTYPES.sh [INPUT_FOLDER] [OUTPUT_FOLDER]" >&2
	exit
else
	#Se comprueba que las rutas acaben en '/'
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
	#Se comprueba que los directorios existan
	if [ ! -d $inputPath ]; then
		echo -e "Folder $inputPath does not exist." >&2
		exit
	fi
	if [ ! -d $outputPath ]; then
		echo -e "Folder $outputPath does not exist." >&2
		exit
	fi	
fi

#Se extraen los ficheros ".ped"
pedFiles=($(ls -v $inputPath*.ped))

#Se generan los nuevos ficheros ".ped" 
pedFiles=($(ls -v "$inputPath"*.ped))
for ((i = 0; i < "${#pedFiles[@]}"; i++))
do
	awk '
		{
			printf $1 OFS $2"_1" OFS $3 OFS $4 OFS $5 OFS $6 OFS
			for(i = 7; i <= NF; i += 2){
				printf $i OFS $i
				printf (i < NF - 1) ? OFS : "\n"
			}
			printf $1 OFS $2"_2" OFS $3 OFS $4 OFS $5 OFS $6 OFS
			for(i = 7; i <= NF; i += 2){
				printf $(i+1) OFS $(i+1)
				printf (i < NF - 1) ? OFS : "\n"
			}
		}
	' ${pedFiles[$i]} > $outputPath$(echo ${pedFiles[$i]} | sed 's/.*\///')
done
