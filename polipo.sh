#!/bin/bash
# Fedora安装(ubuntu) 教程
#
#Step 1.
# sudo apt-get install polipo

#Step 2.
#修改配置(Linux)
#sudo vim /etc/polipo/config

#Step 3.
#设置ParentProxy为Shadowsocks，通常情况下本机shadowsocks的地址如下:
# #Uncomment this if you want to use a parent SOCKS proxy:

# socksParentProxy = "localhost:1080"
# socksProxyType = socks5

#Step 4.
# 先关闭正在运行的polipo，然后再次启动
# sudo service polipo stop
# sudo service polipo start

# Step 5.
# set the http proxy to http://localhost:8123
# export http_proxy="http://localhost:8123"

echo 是否启动polipo服务（y/n）：
read cmd
if [ $cmd == '' -o $cmd == 'y' -o $cmd == 'Y' ]
then
    sudo service polipo start
    http_proxy="http://127.0.0.1:8123"
elif [ $cmd == 'n' -o $cmd == 'N' ]
then 
    sudo service polipo stop
else
    echo 请输入y或n
fi
