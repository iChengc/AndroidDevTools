@echo off
setlocal enabledelayedexpansion
set apkName=shopforce.apk
set apkPath=.\\%apkName%

set work_dir=%cd%
set script_dir=%~dp0

rem make sure the work directory is in where the script is.
if not "%work_dir%"=="%script_dir%" cd /d "%script_dir%"
rem call "%cd%\bin\Env.bat"

set current_dir=%cd%

call %current_dir%\ip.bat

rem Download app from dist
set curl=%cd%\bin\curl\curl.exe
%curl% -H "Cookie: instance0|session_id=%2295c3032511f045f9b406dc7f28a035a1%22; last_used_database=app_dist;x-nt-session=0a77f70a-2b1c-11e8-a89e-52540092c49b; sid=4180a2adff8a01ce91df778118942aca857ffcb5" -d "{\"app_random\":\"83607429\"}" dist.nexttao.com/api/nt.app.distribute.adapter/get_app.api >.\2

for /f tokens^=23^ delims^=^" %%i in ('findstr /r /c:"\<http.*\.apk\>" ".\2"') do  set apkUrl=%%i

%curl% %apkUrl% -o %apkPath%

DEL .\2

rem the attached devices count
set /a device_count=0

set devices=
rem the selected device
set adb="%script_dir%bin\adb.exe"

rem for /f "usebackq" %%i in (`"@where adb"`) do @set var=%%i
rem if %var% NEQ "" (
rem    %adb%=%var%
rem )

@%adb% kill-server>.\2

rem Change the adb server port
set ANDROID_ADB_SERVER_PORT=1993
@%adb% start-server>.\2
call :connect_device 主屏 5555
call :install_apk 主屏 5555
echo 
echo ------------------
echo
call :connect_device 副屏 5554
call :install_apk 副屏 5554

echo 安装成功
call :clear_env
goto :exit

:clear_env
    @%adb% kill-server
    rem @RD /S /Q cache
    @DEL .\2
    @ping -n 3 127.1>nul
    goto :eof

:connect_device
    @echo 正在连接到商米%1
    @%adb% connect %ip%:%2>.\2
    
    @ping -n 2 127.1>nul
    rem findstr /C:"connected to" %current_dir%\2
    for /f "delims=" %%i in ('findstr C:/"connected to" .\2') do (
        set isConnected=%%i
    )
    if "%isConnected%"=="" (
      echo 无法连接到商米%1
      call :clear_env
      goto :eof
    ) else (
      @%adb% devices>.\2
    
     for /f "delims=" %%i in ('findstr "device$" .\2') do (
        set devices=!devices! %%i
    	set  /a device_count = !device_count! + 1
     )
  
      if !device_count!==0 (
        echo 无法连接到商米%1
        call :clear_env
        pause 1
        goto :exit
      )
    goto :eof
   )

:install_apk
    echo 正在安装 %apkName% 到商米%1
    echo "" >.\2
    for /f "delims=" %%i in ('@%adb% -s %ip%:%2 install -r %apkPath%') do (
       echo %%i>>.\2
     )
 
    for /f "delims=" %%i in ('findstr "Success" .\2') do (
        set isSuccess=%%i
    )

    if "%isSuccess%" == "" (
      echo 安装出错
      call :clear_env
     
      goto :exit
    ) else (
      echo %apkName%已成功安装到商米%1
    )
goto :eof

:exit
pause 1
@echo on
exit 0
