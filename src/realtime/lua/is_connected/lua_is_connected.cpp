#include "realtime/lua_bindings.h"
#include "realtime/redis_client.h"

using namespace GarrysMod;

namespace realtime::lua::is_connected {

LUA_FUNCTION(Lua_IsConnected) {
    auto& redis = ::realtime::GetRedisClient();
    LUA->PushBool(redis.IsConnected());
    return 1;
}

} // namespace realtime::lua::is_connected
