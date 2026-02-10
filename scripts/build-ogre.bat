@echo off
setlocal EnableExtensions EnableDelayedExpansion

echo ==========================================================
echo [OGRE] build-ogre.bat v2026.02.07.4
echo [OGRE] cwd=%CD%
echo [OGRE] args=%*
echo [OGRE] step=0 enter
echo ==========================================================

echo [OGRE] step=0 enter

rem Resolve AliceThirdParty root (this script's parent)
for %%I in ("%~dp0..") do set "ROOT=%%~fI"
echo [OGRE] step=1 ROOT=%ROOT%

set "OGRE_SRC=%ROOT%\extern\ogre"
set "VCPKG=%ROOT%\extern\vcpkg"

rem Usage:
rem   scripts\build-ogre.bat [Release|Debug] [triplet] [manifest_dir]
set "CFG=%~1"
if "%CFG%"=="" set "CFG=Release"

set "TRIPLET=%~2"
if "%TRIPLET%"=="" set "TRIPLET=x64-windows"

set "MANIFEST_IN=%~3"
if "%MANIFEST_IN%"=="" set "MANIFEST_IN=manifests\ogre"

echo [OGRE] step=2 CFG=%CFG% TRIPLET=%TRIPLET% MANIFEST_IN=%MANIFEST_IN%

rem ---- Normalize manifest to absolute path (robust, avoid IF (...) syntax pitfalls) ----
set "MANIFEST_DIR=%MANIFEST_IN%"
set "IS_ABS=0"
if /I "%MANIFEST_DIR:~1,1%"==":" set "IS_ABS=1"
if /I "%MANIFEST_DIR:~0,2%"=="\\\\" set "IS_ABS=1"
if "%IS_ABS%"=="0" set "MANIFEST_DIR=%ROOT%\%MANIFEST_DIR%"

for %%M in ("%MANIFEST_DIR%") do set "MANIFEST_DIR=%%~fM"

rem Accept legacy folder name: manifest\ogre (singular)
if not exist "%MANIFEST_DIR%\vcpkg.json" (
  if exist "%ROOT%\manifest\ogre\vcpkg.json" (
    echo [WARN] manifests\ogre missing vcpkg.json, fallback to legacy: %ROOT%\manifest\ogre
    for %%M in ("%ROOT%\manifest\ogre") do set "MANIFEST_DIR=%%~fM"
  )
)

echo [OGRE] step=3 MANIFEST_DIR=%MANIFEST_DIR%

set "PLATFORM=msvc2022-x64-md"
set "CFG_DIR=Release"
if /I "%CFG%"=="Debug" set "CFG_DIR=Debug"

rem IMPORTANT: per-package install prefix to avoid mixing with OCCT/others
set "INSTALL_PREFIX=%ROOT%\install\%PLATFORM%\%CFG_DIR%\ogre"
set "BUILD_DIR=%ROOT%\build\ogre\win\%CFG_DIR%"

echo [OGRE] step=4 BUILD_DIR=%BUILD_DIR%
echo [OGRE] step=4 INSTALL_PREFIX=%INSTALL_PREFIX%

if not exist "%OGRE_SRC%\CMakeLists.txt" (
  echo [ERR] OGRE source not found: %OGRE_SRC%
  echo       Ensure submodule initialized: git submodule update --init --recursive
  exit /b 1
)

if not exist "%ROOT%\scripts\bootstrap-vcpkg.bat" (
  echo [ERR] bootstrap-vcpkg.bat missing: %ROOT%\scripts\bootstrap-vcpkg.bat
  exit /b 1
)

rem Bootstrap vcpkg for this manifest
echo [OGRE] step=5 bootstrap-vcpkg...
call "%ROOT%\scripts\bootstrap-vcpkg.bat" "%TRIPLET%" "%MANIFEST_DIR%"
if errorlevel 1 (
  echo [ERR] bootstrap-vcpkg.bat failed.
  exit /b 1
)

echo [OGRE] step=6 Configure...
cmake -S "%OGRE_SRC%" -B "%BUILD_DIR%" ^
  -G "Visual Studio 17 2022" -A x64 ^
  -DCMAKE_TOOLCHAIN_FILE="%VCPKG%\scripts\buildsystems\vcpkg.cmake" ^
  -DVCPKG_TARGET_TRIPLET="%TRIPLET%" ^
  -DVCPKG_MANIFEST_DIR="%MANIFEST_DIR%" ^
  -DCMAKE_INSTALL_PREFIX="%INSTALL_PREFIX%" ^
  -DBUILD_SHARED_LIBS=ON ^
  -DOGRE_BUILD_SAMPLES=OFF ^
  -DOGRE_BUILD_TESTS=OFF ^
  -DOGRE_BUILD_TOOLS=OFF ^
  -DOGRE_BUILD_COMPONENT_BITES=OFF ^
  -DOGRE_BUILD_COMPONENT_PAGING=OFF ^
  -DOGRE_BUILD_COMPONENT_PROPERTY=OFF ^
  -DOGRE_BUILD_COMPONENT_OVERLAY=OFF ^
  -DOGRE_BUILD_RENDERSYSTEM_GL3PLUS=ON ^
  -DOGRE_BUILD_RENDERSYSTEM_D3D11=OFF ^
  -DOGRE_BUILD_RENDERSYSTEM_VULKAN=OFF ^
  -DOGRE_BUILD_DEPENDENCIES=OFF ^
  -DOGRE_CONFIG_ENABLE_FREEIMAGE=OFF

if errorlevel 1 (
  echo [ERR] CMake configure failed.
  exit /b 1
)

echo [OGRE] step=7 Build + Install...
cmake --build "%BUILD_DIR%" --config "%CFG_DIR%" --target INSTALL
if errorlevel 1 (
  echo [ERR] Build/install failed.
  exit /b 1
)

echo [OK] OGRE built and installed to: %INSTALL_PREFIX%
echo [OGRE] step=8 exit
exit /b 0