#include "lua_api.h"
#include "../core/realtime_module.h"
#include <sstream>
#include <ctime>
#include <iostream>

namespace Realtime {

int Lua_Connect(lua_State* L) {
    auto LUA = GarrysMod::Lua::ILuaBase::Get(L);
    
    const char* host = LUA->CheckString(1);
    int port = static_cast<int>(LUA->CheckNumber(2));

    auto& module = RealtimeModule::Get();
    auto result = module.Connect(host, static_cast<uint16_t>(port));

    if (result.IsErr()) {
        std::cout << "[Redis] Connection failed: " << result.Error() << std::endl;
        LUA->PushBool(false);
        return 1;
    }

    std::cout << "[Redis] Connected to " << host << ":" << port << std::endl;
    LUA->PushBool(true);
    return 1;
}

int Lua_Disconnect(lua_State* L) {
    auto LUA = GarrysMod::Lua::ILuaBase::Get(L);
    RealtimeModule::Get().Shutdown();
    return 0;
}

int Lua_Publish(lua_State* L) {
    auto LUA = GarrysMod::Lua::ILuaBase::Get(L);
    
    const char* channel = LUA->CheckString(1);
    const char* message = LUA->CheckString(2);

    auto& module = RealtimeModule::Get();
    if (!module.IsConnected()) {
        std::cout << "[Redis] Not connected!" << std::endl;
        LUA->PushBool(false);
        return 1;
    }

    auto result = module.Publish(channel, message);
    if (result.IsErr()) {
        LUA->PushBool(false);
        return 1;
    }
    
    LUA->PushBool(true);
    return 1;
}

int Lua_Subscribe(lua_State* L) {
    auto LUA = GarrysMod::Lua::ILuaBase::Get(L);
    
    const char* channel = LUA->CheckString(1);

    if (!LUA->IsType(2, GarrysMod::Lua::Type::FUNCTION)) {
        LUA->ThrowError("Second argument must be a function");
        return 0;
    }

    auto& module = RealtimeModule::Get();
    if (!module.IsConnected()) {
        std::cout << "[Redis] Not connected!" << std::endl;
        LUA->PushBool(false);
        return 1;
    }

    // Create Lua callback wrapper (RAII)
    LuaCallback callback(LUA, 2);
    if (!callback.IsValid()) {
        LUA->ThrowError("Failed to create callback");
        return 0;
    }

    // Register with module
    auto result = module.Subscribe(channel, std::move(callback));
    if (result.IsErr()) {
        std::cout << "[Redis] Subscribe failed: " << result.Error() << std::endl;
        LUA->PushBool(false);
        return 1;
    }

    std::cout << "[Redis] Subscribed to: " << channel << std::endl;
    LUA->PushBool(true);
    return 1;
}

int Lua_Unsubscribe(lua_State* L) {
    auto LUA = GarrysMod::Lua::ILuaBase::Get(L);
    const char* channel = LUA->CheckString(1);
    std::cout << "[Redis] Unsubscribed from: " << channel << std::endl;
    return 0;
}

int Lua_ProcessEvents(lua_State* L) {
    auto LUA = GarrysMod::Lua::ILuaBase::Get(L);
    auto& module = RealtimeModule::Get();
    module.ProcessEvents(LUA);
    return 0;
}

int Lua_IsConnected(lua_State* L) {
    auto LUA = GarrysMod::Lua::ILuaBase::Get(L);
    auto& module = RealtimeModule::Get();
    LUA->PushBool(module.IsConnected());
    return 1;
}

int Lua_GetLastError(lua_State* L) {
    auto LUA = GarrysMod::Lua::ILuaBase::Get(L);
    auto& module = RealtimeModule::Get();
    LUA->PushString(module.GetLastError().c_str());
    return 1;
}

int Lua_PlayerKill(lua_State* L) {
    auto LUA = GarrysMod::Lua::ILuaBase::Get(L);
    
    const char* killer = LUA->CheckString(1);
    const char* victim = LUA->CheckString(2);
    const char* weapon = LUA->CheckString(3);

    auto& module = RealtimeModule::Get();
    if (!module.IsConnected()) {
        LUA->PushBool(false);
        return 1;
    }

    std::cout << "[Kill] " << killer << " killed " << victim << " with " << weapon << std::endl;
    LUA->PushBool(true);
    return 1;
}

int Lua_VehicleSpawned(lua_State* L) {
    auto LUA = GarrysMod::Lua::ILuaBase::Get(L);
    
    const char* player_name = LUA->CheckString(1);
    const char* vehicle_class = LUA->CheckString(2);
    const char* vehicle_model = LUA->CheckString(3);
    double pos_x = LUA->CheckNumber(4);
    double pos_y = LUA->CheckNumber(5);
    double pos_z = LUA->CheckNumber(6);

    auto& module = RealtimeModule::Get();
    if (!module.IsConnected()) {
        LUA->PushBool(false);
        return 1;
    }

    std::cout << "[Vehicle] " << player_name << " spawned " << vehicle_class 
              << " at (" << pos_x << ", " << pos_y << ", " << pos_z << ")" << std::endl;
    LUA->PushBool(true);
    return 1;
}

int Lua_VehicleRemoved(lua_State* L) {
    auto LUA = GarrysMod::Lua::ILuaBase::Get(L);
    
    const char* player_name = LUA->CheckString(1);
    const char* vehicle_class = LUA->CheckString(2);
    const char* reason = LUA->CheckString(3);

    auto& module = RealtimeModule::Get();
    if (!module.IsConnected()) {
        LUA->PushBool(false);
        return 1;
    }

    std::cout << "[Vehicle] " << player_name << "'s " << vehicle_class << " removed (" << reason << ")" << std::endl;
    LUA->PushBool(true);
    return 1;
}

} // namespace Realtime
