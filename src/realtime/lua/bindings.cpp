#include "realtime/lua_bindings.h"
#include "realtime/redis_client.h"
#include "realtime/subscription_manager.h"

using namespace GarrysMod;

namespace realtime {

static RedisClient g_redis;
static SubscriptionManager g_subscription_manager;

// Forward declarations from each primitive namespace
namespace lua::connect {
int Lua_Connect(lua_State* state);
}
namespace lua::publish {
int Lua_Publish(lua_State* state);
}
namespace lua::subscribe {
int Lua_Subscribe(lua_State* state);
}
namespace lua::process_events {
int Lua_ProcessEvents(lua_State* state);
}
namespace lua::is_connected {
int Lua_IsConnected(lua_State* state);
}
namespace lua::disconnect {
int Lua_Disconnect(lua_State* state);
}
namespace lua::perf_stats {
int Lua_GetPerfStats(lua_State* state);
int Lua_ResetPerfStats(lua_State* state);
}

// Export function for primitives to access the Redis client
RedisClient& GetRedisClient() {
    return g_redis;
}

// Export function for primitives to access the subscription manager
SubscriptionManager& GetSubscriptionManager() {
    return g_subscription_manager;
}

void RegisterLuaBindings(GarrysMod::Lua::ILuaBase* LUA) {
    LUA->PushSpecial(GarrysMod::Lua::SPECIAL_GLOB);
    LUA->CreateTable();

    // Core primitives - infrastructure tier
    LUA->PushCFunction(lua::connect::Lua_Connect);
    LUA->SetField(-2, "Connect");

    LUA->PushCFunction(lua::publish::Lua_Publish);
    LUA->SetField(-2, "Publish");

    LUA->PushCFunction(lua::subscribe::Lua_Subscribe);
    LUA->SetField(-2, "Subscribe");

    LUA->PushCFunction(lua::process_events::Lua_ProcessEvents);
    LUA->SetField(-2, "ProcessEvents");

    LUA->PushCFunction(lua::is_connected::Lua_IsConnected);
    LUA->SetField(-2, "IsConnected");

    LUA->PushCFunction(lua::disconnect::Lua_Disconnect);
    LUA->SetField(-2, "Disconnect");

    LUA->PushCFunction(lua::perf_stats::Lua_GetPerfStats);
    LUA->SetField(-2, "GetPerfStats");

    LUA->PushCFunction(lua::perf_stats::Lua_ResetPerfStats);
    LUA->SetField(-2, "ResetPerfStats");

    LUA->SetField(-2, "realtime");
    LUA->Pop();
}

void ShutdownRealtime() noexcept {
    g_subscription_manager.Shutdown();
    g_redis.Disconnect();
}

} // namespace realtime
