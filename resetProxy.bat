@echo off
setlocal enabledelayedexpansion
rem the proxy host ip address
set Proxy_Host=192.168.11.144
rem the proxy host port the fiddler default proxy port is 8888
set Proxy_Port=8888

set SSID=NextTao

rem %~f0 ==> get the path of the script.
rem %~dp0 ==> get the directory path of the script that holds the script.
rem %[1-9] ==> get the parameters.

rem Set variables
rem set package_name=com.perkinelmer.pivot
set work_dir=%cd%
set script_dir=%~dp0

rem make sure the work directory is in where the script is.
if not "%work_dir%"=="%script_dir%" cd /d "%script_dir%"
call %cd%\bin\Env.bat

set current_dir=%cd%

set adb="%script_dir%\bin\adb"

rem the attached devices count
set device_count=0

rem the flag of no devices count
set no_device_count=0
set devices=
rem the selected device
set selected_devices=
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
	
	echo ������ƭ�Ҹ�����! �豸��������ô���Ҹ���װ����
	echo �����豸�󣬻س�������װ:
	set /p tmp=
	goto DetectDevice )
	
	if !no_device_count!==2 (
	set  /a device_count=0
	
	echo ��˵��Ҫ��ȥ�����豸�ˣ�
	echo �Ͽ�ȥ�����豸�󣬻س�������װ:
	set /p tmp=
	goto DetectDevice ) 
	
	if !no_device_count!==3 (
		set  /a device_count=0
		echo ��һֱ����ƭ�ң��б������ûس����ԣ�
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
			goto ResetWifiProxy
		)
	)
	echo �����˰���
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
	
	set /p devic_id=������!multi_devices_count!̨�豸������Ҫ��װ�����豸�ţ�1, !multi_devices_count!��:
	set /a count=0
	for %%d in (!multi_devices!) do (
		set /a count=!count!+1
		if !devic_id! == !count! (
			set selected_devices=%%d
			goto ResetWifiProxy
		)
	)
	echo �����˰���
	goto :EOF
)

:ResetWifiProxy
echo �������ô���...
%adb% shell input keyevent 3
%adb% shell am start -a android.settings.WIFI_SETTINGS
%adb% shell input tap --longpress 388 388
@echo on
