#include "realtime/lua_bindings.h"
#include "realtime/redis_client.h"

using namespace GarrysMod;

namespace realtime::lua::disconnect {

LUA_FUNCTION(Lua_Disconnect) {
    auto& redis = ::realtime::GetRedisClient();
    redis.Disconnect();
    return 0;
}

} // namespace realtime::lua::disconnect
