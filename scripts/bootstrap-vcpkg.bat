@echo off
setlocal

rem ---- Normalize ROOT to absolute path
for %%I in ("%~dp0..") do set "ROOT=%%~fI"
set "VCPKG=%ROOT%\extern\vcpkg"

set "TRIPLET=%~1"
if "%TRIPLET%"=="" set "TRIPLET=x64-windows"

if not exist "%VCPKG%\vcpkg.exe" (
  echo [TP] vcpkg.exe not found, bootstrapping...
  if not exist "%VCPKG%\bootstrap-vcpkg.bat" (
    echo [ERR] vcpkg submodule not found: %VCPKG%
    echo       Run: git submodule update --init --recursive
    exit /b 1
  )
  pushd "%VCPKG%"
  call bootstrap-vcpkg.bat -disableMetrics
  popd
)

if not exist "%VCPKG%\vcpkg.exe" (
  echo [ERR] vcpkg bootstrap failed: %VCPKG%\vcpkg.exe not generated.
  exit /b 1
)

echo [TP] vcpkg version:
"%VCPKG%\vcpkg.exe" version

echo [TP] vcpkg install (manifest) ...
"%VCPKG%\vcpkg.exe" install --triplet "%TRIPLET%" --x-manifest-root="%ROOT%"
if errorlevel 1 exit /b 1

echo [OK] vcpkg install done. triplet=%TRIPLET%
exit /b 0
