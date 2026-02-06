# AliceThirdParty - OCCT

## Prerequisites
- Visual Studio 2022 (v143), x64
- CMake >= 3.24
- Git

## Init
```bash
git submodule update --init --recursive

```

## Build OCCT

PowerShell:

```
.\scripts\build-occt.ps1 -Config Release
.\scripts\build-occt.ps1 -Config Debug
```

## Output

- install/msvc2022-x64-md/Release
- install/msvc2022-x64-md/Debug
