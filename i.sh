#!/bin/bash
#str="123#abc#@&?"  
#`awk 'BEGIN { split("'"$str"'",a,"#")}  
#     END   { for (i in a) {print a[i];$count++; }}'  /dev/null > 2`  
#`adb devices | grep "device" | awk '{print $1;}' >/dev/null>2`      
#while read buf  
#do
# echo $buf  
# tArray[$c]=$buf  
# c=$(expr $c + 1)  
#done < 2  
#echo "array len:" $c
#for i in ${tArray[@]} 
#do
 # echo $i  
#done

#arr[0]=ooo
#arr[1]=ppp
#for i in ${arr[@]}
#do
# echo $
#done
# read num
# if [ $num > 0 -a $num < 5 ]
# then
#    echo "eeeeeee"
#fi
#name="9884737&3ii2i3&88363"
#echo $name
#awk 'BEGIN {split('"\"$name\""', a, "&");print "rrrr";}END{}'

#echo "------"
#while read buf  
#do
# echo $buf  
# apk_path=$buf  
 #c=$(expr $c + 1)  
#done < 2
PLATFORM=`uname`
echo $PLATFORM
tmp=`echo $PLATFORM | grep "MINGW32"`
echo $tmp
if [ -z "$tmp" ]
then
    case $PLATFORM in
      HP-UX)
        OS=HP-UX ;;
      AIX)
        OS=AIX ;;
      Darwin)
        OS=OSX ;;
      SunOS)
        OS=SunOS ;;
      Linux)
        if [ -s /etc/oracle-release ]; then
            OS=Oracle
        elif [ -s /etc/SuSE-release ]; then
            OS=SuSE
        elif [ -f /etc/centos-release ]; then
            OS=CentOS
        elif [ -s /etc/redhat-release ]; then
            OS=RedHat
        elif [ -r /etc/os-release ]; then
            grep 'NAME="Ubuntu"' /etc/os-release > /dev/null 2>&1
            if [ $? == 0 ]; then
                OS=Ubuntu
            fi
        else
            OS="Unknown Linux"
        fi ;;
      *)
        OS="Unknown UNIX/Linux" ;;
    esac
else
    OS="Windows"
fi
echo $OS
if [ "$OS" == "Windows" ]
then
    screenshot=`date '+%s'`.png
	echo $screenshot
    echo ppppppppppppppppppppp
fi 
read dd
