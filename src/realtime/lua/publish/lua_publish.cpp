#include "realtime/lua_bindings.h"
#include "realtime/redis_client.h"

using namespace GarrysMod;

namespace realtime::lua::publish {

LUA_FUNCTION(Lua_Publish) {
    const char* channel = LUA->CheckString(1);
    const char* message = LUA->CheckString(2);
    
    auto& redis = ::realtime::GetRedisClient();
    if (!redis.IsConnected()) {
        LUA->PushBool(false);
        return 1;
    }
    
    LUA->PushBool(redis.Publish(channel, message));
    return 1;
}

} // namespace realtime::lua::publish
