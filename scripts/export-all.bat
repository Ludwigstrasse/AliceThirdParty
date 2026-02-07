@echo off
setlocal

set "CFG=%~1"
if "%CFG%"=="" set "CFG=Release"

set "SD_ROOT=%~2"
set "MANIFEST_DIR=%~3"

call "%~dp0export-occt-sdk.bat" "%CFG%" "%SD_ROOT%" "%MANIFEST_DIR%" || exit /b 1
call "%~dp0export-ogre-sdk.bat" "%CFG%" "%SD_ROOT%" "%MANIFEST_DIR%" || exit /b 1
call "%~dp0export-osg-sdk.bat"  "%CFG%" "%SD_ROOT%" "%MANIFEST_DIR%" || exit /b 1
call "%~dp0export-vtk-sdk.bat"  "%CFG%" "%SD_ROOT%" "%MANIFEST_DIR%" || exit /b 1
call "%~dp0export-skylark-sdk.bat" "%CFG%" "%SD_ROOT%" "%MANIFEST_DIR%" || exit /b 1

echo [OK] Export all done.
exit /b 0
