@echo off
setlocal enabledelayedexpansion

set SRC=Z:\Documents\s4001_plc
set DST=C:\Users\Gianfranco\Documents\s4001_plc

set CONFIG=sync_dirs.txt


rem ---- Load directories from file or create default ----
if exist %CONFIG% (
    set DIRS=
    for /F "delims=" %%D in (%CONFIG%) do (
        set DIRS=!DIRS! %%D
    )
) else (
    echo Core > %CONFIG%
    set DIRS=Core
)


:RUN_LOOP
cls
echo ==========================================
echo Current directories: %DIRS%
echo ==========================================

for %%D in (%DIRS%) do (
    echo Syncing %%D ...
    robocopy "%SRC%\%%D" "%DST%\%%D" /MIR /FFT /R:1 /W:1
)

echo.
echo Done at %TIME%
echo.
echo Current directories: %DIRS%
echo Press ENTER to run again
echo Type M for menu
echo Type Q to quit
echo.

set KEY=
set /p KEY="Choice: "

if "%KEY%"=="" goto RUN_LOOP
if /I "%KEY%"=="M" goto MENU
if /I "%KEY%"=="Q" exit

goto RUN_LOOP


:MENU
cls
echo ========= MENU =========
echo 1 - Add directory
echo 2 - Remove directory
echo 3 - Run
echo Q - Quit
echo ========================

choice /C 123Q /N /M "Select option: "

if %ERRORLEVEL%==1 goto ADD
if %ERRORLEVEL%==2 goto REMOVE
if %ERRORLEVEL%==3 goto RUN_LOOP
if %ERRORLEVEL%==4 exit


:ADD
cls
echo Current directories: %DIRS%
echo.
echo Type directory name to add
echo Leave empty and press ENTER to go back.

set NEWDIR=
set /p NEWDIR=Directory: 

if not defined NEWDIR goto MENU

echo %NEWDIR% >> %CONFIG%

rem Reload list
set DIRS=
for /F "delims=" %%D in (%CONFIG%) do (
    set DIRS=!DIRS! %%D
)

goto ADD


:REMOVE
cls
echo Directories:

set COUNT=0
for %%D in (%DIRS%) do (
    set /a COUNT+=1
    echo !COUNT!: %%D
)

echo.
echo Type number to remove, or ENTER to go back.

set REMNUM=
set /p REMNUM=Choice: 

if not defined REMNUM goto MENU


set INDEX=0
break > %CONFIG%

for %%D in (%DIRS%) do (
    set /a INDEX+=1
    if not "!INDEX!"=="%REMNUM%" (
        echo %%D >> %CONFIG%
    )
)

rem Reload list
set DIRS=
for /F "delims=" %%D in (%CONFIG%) do (
    set DIRS=!DIRS! %%D
)

goto REMOVE
