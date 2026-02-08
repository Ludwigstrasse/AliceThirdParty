# AliceThirdParty — Build & Export Third‑Party SDKs (OCCT / OGRE / OSG / VTK / Skylark)

This repository builds **all third‑party SDKs** required by SolidDesigner/Alice and exports them into a
standardized SDK + runtime layout that can be consumed by the main solution.

It is designed around two principles:

1. **Per‑package install prefix**  
   Each package installs into its own folder (e.g. `install/<platform>/<config>/occt/`), matching the layout you expect
   (cmake/include/lib/bin/data/win64… depending on the package).

2. **Per‑package vcpkg manifest**  
   Each package has its own vcpkg manifest folder (e.g. `manifests/osg/vcpkg.json`) and its own
   `vcpkg_installed/` under that manifest. This makes dependency ownership explicit and keeps build scripts reproducible.

---

## Prerequisites

### Windows
- Visual Studio 2022 (v143), x64
- CMake **>= 3.24** (newer CMake is fine; see *Troubleshooting* for legacy projects)
- Git

### Linux
- A recent GCC/Clang toolchain
- CMake **>= 3.24**
- Git

---

## Repository layout

```
AliceThirdParty/
  extern/                       # third-party sources (git submodules)
    occt/
    ogre/
    osg/                        # OpenSceneGraph
    vtk/
    skylark/
    vcpkg/                      # vcpkg toolchain (submodule)
  manifests/                    # per-package vcpkg manifests
    occt/vcpkg.json
    ogre/vcpkg.json
    osg/vcpkg.json
    vtk/vcpkg.json
    skylark/vcpkg.json
  build/                        # out-of-source build trees
  install/                      # per-package install prefixes (SDK-like layout)
  scripts/                      # build/export helpers (Windows + Linux)
```

---

## Init (submodules)

```bash
git submodule update --init --recursive
```

You must initialize submodules before building; `extern/<pkg>` and `extern/vcpkg` are required.

---

## Build (how compilation works)

All build scripts follow the same pipeline:

1. **Install vcpkg dependencies** using the selected manifest
2. **Configure** the package using CMake + vcpkg toolchain
3. **Build**
4. **Install** into `install/<platform>/<config>/<pkg>/`

### Key concepts

- **Config**: `Release` or `Debug`
- **Triplet** (Windows): typically `x64-windows`  
  (Linux examples below use a typical `x64-linux` naming convention; adapt to your environment)
- **Manifest directory**: folder containing `vcpkg.json`, e.g. `manifests/osg`

### Windows commands (BAT)

> Most scripts default to **Release** if you do not pass a config.
> If you expect output under `Debug/`, you must explicitly pass `Debug`.

Build one package:

```bat
cd /d D:\WorkSpaceForSolidDesigner\AliceThirdParty

scripts\build-occt.bat   Debug x64-windows manifests\occt
scripts\build-ogre.bat   Debug x64-windows manifests\ogre
scripts\build-osg.bat    Debug x64-windows manifests\osg
scripts\build-vtk.bat    Debug x64-windows manifests\vtk
scripts\build-skylark.bat Debug x64-windows manifests\skylark
```

Build Release:

```bat
scripts\build-osg.bat Release x64-windows manifests\osg
```

### Linux commands (SH)

```bash
cd /path/to/AliceThirdParty

./scripts/build-occt.sh   Debug x64-linux manifests/occt
./scripts/build-ogre.sh   Debug x64-linux manifests/ogre
./scripts/build-osg.sh    Debug x64-linux manifests/osg
./scripts/build-vtk.sh    Debug x64-linux manifests/vtk
./scripts/build-skylark.sh Debug x64-linux manifests/skylark
```

---

## Install output layout (what gets produced)

After a successful build+install, each package is installed independently:

```
install/<platform>/<config>/<pkg>/
  include/   (if provided by the package)
  lib/       (import libs / static libs)
  bin/       (DLLs / executables)   # some packages
  cmake/     (CMake package config files)  # some packages
  data/      (package data)         # OCCT
  win64/     (OCCT Windows layout: vc*/bin or vc*/bind)
  ...
```

Examples on Windows:

- `install/msvc2022-x64-md/Debug/occt/`
- `install/msvc2022-x64-md/Release/osg/`

---

## Export / Copy (how “SDK + runtime” is staged for SolidDesigner)

SolidDesigner typically needs:

- **SDK** (development time): headers, import libs, CMake config files, etc.
- **Runtime** (execution time): DLLs/SOs and plugins/resources that must be present when you run Alice.

The export scripts copy both into **SolidDesigner** under a predictable structure:

```
<SolidDesignerRoot>/Externals/3rdParty/
  sdk/<platform>/<config>/<pkg>/        # full SDK tree (copied from install/<...>/<pkg>)
  runtime/<platform>/<config>/<pkg>/    # runtime DLLs (pkg + vcpkg runtime deps)
```

### What the export scripts copy

For each package:

1. **SDK copy**  
   Copies the whole `install/<platform>/<config>/<pkg>/` folder to:
   `Externals/3rdParty/sdk/<platform>/<config>/<pkg>/`

2. **Runtime copy**
   - Copies the package runtime DLLs from the package install tree:
     - OCCT: prefers `win64/vc*/bin` (Release) or `win64/vc*/bind` (Debug) if `bin/` is not present
     - OSG/OGRE/VTK/Skylark: usually `bin/` under the install prefix
   - Copies vcpkg runtime DLLs from:
     - Release: `manifests/<pkg>/vcpkg_installed/<triplet>/bin`
     - Debug:   `manifests/<pkg>/vcpkg_installed/<triplet>/debug/bin`

### Windows export (recommended)

Export a single package:

```bat
cd /d D:\WorkSpaceForSolidDesigner\AliceThirdParty

scripts\export-osg-sdk.bat Debug "D:\WorkSpaceForSolidDesigner\SolidDesigner" manifests\osg
```

Export all packages:

```bat
scripts\export-all.bat Debug "D:\WorkSpaceForSolidDesigner\SolidDesigner" D:\WorkSpaceForSolidDesigner\AliceThirdParty\manifests
```

### Linux export

```bash
./scripts/export-all.sh Debug /path/to/SolidDesigner /path/to/AliceThirdParty/manifests
```

---

## How SolidDesigner/Alice should consume these outputs

### Build time (compile + link)

Use the **SDK path** (not runtime) for headers and import libs.

Typical strategies:

- Add to `CMAKE_PREFIX_PATH`:
  - `.../Externals/3rdParty/sdk/<platform>/<config>/occt`
  - `.../Externals/3rdParty/sdk/<platform>/<config>/osg`
  - etc.

- Or point your superproject at `install/<platform>/<config>/<pkg>` directly during development.

### Run time (DLL loading)

At runtime you need the **runtime** folders (DLLs + plugin DLLs):

- `.../Externals/3rdParty/runtime/<platform>/<config>/<pkg>/`

On Windows, the simplest method is to add these folders to `PATH` during development,
or to use a dedicated loader strategy in Alice (recommended):

- `SetDefaultDllDirectories(...)`
- `AddDllDirectory(runtime\...\<pkg>)`
- `LoadLibraryEx(...)` per backend

This avoids global PATH pollution and makes backend switching deterministic.

---

## Troubleshooting

### “Why did it install to Release instead of Debug?”
Most `build-*.bat` scripts default to **Release** if you do not pass the config.
Always call:

```bat
scripts\build-xxx.bat Debug ...
```

### vcpkg port name errors (example: jpeg-turbo)
vcpkg ports must match official names. For example, use `libjpeg-turbo` (not `jpeg-turbo`) in `vcpkg.json`.

### Legacy CMake compatibility errors
Some projects have an old `cmake_minimum_required(...)`. If CMake refuses to configure:

- Update the project’s `cmake_minimum_required(VERSION ...)` to a modern minimum (recommended), or
- Configure with `-DCMAKE_POLICY_VERSION_MINIMUM=<min>` for compatibility.

### OpenSceneGraph (OSG) `_FPOSOFF` build error on MSVC
If you see `error C3861: '_FPOSOFF': identifier not found` in `osgPlugins/osga/OSGA_Archive.cpp`,
apply the known fix (as used by vcpkg) or disable the `osga` plugin.

---

## Output summary

Local install prefixes (built by this repo):

- `install/msvc2022-x64-md/Release/<pkg>`
- `install/msvc2022-x64-md/Debug/<pkg>`

Exported for SolidDesigner:

- `<SolidDesignerRoot>/Externals/3rdParty/sdk/<platform>/<config>/<pkg>`
- `<SolidDesignerRoot>/Externals/3rdParty/runtime/<platform>/<config>/<pkg>`
