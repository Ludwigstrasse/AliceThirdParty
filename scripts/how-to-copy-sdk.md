现在 AliceThirdParty 已经产出了两套关键目录：
AliceThirdParty/install/...：OCCT SDK（include/lib/bin/cmake 等）
AliceThirdParty/vcpkg_installed/...：运行时依赖 DLL/headers/libs（tbb/freetype 等）
需要拷到 SolidDesigner/Externals/3rdParty，建议统一落地到：
SolidDesigner/Externals/3rdParty/sdk/<platform>/<config>/（供 CMake CMAKE_PREFIX_PATH 消费）
SolidDesigner/Externals/3rdParty/runtime/<platform>/<config>/（运行时 DLL 汇总，给 exe 用）

下面两份脚本：Windows .bat 和 Linux/macOS .sh，可直接放在 AliceThirdParty/scripts/。

1) Windows：scripts\export-occt-sdk.bat
用法：
在 AliceThirdParty 根目录执行：
scripts\export-occt-sdk.bat Release
scripts\export-occt-sdk.bat Debug
也可以传第二个参数指定 SolidDesigner 根目录：
scripts\export-occt-sdk.bat Release D:\WorkSpaceForSolidDesigner\SolidDesigner

2) Linux：scripts/export-occt-sdk.sh
用法：
./scripts/export-occt-sdk.sh Release
./scripts/export-occt-sdk.sh Debug
或指定 SolidDesigner 根目录：
./scripts/export-occt-sdk.sh Release /path/to/SolidDesigner