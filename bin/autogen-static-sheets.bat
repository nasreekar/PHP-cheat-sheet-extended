@ECHO OFF
@SETLOCAL

::----------------------------------------------------------------------------------
:: Build script for static PHPCheatSheets
::
:: Copyright (c) 2006-2014, Juliette Reinders Folmer <juliette@phpcheatsheets.com>.
:: All rights reserved.
::
::
:: Run this file from the command line
:: > autogen-static-sheets.bat
::
:: Use the verbose argument to get additional info on string replacements
:: > autogen-static-sheets.bat verbose=0
:: > autogen-static-sheets.bat verbose=1
:: > autogen-static-sheets.bat verbose=2
::
:: Where verbose not set       = 0 => Only show result summary (default)
:: Where verbose without value = 1 => Show information per requested PHP release
::                               2 => Also show detailed information on string replacements
::
:: Short form syntax:
:: > autogen-static-sheets.bat -v     # = level 1
:: > autogen-static-sheets.bat -vv    # = level 2
::
::----------------------------------------------------------------------------------

::----------------------------------------------------------------------------------
:: Please set following to mirror your local environment
::----------------------------------------------------------------------------------

IF "%_LOCAL_PHP_BIN_DIR%" == "" SET "_LOCAL_PHP_BIN_DIR=./php.exe"
IF "%_AUTOGEN_SCRIPT_LOCATION%" == "" SET "_AUTOGEN_SCRIPT_LOCATION=./path/to/cheatsheets-gitroot/bin/autogen-static-sheets.php"

::---------------------------------------------------------------------------------
::---------------------------------------------------------------------------------
:: Do not modify below this line!! (Unless you know what you're doing :)
::---------------------------------------------------------------------------------
::---------------------------------------------------------------------------------

:: Start the timer, initialize the counters
SET start=%time%
SET _FILE_SUCCESS=0
SET _FILE_FAILURE=0
SET _PHP_SUCCESS=0
SET _PHP_FAILURE=0


:: ECHO Received variables:
:: FOR %%A IN (%*) DO (
:: ECHO %%A
:: )

:: Check if the verbose command line option has been set
SET "_VERBOSE=0"
IF NOT [%1]==[] (
	:: Test for short forms
	IF "%1"=="-v" SET "_VERBOSE=1"
	IF "%1"=="-vv" SET "_VERBOSE=2"

	:: Test for param=value, --param=value, /param=value forms
	IF NOT [%2]==[] (
		IF %2 GEQ 0 IF %2 LEQ 2 (
			IF "%1"=="verbose" SET "_VERBOSE=%2"
			IF "%1"=="--verbose" SET "_VERBOSE=%2"
			IF "%1"=="/verbose" SET "_VERBOSE=%2"
		)
	) ELSE (
		IF "%1"=="verbose" SET "_VERBOSE=1"
	)
)



:: Check Autogen script can be found
IF NOT EXIST "%_AUTOGEN_SCRIPT_LOCATION%" GOTO :AUTOGEN_SCRIPT_LOCATION_ERROR ELSE GOTO :RUN_AUTOGEN


::---------------------------------------------------------------------------------
:: Basis for PHP versions used:
::
:: Current latest version and popular versions per minor as of Dec 23, 2014:
:: PHP minor  Latest    Popular ( ~> 5% )
:: 4.3        4.3.11    4.3.9
:: 4.4        4.4.9     4.4.9
:: 5.0        5.0.5     5.0.4
:: 5.1        5.1.6     5.1.6
:: 5.2        5.2.17    5.2.17, 5.2.6, 5.2.9
:: 5.3        5.3.29    5.3.29, 5.3.3, 5.3.28, 5.3.10, 5.3.27
:: 5.4        5.4.36    5.4.34, 5.4.35, 5.4.4, 5.4.33, 5.4.32
:: 5.5        5.5.20    5.5.9, 5.5.18, 5.5,19 5.5.17, 5.5.16, 5.5.3 // 5.5.15, 5.5.8
:: 5.6        5.6.4     5.6.2, 5.6.0, 5.6.3, 5.6.1
::
:: Ubuntu LTS versions: 5.3.2 (U 10.04), 5.3.10 ( U 12.04), 5.5.9 ( U 14.04 )
::
:: Included for historical reasons (previously generated):
:: 4.3.9, 4.4.9, 5.0.5, 5.1.6, 5.2.4, 5.2.8, 5.2.14 5.2.17, 5.3.2, 5.3.10, 5.3.27, 5.4.6, 5.4.11, 5.4.13 (live), 5.4.20
::
::
:: @internal The code for each FOR loop is the same
::---------------------------------------------------------------------------------

:: Run autogen for various PHP versions
:RUN_AUTOGEN
FOR %%G IN (5.6.4 5.6.3 5.6.2 5.6.1 5.6.0) DO CALL :RUN_AUTOGEN_PHP5 %%G
FOR %%G IN (5.5.20 5.5.19 5.5.18 5.5.17 5.5.16 5.5.9 5.5.3) DO CALL :RUN_AUTOGEN_PHP5 %%G
FOR %%G IN (5.4.36 5.4.35 5.4.34 5.4.33 5.4.32 5.4.20 5.4.13 5.4.11 5.4.6 5.4.4) DO CALL :RUN_AUTOGEN_PHP5 %%G
FOR %%G IN (5.3.29 5.3.28 5.3.27 5.3.10 5.3.3 5.3.2) DO CALL :RUN_AUTOGEN_PHP5 %%G
FOR %%G IN (5.2.17 5.2.14 5.2.9 5.2.8 5.2.6 5.2.4) DO CALL :RUN_AUTOGEN_PHP5 %%G
FOR %%G IN (5.1.6 5.0.5 5.0.4) DO CALL :RUN_AUTOGEN_PHP5 %%G
FOR %%G IN (4.4.9 4.3.11 4.3.9) DO CALL :RUN_AUTOGEN_PHP4 %%G
GOTO :CLOSE


:RUN_AUTOGEN_PHP5
SET "_CURRENT_PHP_CLI=%_LOCAL_PHP_BIN_DIR%\php%1\php.exe"
SET "_CURRENT_PHP_INI=%_LOCAL_PHP_BIN_DIR%\php%1\php.ini"
IF EXIST %_CURRENT_PHP_CLI% (
	IF %_VERBOSE% GTR 0 (
		ECHO(
		ECHO ===========================================
	)
	"%_CURRENT_PHP_CLI%" -c "%_CURRENT_PHP_INI%" -f "%_AUTOGEN_SCRIPT_LOCATION%" verbose=%_VERBOSE%
	CALL :KEEP_COUNT
) ELSE CALL :PHP_NOT_FOUND_ERROR %1 %_CURRENT_PHP_CLI%
GOTO :EOF


:RUN_AUTOGEN_PHP4
SET "_CURRENT_PHP_CLI=%_LOCAL_PHP_BIN_DIR%\php%1\cli\php.exe"
SET "_CURRENT_PHP_INI=%_LOCAL_PHP_BIN_DIR%\php%1\php.ini"
IF EXIST %_CURRENT_PHP_CLI% (
	IF %_VERBOSE% GTR 0 (
		ECHO ===========================================
	)
	"%_CURRENT_PHP_CLI%" -c "%_CURRENT_PHP_INI%" -f "%_AUTOGEN_SCRIPT_LOCATION%" verbose=%_VERBOSE%
	CALL :KEEP_COUNT
) ELSE CALL :PHP_NOT_FOUND_ERROR %1 %_CURRENT_PHP_CLI%
GOTO :EOF


:PHP_NOT_FOUND_ERROR
SET /A "_PHP_FAILURE+=1"
IF %_VERBOSE% GTR 0 (
	ECHO(
	ECHO ===========================================
	ECHO Static sheets NOT generated for PHP %1.
	ECHO PHP binary not found at :
	ECHO %2
)
GOTO :EOF


:AUTOGEN_SCRIPT_LOCATION_ERROR
ECHO ===========================================
ECHO _AUTOGEN_SCRIPT_LOCATION is not set correctly.
ECHO Please fix it by setting an environment variable or modify
ECHO the default value in autogen-static-sheets.bat
ECHO The current value is:
ECHO %_AUTOGEN_SCRIPT_LOCATION%
ECHO ===========================================
GOTO :END


:: This will work as long as there are less than 10 files to be written. If this ever would become more
:: the logic for the counters has to be revisited.
:KEEP_COUNT
IF %ERRORLEVEL% GTR 0 (
	SET /A "_FILE_SUCCESS+=(%ERRORLEVEL% / 10)"
	SET /A "_FILE_FAILURE+=(%ERRORLEVEL% %% 10)"
	SET /A "_PHP_SUCCESS+=1"
)
GOTO :EOF

:: Timer script liberally copied from http://stackoverflow.com/questions/673523/
:CLOSE
SET end=%time%
SET options="tokens=1-4 delims=:."
FOR /f %options% %%a IN ("%start%") DO SET start_h=%%a&SET /a start_m=100%%b %% 100&SET /a start_s=100%%c %% 100&SET /a start_ms=100%%d %% 100
FOR /f %options% %%a IN ("%end%") DO SET end_h=%%a&SET /a end_m=100%%b %% 100&SET /a end_s=100%%c %% 100&SET /a end_ms=100%%d %% 100

SET /a hours=%end_h%-%start_h%
SET /a mins=%end_m%-%start_m%
SET /a secs=%end_s%-%start_s%
SET /a ms=%end_ms%-%start_ms%
IF %hours% LSS 0 SET /a hours = 24%hours%
IF %mins% LSS 0 SET /a hours = %hours% - 1 & SET /a mins = 60%mins%
IF %secs% LSS 0 SET /a mins = %mins% - 1 & SET /a secs = 60%secs%
IF %ms% LSS 0 SET /a secs = %secs% - 1 & SET /a ms = 100%ms%
IF 1%ms% LSS 100 SET ms=0%ms%

:: mission accomplished
SET /a totalsecs = %hours%*3600 + %mins%*60 + %secs%

:: Show summary results and beep to indicate the script is finished
IF %_FILE_FAILURE% GTR 0 (
	SET "_FILE_FAIL_MSG=FAILED to create %_FILE_FAILURE% files."
) ELSE SET "_FILE_FAIL_MSG="

ECHO(
ECHO(
ECHO +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
ECHO SUCCESSFULLY generated %_FILE_SUCCESS% files in %_PHP_SUCCESS% PHP flavors. %_FILE_FAIL_MSG%
IF %_PHP_FAILURE% GTR 0 (
	ECHO PHP flavors ^(versions^) requested, but NOT FOUND on your system: %_PHP_FAILURE%.
)
ECHO(
ECHO Finished static file autogeneration in %hours%:%mins%:%secs%.%ms% (%totalsecs%.%ms%s total)
ECHO +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
GOTO :END

:END
ECHO 
@ECHO ON
@ENDLOCAL