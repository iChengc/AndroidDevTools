@echo off
setlocal enabledelayedexpansion
rem %~f0 ==> get the path of the script.
rem %~dp0 ==> get the directory path of the script that holds the script.
rem %[1-9] ==> get the parameters.

rem Set variables
rem set package_name=com.perkinelmer.pivot
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
		goto :EOF
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
	goto :EOF
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
	
	set /p devic_id=发现了!multi_devices_count!台设备，输入要开启wifi调试的设备号（1, !multi_devices_count!）:
	set /a count=0
	for %%d in (!multi_devices!) do (
		set /a count=!count!+1
		if !devic_id! == !count! (
			set selected_devices=%%d
			
			goto InstallStart
		)
	)
	echo 出错了啊！
	goto :EOF
)

:InstallStart
@%adb% -s %selected_devices% tcpip 5555
@%adb% kill-server
echo 安装成功
@ping -n 3 127.1>nul
@echo on

