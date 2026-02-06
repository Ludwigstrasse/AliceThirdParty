# msvc2022-x64-md.cmake
set(CMAKE_CXX_STANDARD 17 CACHE STRING "" FORCE)
set(CMAKE_CXX_STANDARD_REQUIRED ON CACHE BOOL "" FORCE)

# 强制 MSVC runtime：/MD for Release, /MDd for Debug
set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>DLL" CACHE STRING "" FORCE)

# 一般不建议让第三方把 warning 当 error
add_compile_options($<$<CXX_COMPILER_ID:MSVC>:/W3>)

# 对应后续可能要的：统一 PIC（对 Windows 影响不大，但对跨平台有用）
set(CMAKE_POSITION_INDEPENDENT_CODE ON CACHE BOOL "" FORCE)
