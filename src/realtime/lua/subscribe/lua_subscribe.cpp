#include "realtime/lua_bindings.h"
#include "realtime/redis_client.h"
#include "realtime/subscription_manager.h"

using namespace GarrysMod;

namespace realtime::lua::subscribe {

LUA_FUNCTION(Lua_Subscribe) {
    const char* channel = LUA->CheckString(1);
    LUA->CheckType(2, Lua::Type::Function);

    if (!channel || !*channel) {
        LUA->PushBool(false);
        return 1;
    }

    auto& redis = GetRedisClient();
    auto& subscription_mgr = GetSubscriptionManager();

    if (!redis.IsConnected()) {
        LUA->PushBool(false);
        return 1;
    }

    // Subscribe to the channel
    bool success = subscription_mgr.Subscribe(channel);

    if (success) {
        // Store callback in realtime._callbacks[channel]
        LUA->PushSpecial(Lua::SPECIAL_GLOB);
        LUA->GetField(-1, "realtime");
        
        if (LUA->IsType(-1, Lua::Type::Table)) {
            LUA->GetField(-1, "_callbacks");
            
            if (!LUA->IsType(-1, Lua::Type::Table)) {
                // Create _callbacks table if it doesn't exist
                LUA->Pop(1);
                LUA->CreateTable();
                LUA->SetField(-2, "_callbacks");
                LUA->GetField(-1, "_callbacks");
            }
            
            // Store the callback: _callbacks[channel] = function
            LUA->Push(2);  // Push the callback function
            LUA->SetField(-2, channel);
            
            LUA->Pop(3);  // Pop _callbacks, realtime, global
        } else {
            LUA->Pop(2);  // Pop realtime, global
        }
    }

    LUA->PushBool(success);
    return 1;
}

} // namespace realtime::lua::subscribe
