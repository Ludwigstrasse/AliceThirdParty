@echo off
setlocal

for %%I in ("%~dp0..") do set "ROOT=%%~fI"
set "OCCT_SRC=%ROOT%\extern\occt"
set "VCPKG=%ROOT%\extern\vcpkg"

rem Usage: build-occt.bat [Release|Debug] [triplet] [manifest_dir]
set "CFG=%~1"
if "%CFG%"=="" set "CFG=Release"

set "TRIPLET=%~2"
if "%TRIPLET%"=="" set "TRIPLET=x64-windows"

set "MANIFEST_IN=%~3"
if "%MANIFEST_IN%"=="" set "MANIFEST_IN=manifests\occt"

set "MANIFEST_DIR=%MANIFEST_IN%"
if not "%MANIFEST_DIR:~1,1%"==":" if not "%MANIFEST_DIR:~0,2%"=="\\\" (
  set "MANIFEST_DIR=%ROOT%\%MANIFEST_DIR%"
)
for %%M in ("%MANIFEST_DIR%") do set "MANIFEST_DIR=%%~fM"

if not exist "%MANIFEST_DIR%\vcpkg.json" (
  for %%M in ("%ROOT%\manifest\occt") do set "MANIFEST_DIR=%%~fM"
)

rem if not exist "%MANIFEST_DIR%\vcpkg.json" (
rem   echo [ERR] manifest_dir not found or missing vcpkg.json:
rem   echo       %MANIFEST_IN%
rem   echo       expected: %ROOT%\manifests\occt  (or %ROOT%\manifest\occt)
rem   exit /b 1
rem )

set "PLATFORM=msvc2022-x64-md"
set "CFG_DIR=Release"
if /I "%CFG%"=="Debug" set "CFG_DIR=Debug"

set "INSTALL_PREFIX=%ROOT%\install\%PLATFORM%\%CFG_DIR%\occt"
set "BUILD_DIR=%ROOT%\build\occt\win\%CFG_DIR%"

echo [OCCT] ROOT=%ROOT%
echo [OCCT] CFG=%CFG_DIR%
echo [OCCT] TRIPLET=%TRIPLET%
echo [OCCT] MANIFEST_DIR=%MANIFEST_DIR%
echo [OCCT] SRC=%OCCT_SRC%
echo [OCCT] BUILD_DIR=%BUILD_DIR%
echo [OCCT] INSTALL_PREFIX=%INSTALL_PREFIX%

if not exist "%OCCT_SRC%\CMakeLists.txt" (
  echo [ERR] OCCT source not found: %OCCT_SRC%
  echo       Ensure submodule initialized: git submodule update --init --recursive
  exit /b 1
)

call "%ROOT%\scripts\bootstrap-vcpkg.bat" "%TRIPLET%" "%MANIFEST_DIR%" || exit /b 1

echo [OCCT] Configure...
cmake -S "%OCCT_SRC%" -B "%BUILD_DIR%" ^
  -G "Visual Studio 17 2022" -A x64 ^
  -DCMAKE_TOOLCHAIN_FILE="%VCPKG%\scripts\buildsystems\vcpkg.cmake" ^
  -DVCPKG_TARGET_TRIPLET="%TRIPLET%" ^
  -DVCPKG_MANIFEST_DIR="%MANIFEST_DIR%" ^
  -DCMAKE_INSTALL_PREFIX="%INSTALL_PREFIX%" ^
  -DBUILD_LIBRARY_TYPE=Shared ^
  -DBUILD_TESTING=OFF ^
  -DUSE_OPENGL=ON ^
  -DUSE_TBB=ON ^
  -DUSE_FREETYPE=ON

if errorlevel 1 exit /b 1

echo [OCCT] Build + Install...
cmake --build "%BUILD_DIR%" --config "%CFG_DIR%" --target INSTALL || exit /b 1
echo [OK] OCCT built and installed to: %INSTALL_PREFIX%
exit /b 0
