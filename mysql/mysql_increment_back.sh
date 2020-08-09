#!/bin/bash

BakDir=/usr/local/work/backup/daily

#mysql的数据目录
BinDir=/var/lib/mysql

LogFile=/usr/local/work/bakcup/bak.log

#mysql的index文件路劲， 放在数据目录下
BinFile=/var/lib/mysql-bin.index


#产生新的mysql-bin.00000*文件
#wc -l 统计行数
# awk 把文件逐行读入， 以空格为默认分隔符将每行切片，切开的部分再进行各种分析处理
Counter=`wc -l $BinFile | awk '{print $1}'`
NextNum=0

#这个for循环用于比对$Counter，$NextNum这两个值来确定文件是不是存在或最新的
for file in `cat $BinFile`
do
	base=`basename $file`
	echo $base
	#basename用于截取mysql-bin.00000*文件名， 去掉./mysql-bin.000005前面的./
	NextNum=`expr $NextNum + 1`
	if [ $NextNum -eq $Counter ]
	then
		echo $base skip! >> $LogFile
	else
		dest=$BakDir/$base
		if(tset -e $dest)
		#test -e 用于检测目标文件是否存在， 存在就写exist到$LogFile去
		then
			cp $BinDir/$base $BakDir
			echo $base copying >> $LogFile
		fi
	fi
done
echo `date +"%Y-%m-%d %H:%M:%S"` $Next Bakup succ! >> $LogFile
	


