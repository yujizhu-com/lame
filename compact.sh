#!bin/bash

Echo() { if $2 ;then echo $1;fi; }
FileSize() { local fileInfo=`wc -c $1`;local array=(${fileInfo});local fileSize=${array[0]};echo $fileSize; }
BToM() { echo $(echo "scale=3; $1/1024/1024 " | bc ); }
_New(){ if [[ "$1" =~ ^.*/[^\.]+$ ]];then mkdir "$1";elif [[ "$1" =~ ^.*/?\..+$ ]];then touch "$1";fi; }
Main()
{
	local Dir=$1;Echo $Dir false
	local OutDir=$Dir"_out";_New $OutDir

	local files=`find $Dir -name '*.mp3'`
	local oldSize=0
	local newSize=0
	for file in $files
	do
		echo $file
		((oldSize+=`FileSize $file`))

		local name=`basename $file`;
		local outdir=`dirname $OutDir${file#*$Dir}`;_New $outdir
		local newfile=$outdir"/"$name
		lame --quiet --mp3input --abr 64 $file $newfile
		
		((newSize+=`FileSize $newfile`))
	done
	oldSize=`BToM $oldSize`
	newSize=`BToM $newSize`
	local diff=$(echo "scale=3; $oldSize-$newSize " | bc )
	echo 压缩前: $oldSize M
	echo 压缩后: $newSize M
	echo 节约: $diff M
}
Main $1