@echo off
setlocal

rem ===== Resolve AliceThirdParty root (this script's parent) =====
for %%I in ("%~dp0..") do set "TP_ROOT=%%~fI"

rem ===== Args (keep same convention as original export-occt-sdk.bat) =====
set "CFG=%~1"
if "%CFG%"=="" set "CFG=Release"

set "SD_ROOT=%~2"
if "%SD_ROOT%"=="" (
  rem Default: AliceThirdParty is beside SolidDesigner/AliceThirdParty (as submodule)
  for %%I in ("%TP_ROOT%\..") do set "SD_ROOT=%%~fI"
)

rem Optional: override vcpkg manifest dir (defaults to TP_ROOT)
set "MANIFEST_DIR=%~3"
if "%MANIFEST_DIR%"=="" set "MANIFEST_DIR=%TP_ROOT%"

rem ===== Platform mapping =====
set "PLATFORM=msvc2022-x64-md"
set "TRIPLET=x64-windows"

rem Normalize config folder name
set "CFG_DIR=Release"
if /I "%CFG%"=="Debug" set "CFG_DIR=Debug"

rem ===== Package =====
set "PKG=osg"

rem ===== Sources (prefer per-package install prefix) =====
set "SRC_PREFIX=%TP_ROOT%\install\%PLATFORM%\%CFG_DIR%\%PKG%"
if not exist "%SRC_PREFIX%" (
  rem Legacy fallback (single shared prefix)
  set "SRC_PREFIX=%TP_ROOT%\install\%PLATFORM%\%CFG_DIR%"
  echo [WARN] per-package install prefix not found, fallback to legacy: %SRC_PREFIX%
)

set "SRC_VCPKG_BIN=%MANIFEST_DIR%\vcpkg_installed\%TRIPLET%\bin"
set "SRC_VCPKG_DBG_BIN=%MANIFEST_DIR%\vcpkg_installed\%TRIPLET%\debug\bin"

rem ===== Destinations (per package) =====
set "DST_SDK=%SD_ROOT%\Externals\3rdParty\sdk\%PLATFORM%\%CFG_DIR%\%PKG%"
set "DST_RUNTIME=%SD_ROOT%\Externals\3rdParty\runtime\%PLATFORM%\%CFG_DIR%\%PKG%"

echo [EXPORT] TP_ROOT      = %TP_ROOT%
echo [EXPORT] SD_ROOT      = %SD_ROOT%
echo [EXPORT] CFG          = %CFG_DIR%
echo [EXPORT] PKG          = %PKG%
echo [EXPORT] SRC_PREFIX   = %SRC_PREFIX%
echo [EXPORT] MANIFEST_DIR = %MANIFEST_DIR%
echo [EXPORT] DST_SDK      = %DST_SDK%
echo [EXPORT] DST_RUNTIME  = %DST_RUNTIME%

if not exist "%SRC_PREFIX%" (
  echo [ERR] Install prefix not found: %SRC_PREFIX%
  exit /b 1
)

rem ===== Ensure target dirs =====
if not exist "%DST_SDK%" mkdir "%DST_SDK%"
if not exist "%DST_RUNTIME%" mkdir "%DST_RUNTIME%"

rem ===== Copy SDK tree =====
echo [EXPORT] Copy %PKG% SDK...
robocopy "%SRC_PREFIX%" "%DST_SDK%" /E /NFL /NDL /NJH /NJS /NP >nul
if errorlevel 8 (
  echo [ERR] robocopy failed copying %PKG% SDK.
  exit /b 1
)

rem ===== Copy runtime DLLs =====
echo [EXPORT] Copy %PKG% runtime DLLs...
if exist "%SRC_PREFIX%\bin" (
  robocopy "%SRC_PREFIX%\bin" "%DST_RUNTIME%" *.dll /NFL /NDL /NJH /NJS /NP >nul
)

echo [EXPORT] Copy vcpkg runtime DLLs...
if /I "%CFG_DIR%"=="Debug" (
  if exist "%SRC_VCPKG_DBG_BIN%" (
    robocopy "%SRC_VCPKG_DBG_BIN%" "%DST_RUNTIME%" *.dll /NFL /NDL /NJH /NJS /NP >nul
  )
) else (
  if exist "%SRC_VCPKG_BIN%" (
    robocopy "%SRC_VCPKG_BIN%" "%DST_RUNTIME%" *.dll /NFL /NDL /NJH /NJS /NP >nul
  )
)

echo [OK] Export done.
echo      SDK:     %DST_SDK%
echo      Runtime: %DST_RUNTIME%
exit /b 0
