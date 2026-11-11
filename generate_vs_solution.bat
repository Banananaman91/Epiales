@echo off
setlocal

set "SOURCE_DIR=%~dp0"
set "SOURCE_DIR=%SOURCE_DIR:~0,-1%"
set "BUILDS_DIR=%SOURCE_DIR%\builds"
set "DEP_DIR=%SOURCE_DIR%\_deps\"
set "CMAKEFILES_DIR=%SOURCE_DIR%\CMakeFiles\"
set "CMAKECACHE_FILE=%SOURCE_DIR%\CMakeCache.txt"
set "GENERATOR=Visual Studio 17 2022"

echo Source: %SOURCE_DIR%
echo Builds dir: %BUILDS_DIR%

if not exist "%VS_DIR%" mkdir "%VS_DIR%"
if not exist "%BUILDS_DIR%" mkdir "%BUILDS_DIR%"
if exist "%CMAKEFILES_DIR%" rmdir /q /s "%CMAKEFILES_DIR%"
if exist "%CMAKECACHE_FILE%" del "%CMAKECACHE_FILE%"

cmake -S "%SOURCE_DIR%" -B "%SOURCE_DIR%" -A x64
if errorlevel 1 (
  echo CMake generation failed.
  endlocal
  exit /b 1
)

echo Generation complete.
echo Open %VS_DIR%\MyGame.sln and build MyGame.
echo Package a Release zip from %VS_DIR%:  cpack -C Release -B "%SOURCE_DIR%\dist"
endlocal
pause
