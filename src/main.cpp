#include <GarrysMod/Lua/Interface.h>
#include "realtime/lua_bindings.h"
#include <iostream>

// The module registration entry point lives in this file.
// Implementation moved to `realtime` namespace in `lua_bindings`.

// GMod Module Entry Point
GMOD_MODULE_OPEN() {
    std::cout << "[Realtime] Module loading..." << std::endl;
    realtime::RegisterLuaBindings(LUA);
    
    std::cout << "[Realtime] Module loaded successfully" << std::endl;
    return 0;
}

GMOD_MODULE_CLOSE() {
    std::cout << "[Realtime] Module unloading..." << std::endl;
    realtime::ShutdownRealtime();
    return 0;
}