@echo off
setlocal

rem ===== Resolve AliceThirdParty root (this script's parent) =====
for %%I in ("%~dp0..") do set "TP_ROOT=%%~fI"

rem ===== Args =====
set "CFG=%~1"
if "%CFG%"=="" set "CFG=Release"

set "SD_ROOT=%~2"
if "%SD_ROOT%"=="" (
  rem Default: AliceThirdParty is beside SolidDesigner/AliceThirdParty (as submodule)
  for %%I in ("%TP_ROOT%\..") do set "SD_ROOT=%%~fI"
)

rem ===== Platform mapping =====
set "PLATFORM=msvc2022-x64-md"
set "TRIPLET=x64-windows"

rem Normalize config folder name
set "CFG_DIR=Release"
if /I "%CFG%"=="Debug" set "CFG_DIR=Debug"

rem ===== Sources =====
set "SRC_OCCT=%TP_ROOT%\install\%PLATFORM%\%CFG_DIR%"
set "SRC_VCPKG_BIN=%TP_ROOT%\vcpkg_installed\%TRIPLET%\bin"
set "SRC_VCPKG_DBG_BIN=%TP_ROOT%\vcpkg_installed\%TRIPLET%\debug\bin"

rem ===== Destinations =====
set "DST_SDK=%SD_ROOT%\Externals\3rdParty\sdk\%PLATFORM%\%CFG_DIR%"
set "DST_RUNTIME=%SD_ROOT%\Externals\3rdParty\runtime\%PLATFORM%\%CFG_DIR%"

echo [EXPORT] TP_ROOT     = %TP_ROOT%
echo [EXPORT] SD_ROOT     = %SD_ROOT%
echo [EXPORT] CFG         = %CFG_DIR%
echo [EXPORT] SRC_OCCT    = %SRC_OCCT%
echo [EXPORT] DST_SDK     = %DST_SDK%
echo [EXPORT] DST_RUNTIME = %DST_RUNTIME%

if not exist "%SRC_OCCT%" (
  echo [ERR] OCCT install prefix not found: %SRC_OCCT%
  echo       Build OCCT first: scripts\build-occt.bat %CFG_DIR%
  exit /b 1
)

rem ===== Ensure target dirs =====
if not exist "%DST_SDK%" mkdir "%DST_SDK%"
if not exist "%DST_RUNTIME%" mkdir "%DST_RUNTIME%"

rem ===== Copy OCCT SDK (include/lib/bin/cmake/share) =====
echo [EXPORT] Copy OCCT SDK...
robocopy "%SRC_OCCT%" "%DST_SDK%" /E /NFL /NDL /NJH /NJS /NP >nul
if errorlevel 8 (
  echo [ERR] robocopy failed copying OCCT SDK.
  exit /b 1
)

rem ===== Copy runtime DLLs =====
rem Strategy:
rem 1) Copy OCCT bin/*.dll
rem 2) Copy vcpkg runtime dlls from vcpkg_installed/.../bin (Release) or debug/bin (Debug)
echo [EXPORT] Copy OCCT runtime DLLs...
if exist "%SRC_OCCT%\bin" (
  robocopy "%SRC_OCCT%\bin" "%DST_RUNTIME%" *.dll /NFL /NDL /NJH /NJS /NP >nul
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
