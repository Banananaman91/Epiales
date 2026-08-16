@echo off
setlocal

REM Resolve directories
set "SOURCE_DIR=%~dp0"
set "SOURCE_DIR=%SOURCE_DIR:~0,-1%"
set "VS_DIR=%SOURCE_DIR%\vs"
set "BUILDS_DIR=%SOURCE_DIR%\builds"
set "GENERATOR=Visual Studio 17 2022"

echo Source: %SOURCE_DIR%
echo VS dir: %VS_DIR%
echo Builds dir: %BUILDS_DIR%

REM Create directories if missing
if not exist "%VS_DIR%" mkdir "%VS_DIR%"
if not exist "%BUILDS_DIR%" mkdir "%BUILDS_DIR%"

REM Generate projects in vs dir so .sln and .vcxproj live in MyGame/vs
pushd "%VS_DIR%"
cmake -G "%GENERATOR%" "%SOURCE_DIR%"
popd

echo Generation complete.
endlocal
pause
