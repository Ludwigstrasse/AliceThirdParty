@echo off
setlocal

rem Usage: bootstrap-vcpkg.bat <triplet> <manifest_dir>
set "TRIPLET=%~1"
if "%TRIPLET%"=="" set "TRIPLET=x64-windows"
set "MANIFEST=%~2"
if "%MANIFEST%"=="" (
  echo [ERR] manifest_dir is required. e.g. manifest\occt
  exit /b 1
)

for %%I in ("%~dp0..") do set "ROOT=%%~fI"
set "VCPKG=%ROOT%\extern\vcpkg\vcpkg.exe"

if not exist "%VCPKG%" (
  echo [ERR] vcpkg.exe not found: %VCPKG%
  exit /b 1
)

echo [VCPKG] triplet=%TRIPLET%
echo [VCPKG] manifest=%MANIFEST%

"%VCPKG%" install --triplet "%TRIPLET%" --x-manifest-root="%MANIFEST%"
if errorlevel 1 exit /b 1

exit /b 0
