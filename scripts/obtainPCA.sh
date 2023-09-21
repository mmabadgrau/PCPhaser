#!/bin/bash

#Este script recibe cuatro parámetros: dos directorios de entrada, un directorio de salida y un prefijo de salida.
#El script asume lo siguiente:
#ENTRADA
#1.1 El primer directorio de entrada contiene ficheros en formato ".ped".
#1.2 El segundo directorio de entrada contiene ficheros en formato ".map".
#1.3 Los ficheros ".ped" relativos a la misma población tienen todos el mismo nombre, excepto por un número del 1 al 22 justo antes de la extensión, indicando el cromosoma al que se refieren.
#1.4 Los ficheros ".map" tienen todos el mismo nombre, excepto por un número del 1 al 22 justo antes de la extensión, indicando el cromosoma al que se refieren.
#SALIDA
#2.1 En el directorio de salida se escribirá un fichero ".evec" por población que haya en el directorio de entrada, con el mismo nombre pero sin número.
#2.2 Los ficheros ".evec" contendrán el resultado del PCA de las poblaciones de entrada.
#2.3 Para realizar el PCA, se creará en el directorio de salida un fichero ".ped" por población que agrupará todos los cromosomas, y se eliminará automáticamente al acabar.
#2.4 Para realizar el PCA, se creará en el directorio de salida un fichero ".map" que agrupará todos los cromosomas, y se eliminará automáticamente al acabar.
#2.5 Para realizar el PCA, se creará en el directorio de salida un fichero ".par" por población que contendrá los parámetros necesarios para el análisis, y se eliminará automáticamente al acabar.
#2.6 Durante la ejecución del PCA, se crearán en el directorio de salida ficheros ".log" y ".eval" que se eliminarán automáticamente al acabar.

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

#Se asigna a una constante la ruta en las que se encuentra el ejecutable "smartPCA" de EIGENSOFT
readonly smartpcaPath="../EIG/bin/smartpca"


# se obtiene un único fichero ped uniéndolos todos:
./mergePEDFiles.sh $1 $2 $3 $4 


#Se crea el nombre del fichero de salida
outputName=$outputPath$outputPrefix

#Se crea el fichero de parámetros para realizar el PCA
	echo -e "genotypename:    "$outputName".ped" > $outputName".par"
	echo -e "snpname:         "$outputPath$outputPrefix".map" >> $outputName".par"
	echo -e "indivname:       "$outputName".ped" >> $outputName".par"
	echo -e "evecoutname:     "$outputName".evec" >> $outputName".par"
	echo -e "evaloutname:     "$outputName".eval" >> $outputName".par"
	echo -e "numoutevec:      2" >> $outputName".par"
	echo -e "numoutlieriter:  0" >> $outputName".par"
        echo -e "snpweightoutname:	"$outputName".weights" >> $outputName".par"
	#Se realiza el PCA
echo running $smartpcaPath -p $outputName".par" 
	$smartpcaPath -p $outputName".par" > $outputName".log"
	#Se eliminan los ficheros temporales intermedios
#	rm -f $outputName".ped"
#	rm -f $outputName".par"
#	rm -f $outputName".log"
#	rm -f $outputName".eval"

# rm -f $outputPath$outputPrefix".map"
