#!/bin/bash
# This is a script to archive the single Java file to a jar lib
cdir=$(cd `dirname $0` && pwd)
cd $cdir

# Get the path of the Java file.
echo "添加Java文件(只支持单个Java文件):"
read tmp

# Remove character ' and change '~' to absolute path
filePath=$(echo $tmp | sed "s/'//g" | sed 's?^~?'"$HOME"'?')

# Read the pakage componets of the Java class. 
# e.g: If the package is defined to 'package com.example.class',
# then it will return a list contains 'com example class'.
OUTFILE=`head -n 1 $filePath | awk -F '[.; ]' '{for(i=2;i<NF;++i)  print $i}'`

classPath=""
rootPath=""
# reference http://blog.csdn.net/hunanchenxingyu/article/details/9998089
while read line
do
  if [ "$classPath" = "" ]; then
    classPath=$line
    rootPath=$line
  else
    classPath=$classPath/$line
  fi
  mkdir $classPath
done << EOF
  $OUTFILE
EOF

cp $filePath $(pwd)/$classPath/  
#path=$(echo $tmp | awk -F "[\\']" '{print $2}' | awk 'BEGIN{FS=".java"}{print $1}')

jar_name=$(echo $filePath | awk -F "[/.]" '{print $(NF-1)}')

javac -d . $filePath

if [ -f $(pwd)/$classPath/$jar_name.class ]; then
  jar cvf $jar_name.jar $classPath/*.class
else
  echo 编译出错
fi
rm -rf $rootPath
