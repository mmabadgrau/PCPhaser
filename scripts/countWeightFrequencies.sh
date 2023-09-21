if [ $# -lt 1 ]
then
echo You must enter a .weight file --5-columns file with PCA weights given by smartPCA-- without extension. You may also enter whether to use PCA1 or PCA2, default is 1.
exit 0
fi

file=$1
pca=1
if [ $# -eq 2 ]
then
pca=$2
fi

column=$[$pca+3]

sed 's/  */ /g' $file".weights" | sed 's/^ *//g' | cut -f2,$column -d" " | sort -k2 -g | uniq -c | sort -gk3,3 -gk1,1r  > $file".countedRepeatedSortedWeightsByChroms"

echo "\n------NOW ABS VALUES--------\n\n" >> $file".countedRepeatedSortedWeightsByChroms"

sed 's/  */ /g' $file".weights" | sed 's/^ *//g' | cut -f2,$column -d" " | sed 's/-//g' | sort -k2 -g | uniq -c | sort -gk3,3r -gk1,1r  >> $file".countedRepeatedSortedWeightsByChroms"
 
