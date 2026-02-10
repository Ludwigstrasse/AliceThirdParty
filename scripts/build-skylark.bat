@echo off
setlocal

for %%I in ("%~dp0..") do set "ROOT=%%~fI"
set "SKY_SRC=%ROOT%\extern\skylark"
set "VCPKG=%ROOT%\extern\vcpkg"

set "CFG=%~1"
if "%CFG%"=="" set "CFG=Release"

set "TRIPLET=%~2"
if "%TRIPLET%"=="" set "TRIPLET=x64-windows"

set "PLATFORM=msvc2022-x64-md"
set "CFG_DIR=Release"
if /I "%CFG%"=="Debug" set "CFG_DIR=Debug"

set "INSTALL_PREFIX=%ROOT%\install\%PLATFORM%\%CFG_DIR%\skylark"
set "BUILD_DIR=%ROOT%\build\skylark\win\%CFG_DIR%"

if not exist "%SKY_SRC%\CMakeLists.txt" (
  echo [ERR] Skylark source not found: %SKY_SRC%
  exit /b 1
)

call "%ROOT%\scripts\bootstrap-vcpkg.bat" "%TRIPLET%" "%ROOT%\manifests\skylark" || exit /b 1

cmake -S "%SKY_SRC%" -B "%BUILD_DIR%" ^
  -G "Visual Studio 17 2022" -A x64 ^
  -DCMAKE_TOOLCHAIN_FILE="%VCPKG%\scripts\buildsystems\vcpkg.cmake" ^
  -DVCPKG_TARGET_TRIPLET="%TRIPLET%" ^
  -DVCPKG_MANIFEST_DIR="%ROOT%\manifests\skylark" ^
  -DCMAKE_INSTALL_PREFIX="%INSTALL_PREFIX%"

if errorlevel 1 exit /b 1
cmake --build "%BUILD_DIR%" --config "%CFG_DIR%" --target INSTALL || exit /b 1
echo [OK] Skylark installed: %INSTALL_PREFIX%
