#!/bin/bash
# cd to script working directory
script_dir=$(cd `dirname $0` && pwd)
cd $script_dir
apkName='shopforce.apk'
apkPath='./'$apkName
echo 商米Pos机App安装程序
curl -H "Cookie: instance0|session_id=%2295c3032511f045f9b406dc7f28a035a1%22; last_used_database=app_dist;x-nt-session=0a77f70a-2b1c-11e8-a89e-52540092c49b; sid=4180a2adff8a01ce91df778118942a
ca857ffcb5" -d "{\"app_random\":\"83607429\"}" dist.nexttao.com/api/nt.app.distribute.adapter/get_app.api >> 2
apkurl=`awk -F '[",]' '{print $29}' 2`

curl $apkurl -o $apkPath
# echo 请确保Apk安装包名字为shopforce.apk,并且与安装脚本在同一目录下
echo ------------------------------------------------------------
echo 
echo

ip=`head -n 1 ./ip.bat | awk -F '=' '{print $2}'`
#echo $ip
if [ -z '$ip' ]; then 
   echo 安装前请确保已在IP.txt中设置商米Pos机的wifi IP地址
   echo 若未设置请先设置再重启改脚本
   read
   exit 0
fi

function clear_env() {
    `$adb kill-server > /dev/null > 2`
    rm -rf ./2
    rm -rf -d ./cache
    #echo `$adb devices`
}

function connect_device() {

    echo 正在连接到商米$1
    `$adb connect $ip:$2 > /dev/null > 2`
    isConnected=`cat ./2 | grep 'connected to '`
    if [ -z "${isConnected}" ]; then
      echo "无法连接到商米$1"
      clear_env
      #exit 0
    else

      sleep 1
      #echo `$adb devices`
      `$adb devices | grep "device$" | awk '{print $1;}' >/dev/null>2`

      # The count of the pluged in device(s)
      device_count=0

      while read buf  
      do
        conn_devices[$device_count]=$buf
        device_count=$(expr $device_count + 1)
      done < 2

      #count=0
      if [ $device_count -eq 0 ];
      then
        echo "无法连接到商米$1"
        read -p "Press any key to exit..." tmp
        clear_env

        exit 0
      fi
    fi
}

function install_apk() {
    echo "正在安装$apkName到商米$1"
    result=`$adb -s $ip:$2 install -r $apkPath`
    isSuccess=`echo $result | grep Success`
    # cast the result to string
    isSuccess="${isSuccess}"
    #echo $isSuccess
    if [ -z "$isSuccess" ]; then
      echo 安装出错：${result}
	    read -p "Press any key to exit..." tmp
      clear_env
      exit 0
    else
      echo $apkName已成功安装到商米$1
    fi
}

PLATFORM=`uname`
tmp=`echo $PLATFORM | grep "MINGW32"`

if [ -z "$tmp" ];
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

#tm=`whereis adb | awk -F '[: ]+' '{print $2}'`
#echo $tm
#if [ -n '$tm' ]; then
#	adb=$tm
#fi
#echo $adb
#echo $adb

#kill the default adb server
`$adb kill-server>/dev/null>2`
#export ANDROID_ADB_SERVER_PORT=1993
`$adb start-server>/dev/null>2`

connect_device '主屏' 5555
install_apk '主屏' 5555

connect_device '副屏' 5554
install_apk '副屏' 5554

echo 安装成功
clear_env
