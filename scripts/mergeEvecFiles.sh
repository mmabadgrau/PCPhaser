if [ $# -ne 2 ]
then
echo You need to enter fn input/output folder and a name for the merged output file
exit 0
fi

folder=$1
file=$1/$2

rm $file

files=`ls $folder/*evec`
index=1
for f in $files
do
if [ $index -eq 1 ]
then
echo file is $file
cp $f $file
else
sed '1d' $f >> $file
fi
index=$[$index+1]
done



