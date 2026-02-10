@echo off
setlocal

for %%I in ("%~dp0..") do set "ROOT=%%~fI"
set "VTK_SRC=%ROOT%\extern\vtk"
set "VCPKG=%ROOT%\extern\vcpkg"

rem Usage: build-vtk.bat [Release|Debug] [triplet] [manifest_dir]
set "CFG=%~1"
if "%CFG%"=="" set "CFG=Release"

set "TRIPLET=%~2"
if "%TRIPLET%"=="" set "TRIPLET=x64-windows"

set "MANIFEST_IN=%~3"
if "%MANIFEST_IN%"=="" set "MANIFEST_IN=manifests\vtk"

set "MANIFEST_DIR=%MANIFEST_IN%"
if not "%MANIFEST_DIR:~1,1%"==":" if not "%MANIFEST_DIR:~0,2%"=="\\\" (
  set "MANIFEST_DIR=%ROOT%\%MANIFEST_DIR%"
)
for %%M in ("%MANIFEST_DIR%") do set "MANIFEST_DIR=%%~fM"

if not exist "%MANIFEST_DIR%\vcpkg.json" (
  for %%M in ("%ROOT%\manifest\vtk") do set "MANIFEST_DIR=%%~fM"
)

if not exist "%MANIFEST_DIR%\vcpkg.json" (
  echo [ERR] manifest_dir not found or missing vcpkg.json:
  echo       %MANIFEST_IN%
  echo       expected: %ROOT%\manifests\vtk  (or %ROOT%\manifest\vtk)
  exit /b 1
)

set "PLATFORM=msvc2022-x64-md"
set "CFG_DIR=Release"
if /I "%CFG%"=="Debug" set "CFG_DIR=Debug"

set "INSTALL_PREFIX=%ROOT%\install\%PLATFORM%\%CFG_DIR%\vtk"
set "BUILD_DIR=%ROOT%\build\vtk\win\%CFG_DIR%"

echo [VTK] ROOT=%ROOT%
echo [VTK] CFG=%CFG_DIR%
echo [VTK] TRIPLET=%TRIPLET%
echo [VTK] MANIFEST_DIR=%MANIFEST_DIR%
echo [VTK] SRC=%VTK_SRC%
echo [VTK] BUILD_DIR=%BUILD_DIR%
echo [VTK] INSTALL_PREFIX=%INSTALL_PREFIX%

if not exist "%VTK_SRC%\CMakeLists.txt" (
  echo [ERR] VTK source not found: %VTK_SRC%
  echo       Ensure submodule initialized: git submodule update --init --recursive
  exit /b 1
)

call "%ROOT%\scripts\bootstrap-vcpkg.bat" "%TRIPLET%" "%MANIFEST_DIR%" || exit /b 1

echo [VTK] Configure...
cmake -S "%VTK_SRC%" -B "%BUILD_DIR%" ^
  -G "Visual Studio 17 2022" -A x64 ^
  -DCMAKE_TOOLCHAIN_FILE="%VCPKG%\scripts\buildsystems\vcpkg.cmake" ^
  -DVCPKG_TARGET_TRIPLET="%TRIPLET%" ^
  -DVCPKG_MANIFEST_DIR="%MANIFEST_DIR%" ^
  -DCMAKE_INSTALL_PREFIX="%INSTALL_PREFIX%" ^
  -DBUILD_SHARED_LIBS=ON ^
  -DVTK_BUILD_TESTING=OFF ^
  -DVTK_BUILD_EXAMPLES=OFF ^
  -DVTK_WRAP_PYTHON=OFF ^
  -DVTK_ENABLE_WRAPPING=OFF ^
  -DVTK_GROUP_ENABLE_Qt=NO

if errorlevel 1 exit /b 1

echo [VTK] Build + Install...
cmake --build "%BUILD_DIR%" --config "%CFG_DIR%" --target INSTALL || exit /b 1
echo [OK] VTK built and installed to: %INSTALL_PREFIX%
exit /b 0
