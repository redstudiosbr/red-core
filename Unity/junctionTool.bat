@echo off
REM ----------------------------------------------------
REM Script: create_redcore_junction.bat
REM Description:
REM   1. Moves up two levels from this script's folder (e.g., to C:\GitHub)
REM   2. Lists all subdirectories with numeric prefixes
REM   3. Prompts the user to choose one by number
REM   4. Creates a junction named “_RedCore” inside the chosen project’s Assets folder
REM   5. Points that junction back to this Unity project’s Assets folder
REM Usage:
REM   • Place this .bat in your “red-core\Unity” folder.
REM   • Run it as Administrator (required for mklink /J).
REM ----------------------------------------------------

REM 1) Change to the grandparent directory of this script
cd /d "%~dp0..\.."

REM 2) Enable delayed expansion to build variable names in the loop
setlocal enabledelayedexpansion

REM 3) Enumerate all subdirectories, show them with numbers, and store each name
set i=0
for /D %%D in (*) do (
    set /A i+=1
    echo !i! - %%D
    set "dir!i!=%%D"
)

echo.
REM 4) Ask the user to pick a directory by number
set /P choice=Enter the number of the target directory (1-%i%): 

REM 5) Verify the selection is valid
if not defined dir%choice% (
    echo.
    echo ERROR: “%choice%” is not a valid option.
    exit /b 1
)

REM 6) Retrieve the chosen directory name
set "target=!dir%choice%!"
echo.
echo You selected: %target%

REM 7) Define source (this project’s Assets) and destination paths
set "source=%~dp0Assets"
set "destination=%cd%\%target%\Assets\_RedCore"

REM 8) Check that the destination Assets folder actually exists
if not exist "%cd%\%target%\Assets" (
    echo.
    echo ERROR: Assets folder not found in “%target%\Assets”
    exit /b 1
)

REM 9) Remove any existing junction of the same name
if exist "%destination%" (
    echo.
    echo Removing existing junction at "%destination%"...
    rmdir "%destination%"
)

REM 10) Create the junction
echo.
echo Creating junction...
mklink /J "%destination%" "%source%"

REM 11) Report success or failure
if errorlevel 1 (
    echo.
    echo ERROR: Junction creation failed.
    exit /b 1
) else (
    echo.
    echo SUCCESS: Junction created at "%destination%"
)

endlocal
pause
