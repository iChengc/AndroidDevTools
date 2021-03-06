#!/bin/bash
# cd to script working directory
script_dir=$(cd `dirname $0` && pwd)
cd $script_dir

function clear_env() {
    #`$adb kill-server > /dev/null > 2`
    rm -rf ./2
}

PLATFORM=`uname`
tmp=`echo $PLATFORM | grep "MINGW32"`

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

case $OS in
    OSX)
      adb=$script_dir/bin/mac_adb ;;
	Windows)
      adb=$script_dir/bin/adb.exe ;;
    *)
      adb=$script_dir/bin/linux_adb ;;
esac

#tm=`whereis adb | awk -F '[: ]+' '{print $0}'`
#echo `whereis adb`
#if [ -n '$tm' ]; then
#        echo hfhfhi
#	adb=$tm
#fi

#kill the default adb server
#`$adb kill-server>/dev/null>2`

#export ANDROID_ADB_SERVER_PORT=1993
#`$adb start-server>/dev/null>2`
#echo $adb
`$adb devices | grep "device$" | awk '{print $1;}' >/dev/null>2`

# The count of the pluged in device(s)
device_count=0

while read buf  
do
 conn_devices[$device_count]=$buf
 device_count=$(expr $device_count + 1)
done < 2

#count=0
if [ $device_count -eq 0 ]
then
    echo "To be continue, please plug in your android device"
    read -p "Press any key to exit..." tmp
    clear_env

    exit 0
# Multiple devices were founded.
elif [ 1 -lt $device_count ]
then 
    echo "-----------------------------"
    for d in ${conn_devices[*]}
    do
        count=$(expr $count + 1)
        echo "-----    ${count}. $d     -----"
    done
    echo "-----------------------------"
    echo "Multiple devices were found please select which device you want to connect(1-$count):"

    while :
    do 
        read num
        if [ $num -gt 0 -a $num -le $count ];
        then
            selected_device=${conn_devices[$(expr $num - 1)]}
            break 1
        else
            echo "please input (1-$count)"
        fi
    done


else 
    selected_device=${conn_devices[0]}
fi

echo Capturing...
capture_dir=$script_dir/captures

if [ ! -d "${capture_dir}" ]; then
  mkdir ${capture_dir}
fi

$adb -s $selected_device shell /system/bin/screencap -p /mnt/sdcard/screenshot.png
screenshot=`date '+%s'`.png

echo Saving screenshot to ${capture_dir}/$screenshot 
`$adb -s $selected_device pull /mnt/sdcard/screenshot.png ${capture_dir}/$screenshot>/dev/null>2`
$adb -s $selected_device shell rm -f -r /mnt/sdcard/screenshot.png
clear_env
