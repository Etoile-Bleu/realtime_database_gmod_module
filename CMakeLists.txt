cmake_minimum_required(VERSION 3.16)
project(gmsv_realtime)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# ✅ Force DYNAMIC runtime MSVC to match hiredis pre-built library
if(MSVC)
    set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>DLL")
endif()

# Detect architecture
if(CMAKE_SIZEOF_VOID_P EQUAL 8)
    set(ARCH "64")
    set(ARCH_SUFFIX "x64")
    set(LUA_LIB "lua_shared")
    set(HIREDIS_BUILD_DIR "build_x64_static")
elseif(CMAKE_SIZEOF_VOID_P EQUAL 4)
    set(ARCH "32")
    set(ARCH_SUFFIX "x86")
    set(LUA_LIB "lua_shared_x86")
    set(HIREDIS_BUILD_DIR "build_x86_static")
else()
    message(FATAL_ERROR "Unknown architecture")
endif()

message(STATUS "Building for ${ARCH}-bit (${ARCH_SUFFIX})")

# Include directories
include_directories(
    include
    include/lua
    include/garrysmod_common/include
    include/hiredis  # ✅ Ajouter headers hiredis
)

# Add library directories for Hiredis
link_directories(
    "include/hiredis/${HIREDIS_BUILD_DIR}/Release"
    include/lua
)

# Sources
file(GLOB SRC "src/*.cpp")

# Crée le module
add_library(gmsv_realtime SHARED ${SRC})

# Nom final du module avec arch
set_target_properties(gmsv_realtime PROPERTIES
    PREFIX ""
    OUTPUT_NAME "gmsv_realtime_win${ARCH}"
)

# ✅ Link STATIQUEMENT hiredis + ws2_32 (Windows Sockets)
if(MSVC)
    target_link_libraries(gmsv_realtime 
        hiredis          # ← Static hiredis compiled with /MD
        ${LUA_LIB}
        ws2_32           # ← Requis par hiredis sur Windows
        crypt32          # ← Cryptography API required by hiredis
    )
else()
    target_link_libraries(gmsv_realtime 
        hiredis
        ${LUA_LIB}
    )
endif()

# Suppress C4200 warnings from hiredis headers
if(MSVC)
    target_compile_options(gmsv_realtime PRIVATE /wd4200)
endif()

# Compiler flags
if(MSVC)
    target_compile_options(gmsv_realtime PRIVATE /W4 /permissive-)
else()
    target_compile_options(gmsv_realtime PRIVATE -Wall -Wextra -pedantic)
endif()