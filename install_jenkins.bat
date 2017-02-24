@echo off
setlocal enabledelayedexpansion
set jenkinsUserName=xin_lei
set jenkinsPassword=Initial0

set work_dir=%cd%
set script_dir=%~dp0

rem make sure the work directory is in where the script is.
if not "%work_dir%"=="%script_dir%" cd /d "%script_dir%"
rem call "%cd%\bin\Env.bat"

set current_dir=%cd%

rem the attached devices count
set device_count=0

rem the flag of no devices count
set no_device_count=0
set devices=
rem the selected device
set selected_devices=
set adb="%script_dir%\bin\adb"
set curl="%script_dir%\bin\curl\bin\curl.exe"
@%adb% kill-server

rem Change the adb server port
set ANDROID_ADB_SERVER_PORT=1993
@%adb% start-server

:DetectDevice 
for /f "delims=" %%i in ('%adb% devices') do (
	set devices=!devices! %%i
    set  /a device_count=!device_count!+1
	rem echo !device_count! %%~ni
)

rem for %%i in (%devices%) do echo %%i

if !device_count! == 1 (
	set /a no_device_count =!no_device_count!+1
	if !no_device_count!==1 (
	set  /a device_count=0
	
	echo 你在欺骗我感情嘛! 设备都不连怎么让我给你装啊！
	echo 插上设备后，回车继续安装:
	set /p tmp=
	goto DetectDevice )
	
	if !no_device_count!==2 (
	set  /a device_count=0
	
	echo 都说了要你去插上设备了！
	echo 赶快去插上设备后，回车继续安装:
	set /p tmp=
	goto DetectDevice ) 
	
	if !no_device_count!==3 (
		set  /a device_count=0
		echo 你一直在欺骗我，有本事再敲回车试试！
		set /p tmp=
		rem goto :EOF
		goto ClenUP
	)
)


set count=0
set device_name_index=5
if !device_count! == 2 (
	for %%i in (!devices!) do (
		set /a count=!count!+1
		if !count! == 5 (
			set selected_devices=%%i
			goto InstallStart
		)
	)
	echo 出错了啊！
	rem goto :EOF
	goto ClenUP
)

set /a count=0
set multi_devices=
set multi_devices_count = 0
if !device_count! geq 3 (
	for %%i in (!devices!) do (
		set /a count=!count!+1
		if !count! == !device_name_index! (
			set /a device_name_index=!device_name_index!+2
			set /a multi_devices_count=!multi_devices_count!+1
			set multi_devices=!multi_devices! %%i
			echo !multi_devices_count! %%i
		)
	)
	
	set /p devic_id=发现了!multi_devices_count!台设备，输入要安装到的设备号（1, !multi_devices_count!）:
	set /a count=0
	for %%d in (!multi_devices!) do (
		set /a count=!count!+1
		if !devic_id! == !count! (
			set selected_devices=%%d
			goto InstallStart
		)
	)
	echo 出错了啊！
	rem goto :EOF
	goto ClenUP
)

:InstallStart
set packageWillInstall=%~dp0\iPos.apk
echo 请输入Jenkins build Url:
set jenkinsUrl=""
set /p jenkinsUrl=
if %jenkinsUrl%=="" (
	echo 出错了啊！
	rem goto :EOF
	goto ClenUP
)

rem :LoginJenkins
mkdir cache
set cookiesLoc=%~dp0\cache\cookies
set jenkinsLoginUrl="https://jenkins.nexttao.com/j_acegi_security_check"
set loginInfo="j_username=jinhai_ma&j_password=Initial0&from=/&json={\"j_username\": \"jinhai_ma\", \"j_password\": \"Initial0\", \"remember_me\": false, \"from\": \"/\"}&Submit=登录"
rem set loginInfo='j_username=%jenkinsUserName%&j_password=%jenkinsPassword%0&remember_me=on&from=/&json={"j_username": "%jenkinsUserName%", "j_password": "%jenkinsPassword%", "remember_me": true, "from": "/"}&Submit=登录'
@curl -c %cookiesLoc% -d %loginInfo% %jenkinsLoginUrl% 

rem set cookies="ACEGI_SECURITY_HASHED_REMEMBER_ME_COOKIE="eGluX2xlaToxNDg3NzMxNjEyNjIxOjhmOGZmOWU3MTc0MDIyNGQxNThiNTYwYWY0MjUxN2JjMTYxY2FmOGNhNTAwZTQ0NmM2ODhjNjA2YzBkNTg0MGM="; screenResolution=1366x768; JSESSIONID.7551707a=1ewkwfykwxapq9gua452oqjgl"
@%curl% -b %cookiesLoc% %jenkinsUrl% -o %packageWillInstall%

echo 正在安装%packageWillInstall% 到 %selected_devices%...

rem @adb -s %selected_devices% uninstall %package_name%
@%adb% -s %selected_devices% push %packageWillInstall% /mnt/sdcard/1.apk
@%adb% -s %selected_devices% shell pm install -r /mnt/sdcard/1.apk
echo 安装完成

:ClenUP
@%adb% kill-server
@RD /S /Q cache
@ping -n 3 127.1>nul
@echo on

