#pragma once

#include <GarrysMod/Lua/Interface.h>

namespace realtime {

class RedisClient;
class SubscriptionManager;

// Export function for primitives to access the Redis client
RedisClient& GetRedisClient();

// Export function for primitives to access the subscription manager
SubscriptionManager& GetSubscriptionManager();

// Register all Lua bindings for the realtime module.
void RegisterLuaBindings(GarrysMod::Lua::ILuaBase* LUA);

// Cleanly shutdown any active resources (called on module unload)
void ShutdownRealtime() noexcept;

} // namespace realtime
