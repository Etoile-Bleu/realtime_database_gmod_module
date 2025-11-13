#include <lua.hpp>
#include <hiredis/hiredis.h>
#include <iostream>
#include <memory>
#include <string>
#include <cstring>

// Global Redis context (simplified for POC)
static redisContext* g_redis = nullptr;

// Forward declaration
static int CreateModuleTable(lua_State* L);

// Lua function: realtime.Connect(host, port)
static int Lua_Connect(lua_State* L) {
    const char* host = luaL_checkstring(L, 1);
    lua_Integer port_lua = luaL_checkinteger(L, 2);
    int port = static_cast<int>(port_lua);
    
    // Close existing connection
    if (g_redis != nullptr) {
        redisFree(g_redis);
        g_redis = nullptr;
    }
    
    // Connect to Redis
    g_redis = redisConnect(host, port);
    
    if (g_redis == nullptr || g_redis->err) {
        std::cout << "[Redis] Connection failed!" << std::endl;
        lua_pushboolean(L, false);
        return 1;
    }
    
    std::cout << "[Redis] Connected to " << host << ":" << port << std::endl;
    lua_pushboolean(L, true);
    return 1;
}

// Lua function: realtime.Publish(channel, message)
static int Lua_Publish(lua_State* L) {
    const char* channel = luaL_checkstring(L, 1);
    const char* message = luaL_checkstring(L, 2);
    
    if (g_redis == nullptr) {
        std::cout << "[Redis] Not connected!" << std::endl;
        lua_pushboolean(L, false);
        return 1;
    }
    
    redisReply* reply = static_cast<redisReply*>(
        redisCommand(g_redis, "PUBLISH %s %s", channel, message)
    );
    
    if (reply == nullptr) {
        std::cout << "[Redis] Publish command failed!" << std::endl;
        lua_pushboolean(L, false);
        return 1;
    }
    
    freeReplyObject(reply);
    lua_pushboolean(L, true);
    return 1;
}

// Lua function: realtime.Subscribe(channel, callback)
static int Lua_Subscribe(lua_State* L) {
    const char* channel = luaL_checkstring(L, 1);
    
    if (g_redis == nullptr) {
        std::cout << "[Redis] Not connected!" << std::endl;
        lua_pushboolean(L, false);
        return 1;
    }
    
    // For now, just acknowledge subscription (full implementation would need threading)
    std::cout << "[Redis] Subscribed to channel: " << channel << std::endl;
    lua_pushboolean(L, true);
    return 1;
}

// Lua function: realtime.Disconnect()
static int Lua_Disconnect(lua_State* L) {
    (void)L;  // Suppress unused parameter warning
    if (g_redis != nullptr) {
        redisFree(g_redis);
        g_redis = nullptr;
        std::cout << "[Redis] Disconnected" << std::endl;
    }
    return 0;
}

// Module entry point for standard Lua loading (for require())
// GMod looks for luaopen_<modulename> where modulename is the part after gmsv_/gmcl_
// For gmsv_realtime_win32.dll, GMod calls luaopen_realtime (removes prefix and arch)
static int CreateModuleTable(lua_State* L) {
    // Create the module table
    lua_newtable(L);
    
    // Register functions
    lua_pushcfunction(L, Lua_Connect);
    lua_setfield(L, -2, "Connect");
    
    lua_pushcfunction(L, Lua_Publish);
    lua_setfield(L, -2, "Publish");
    
    lua_pushcfunction(L, Lua_Subscribe);
    lua_setfield(L, -2, "Subscribe");
    
    lua_pushcfunction(L, Lua_Disconnect);
    lua_setfield(L, -2, "Disconnect");
    
    // Return the module table
    return 1;
}

extern "C" int luaopen_realtime(lua_State* L) {
    std::cout << "[Module] Loading realtime module" << std::endl;
    return CreateModuleTable(L);
}
