#include "realtime/lua_bindings.h"
#include "realtime/redis_client.h"

using namespace GarrysMod;

namespace realtime::lua::connect {

LUA_FUNCTION(Lua_Connect) {
    const char* host = LUA->CheckString(1);
    int port = static_cast<int>(LUA->CheckNumber(2));
    
    auto& redis = ::realtime::GetRedisClient();
    LUA->PushBool(redis.Connect(host, port));
    return 1;
}

} // namespace realtime::lua::connect
