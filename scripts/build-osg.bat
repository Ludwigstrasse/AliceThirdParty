@echo off
setlocal

for %%I in ("%~dp0..") do set "ROOT=%%~fI"
set "OSG_SRC=%ROOT%\extern\OpenSceneGraph"
set "VCPKG=%ROOT%\extern\vcpkg"

set "CFG=%~1"
if "%CFG%"=="" set "CFG=Release"

set "TRIPLET=%~2"
if "%TRIPLET%"=="" set "TRIPLET=x64-windows"

set "PLATFORM=msvc2022-x64-md"
set "CFG_DIR=Release"
if /I "%CFG%"=="Debug" set "CFG_DIR=Debug"

set "INSTALL_PREFIX=%ROOT%\install\%PLATFORM%\%CFG_DIR%\osg"
set "BUILD_DIR=%ROOT%\build\osg\win\%CFG_DIR%"

if not exist "%OSG_SRC%\CMakeLists.txt" (
  echo [ERR] OSG source not found: %OSG_SRC%
  exit /b 1
)

call "%ROOT%\scripts\bootstrap-vcpkg.bat" "%TRIPLET%" "%ROOT%\manifests\osg" || exit /b 1

cmake -S "%OSG_SRC%" -B "%BUILD_DIR%" ^
  -G "Visual Studio 17 2022" -A x64 ^
   -DCMAKE_POLICY_VERSION_MINIMUM=3.5 ^
  -DCMAKE_TOOLCHAIN_FILE="%VCPKG%\scripts\buildsystems\vcpkg.cmake" ^
  -DVCPKG_TARGET_TRIPLET="%TRIPLET%" ^
  -DVCPKG_MANIFEST_DIR="%ROOT%\manifests\osg" ^
  -DCMAKE_INSTALL_PREFIX="%INSTALL_PREFIX%" ^
  -DBUILD_SHARED_LIBS=ON ^
  -DOSG_BUILD_EXAMPLES=OFF ^
  -DOSG_BUILD_APPLICATIONS=OFF ^
  -DOSG_BUILD_TESTS=OFF

if errorlevel 1 exit /b 1
cmake --build "%BUILD_DIR%" --config "%CFG_DIR%" --target INSTALL || exit /b 1
echo [OK] OSG installed: %INSTALL_PREFIX%
