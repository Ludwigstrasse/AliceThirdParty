@echo off
setlocal enabledelayedexpansion

set ROOT=%~dp0..
set OCCT_SRC=%ROOT%\extern\occt
set VCPKG=%ROOT%\extern\vcpkg

set CFG=%1
if "%CFG%"=="" set CFG=Release

set TRIPLET=%2
if "%TRIPLET%"=="" set TRIPLET=x64-windows

if /I "%CFG%"=="Debug" (
  set INSTALL_PREFIX=%ROOT%\install\msvc2022-x64-md\Debug
) else (
  set INSTALL_PREFIX=%ROOT%\install\msvc2022-x64-md\Release
)

set BUILD_DIR=%ROOT%\build\occt\win\%CFG%

call "%ROOT%\scripts\bootstrap-vcpkg.bat" %TRIPLET%
if errorlevel 1 exit /b 1

cmake -S "%OCCT_SRC%" -B "%BUILD_DIR%" ^
  -G "Visual Studio 17 2022" -A x64 ^
  -DCMAKE_TOOLCHAIN_FILE="%VCPKG%\scripts\buildsystems\vcpkg.cmake" ^
  -DVCPKG_TARGET_TRIPLET=%TRIPLET% ^
  -DVCPKG_MANIFEST_DIR="%ROOT%" ^
  -DCMAKE_INSTALL_PREFIX="%INSTALL_PREFIX%" ^
  -DBUILD_LIBRARY_TYPE=Shared ^
  -DBUILD_TESTING=OFF ^
  -DUSE_OPENGL=ON ^
  -DUSE_TBB=ON ^
  -DUSE_FREETYPE=ON

if errorlevel 1 exit /b 1

cmake --build "%BUILD_DIR%" --config %CFG% --target INSTALL
if errorlevel 1 exit /b 1

echo [OK] OCCT built and installed to: %INSTALL_PREFIX%
exit /b 0

