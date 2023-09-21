#!/bin/bash

#Este script recibe cuatro parámetros: un fichero de entrada, un directorio de salida, la anchura de la imagen de salida y la altura de la imagen de salida.
#El script asume lo siguiente:
#ENTRADA
#1.1 El fichero de entrada ".evec" contiene los datos de un análisis PCA, según el formato de fichero generado por el ejecutable "smartpca" de EIGENSOFT.
#1.2 Cada dos filas consecutivas del fichero ".evec" de entrada contienen la información de dos haplotipos que se representarán unidos por un segmento.
#SALIDA
#2.1 En el directorio de salida se escribirá un fichero ".png" con el mismo nombre que el fichero ".evec" de entrada.
#2.2 Durante el proceso, se crearán en el directorio de salida un fichero temporal por población en el fichero de entrada, que se eliminarán automáticamente al acabar.

#Se comprueba que los argumentos sean correctos
if [ $# -lt 4 ] || [ $# -gt 5 ]; then
	echo "Usage: ./obtainSEGMENT_PLOT.sh.sh [INPUT_FILE] [OUTPUT_FOLDER] [WIDTH] [HEIGHT] [--silent]"
	exit
else
	#Se comprueba que el fichero de entrada exista
	inputFile="$1"
	if [ ! -f "$inputFile" ]; then
		echo -e "File $inputFile does not exist." >&2
		exit
	fi
	#Se comprueba que el directorio de salida acabe en '/', y que exista
	case $2 in
		*/)
			outputFolder=$2
			;;
		*)
			outputFolder=$2/
			;;
	esac	
	if [ ! -d $outputFolder ]; then
		echo -e "Folder $outputFolder does not exist." >&2
		exit
	fi		
	#Se comprueba que el tercer y cuarto argumento sean números positivos enteros
	width="$3"
	if ! [[ "$width" =~ ^[0-9]+$ ]] || [[ "$width" -le 0 ]]; then
		echo -e "The value $width is not a postive integer." >&2
		exit
	fi
	height="$4"
	if ! [[ "$height" =~ ^[0-9]+$ ]] || [[ "$height" -le 0 ]]; then
		echo -e "The value $height is not a positive integer." >&2
		exit
	fi
	if [ $# -eq 5 ] && [ $5 != "--silent" ]; then
		echo -e "The value $5 is not a valid option." >&2
		exit
	fi
	if [ $# -eq 5 ] && [ $5 == "--silent" ]; then
		silent=true
	else
		silent=false
	fi
fi

#Se convierte el formato de los datos de entrada según el requerido por ploteig
cleanData=$(tail -n +2 $inputFile | sed "s/^ *//;s/ *$//;s/ \{1,\}/ /g" | cut -d ' ' -f 1 --complement | sed "N;s/\n/ /" | cut -d ' ' -f 3 --complement)

#Se extraen las etiquetas de cada una de las poblaciones
populationNames=$(cut -d " " -f 5 <(echo -ne "$cleanData") | sort -u)

#Se separan los datos por poblaciones en varios ficheros temporales
while read line
do
	for populationName in $populationNames
	do
		if [[ $(echo -ne $line | cut -d " " -f 5) == $populationName ]]
		then
			echo -e $line >> $outputFolder"TempFileForPopulation"$populationName".temp"
		fi
	done
done < <(echo -e "$cleanData")

#Se crean los comandos para gnuplot
plotCommands=$plotCommands"set title \"PCA segment haplotype graph\"\n"
plotCommands=$plotCommands"set key outside\n"
plotCommands=$plotCommands"set size square\n"
plotCommands=$plotCommands"set xlabel \"PCA 1\"\n"
plotCommands=$plotCommands"set ylabel \"PCA 2\"\n"
plotCommands=$plotCommands"set pointsize 1.5\n"
plotCommands=$plotCommands"set terminal pngcairo size \"$width\",\"$height\" enhanced font 'Verdana,10'\n"
plotCommands=$plotCommands"set output \""$outputFolder$(echo $inputFile | sed 's/.*\///;s/.evec$//')".png\"\n"
plotCommands=$plotCommands"plot"
i=1
for populationName in $populationNames
do # vectors nohead lc $i
	numberIndividuals=$[$(grep -c -w $populationName $inputFile) / 2]
	plotCommands=$plotCommands" \""$outputFolder"TempFileForPopulation"$populationName".temp\" using 1:2:(\$3-\$1):(\$4-\$2) with linespoints title \""$populationName" ("$numberIndividuals" individuals)\"," # \"\" using 1:2 lt $i pt $i notitle, \"\" using 3:4 lt $i pt $i notitle," #notitle
	let i++
done

#Se llama a gnuplot
if $silent ; then
	gnuplot <(echo -ne "${plotCommands%?}")
else
	plotCommands=${plotCommands%?}"\n!display $outputFolder$(echo $inputFile | sed 's/.*\///;s/.evec$//').png"
	gnuplot <(echo -ne $plotCommands)
fi

#Se eliminan los ficheros temporales intermedios
for populationName in $populationNames
do
	rm -Rf $outputFolder"TempFileForPopulation"$populationName".temp"
done

