@echo off
setlocal enabledelayedexpansion

rem --- Determine the name of the “red-core” folder (parent of “Junction Tool”)
for %%X in ("%~dp0..\") do set "coreProj=%%~nX"

rem --- Change directory to the root (e.g., C:\GitHub)
cd /d "%~dp0..\.."
set "root=%CD%"

rem --- List all folders in the root except “red-core”
set i=0
for /D %%D in (*) do (
    if /I not "%%D"=="!coreProj!" (
        set /A i+=1
        echo !i! - %%D
        set "proj!i!=%%D"
    )
)

echo.
set /P sel="Enter the number of the target project (1-%i%): "

if not defined proj%sel% (
    echo.
    echo ERROR: "%sel%" is not a valid option.
    pause
    exit /b 1
)
set "target=!proj%sel%!"

rem --- Define source (Core inside red-core) and destination (Assets\Core in the chosen project)
set "source=%root%\%coreProj%\Core"
set "dest=%root%\%target%\Assets\Core"

echo.
echo Source:      "%source%"
echo Destination: "%dest%"

rem --- If the junction already exists, remove it first
if exist "%dest%" (
    echo.
    echo Removing existing junction...
    rmdir "%dest%"
)

echo.
echo Creating junction...
mklink /J "%dest%" "%source%"

if errorlevel 1 (
    echo.
    echo ERROR: Junction creation failed.
) else (
    echo.
    echo SUCCESS: Junction created at "%dest%".
)

pause
