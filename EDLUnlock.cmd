@ECHO OFF
CD /D "%~dp0" >nul
SET THISBAT=%~0
SET THISPATH=%~dp0
IF "%~1" == "-hex" (
	REM Work-around for calling batch-label inside a for loop
	CALL :DecToHex "%~2"
	EXIT /B %ERRORLEVEL%
)

SETLOCAL enableextensions enabledelayedexpansion
SET ERROR=0

:: Rotate log
IF EXIST log.txt (
	IF EXIST log.previous.txt (
		DEL log.previous.txt
	)
	MOVE log.txt log.previous.txt
)


CALL :CLEAR_TITLE

:: load config
ECHO [#] Reading configured COM port...
CALL :READ_CONFIG_INI COMPort CONFIG_COMPORT
ECHO         %CONFIG_COMPORT%
ECHO [#] Reading configured Firehose loader binary path...
CALL :READ_CONFIG_INI FirehoseLoader CONFIG_LOADER
ECHO         %CONFIG_LOADER%
ECHO [#] Reading configured transfer speed...
CALL :READ_CONFIG_INI TransferSpeed CONFIG_SPEED
ECHO         %CONFIG_SPEED%
ECHO.

:MAIN_MENU
ECHO [i] Make your choice:
ECHO.
ECHO     1) Unlock your device
ECHO.
ECHO     2) Reboot (exit EDL mode)
ECHO.
ECHO     3) Quit
ECHO.
ECHO.
SET CHOICE_MAIN=
SET /P CHOICE_MAIN="[#] Enter number: "
ECHO.

IF "%CHOICE_MAIN%"=="1" (
	CALL :CHOICE_UNLOCK
) ELSE IF "%CHOICE_MAIN%"=="2" (
	CALL :CHOICE_REBOOT
) ELSE IF "%CHOICE_MAIN%"=="3" (
	EXIT /B
) ELSE (
	ECHO [^^!] Invalid option.
)

:ERROR_END
SET ERROR=0
REM clean the log file
IF EXIST "%THISPATH%\log.txt" (
	FINDSTR /V "Sectors remaining " "%THISPATH%\log.txt" > "%THISPATH%\log.clean.txt"
	MOVE /Y "%THISPATH%\log.clean.txt" "%THISPATH%\log.txt" >nul
)
ECHO [i] Press any key to return to main menu.
PAUSE>NUL
CALL :CLEAR_TITLE
GOTO :MAIN_MENU

:ERROR
ECHO.
ECHO [^^!] An error occured. %~1. Check device connection and COM port is correct.
ECHO [^^!] See log.txt for details.
ECHO.
GOTO :EOF

:CHOICE_REBOOT
ECHO [#] Press any key to exit EDL mode.
PAUSE>NUL
"%THISPATH%\bin\emmcdl.exe" -p %CONFIG_COMPORT -r
IF ERRORLEVEL 1 (
	CALL :ERROR "Unable to exit EDL mode!"
	GOTO :ERROR_END
)
ECHO.
ECHO [i] All done^^!
GOTO :EOF

:CHOICE_UNLOCK
SET CHOICE_BACKUPPATH="bin"
CALL :RESTORE_VERIFY_PATH !CHOICE_BACKUPPATH!
IF "!ERROR!"=="1" (
	ECHO [^^!] Missing rawprogram0.xml! Did you download correctly everything?
	GOTO :ERROR_END
)
REM Verified, go!
ECHO [#] Press any key to start the unlock process.
ECHO [#] This may take some time. 
ECHO [#] All output will be in the window [not the log] to show progress.
PAUSE>NUL
CD /D !CHOICE_BACKUPPATH!
"%THISPATH%\bin\emmcdl.exe" -p %CONFIG_COMPORT% -f "%THISPATH%\%CONFIG_LOADER%" -x "!CD!\rawprogram0.xml" -MaxPayloadSizeToTargetInBytes %CONFIG_SPEED%
IF ERRORLEVEL 1 (
	CALL :ERROR "Unlock Failed!"
	GOTO :ERROR_END
)
ECHO.
ECHO [i] All done^^!
CD /D "%THISPATH%"
GOTO :EOF

:RESTORE_VERIFY_PATH
IF NOT EXIST "bin\rawprogram0.xml" (
	SET ERROR=1
	GOTO :EOF
)
GOTO :EOF

REM Thanks to emuzychenko for this batch wizardry
:DecToHex
SETLOCAL enabledelayedexpansion
SET DecNum=%~1
SET DigTable=0123456789abcdef
SET HexRes=
:DecToHex_Loop
SET /A DecNumQ=%DecNum% / 16
SET /A DecRmd=%DecNum% - %DecNumQ% * 16
SET DecNum=%DecNumQ%
SET HexDig=!DigTable:~%DecRmd%,1!
SET HexRes=%HexDig%%HexRes%
IF %DecNum% NEQ 0 GOTO :DecToHex_Loop
ECHO %HexRes%
ENDLOCAL
GOTO :EOF

:CLEAR_TITLE
CLS
ECHO --------------------------------------------------------
ECHO -                Mi A1 EDL Unlock Tool                 -
ECHO -                                                      -
ECHO -                   By Giovix92@XDA                    -
ECHO -     Based on CosmicDan's Mi A1 Low-Level Flasher     -
ECHO -    Based on EMMCDL scripts thanks to @emuzychenko    -
ECHO --------------------------------------------------------
ECHO.
ECHO.
GOTO :EOF

:: Credits to emil @ StackOverflow - https://stackoverflow.com/a/4518146/1767892
:: Syntax - CALL :READ_CONFIG_INI [INI_KEYNAME] [BAT_VARNAME]
:READ_CONFIG_INI
FOR /F "tokens=2 delims==" %%k IN ('find "%~1=" config.ini') DO SET %~2=%%k
GOTO :EOF