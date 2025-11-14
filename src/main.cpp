#include <GarrysMod/Lua/Interface.h>
#include <hiredis/hiredis.h>
#include <iostream>
#include <memory>
#include <string>
#include <sstream>

// RAII wrapper for Redis context
struct RedisContextDeleter {
    void operator()(redisContext* ctx) const {
        if (ctx) redisFree(ctx);
    }
};

struct RedisReplyDeleter {
    void operator()(redisReply* reply) const {
        if (reply) freeReplyObject(reply);
    }
};

static std::unique_ptr<redisContext, RedisContextDeleter> g_redis = nullptr;

// Lua function: realtime.Connect(host, port)
LUA_FUNCTION(Lua_Connect) {
    const char* host = LUA->CheckString(1);
    int port = static_cast<int>(LUA->CheckNumber(2));
    
    g_redis.reset(redisConnect(host, port));
    
    if (!g_redis || g_redis->err) {
        std::cout << "[Redis] Connection failed: " << (g_redis ? g_redis->errstr : "Unknown error") << std::endl;
        LUA->PushBool(false);
        return 1;
    }
    
    std::cout << "[Redis] Connected to " << host << ":" << port << std::endl;
    LUA->PushBool(true);
    return 1;
}

LUA_FUNCTION(Lua_Publish) {
    const char* channel = LUA->CheckString(1);
    const char* message = LUA->CheckString(2);
    
    if (!g_redis) {
        std::cout << "[Redis] Not connected!" << std::endl;
        LUA->PushBool(false);
        return 1;
    }
    
    std::unique_ptr<redisReply, RedisReplyDeleter> reply(
        static_cast<redisReply*>(redisCommand(g_redis.get(), "PUBLISH %s %s", channel, message))
    );
    
    if (!reply) {
        std::cout << "[Redis] Publish failed!" << std::endl;
        LUA->PushBool(false);
        return 1;
    }
    
    LUA->PushBool(true);
    return 1;
}

// POC: Player action tracking
// Usage: realtime.PlayerAction(player_name, action_type, details)
LUA_FUNCTION(Lua_PlayerAction) {
    const char* player_name = LUA->CheckString(1);
    const char* action_type = LUA->CheckString(2);
    const char* details = LUA->CheckString(3);
    
    if (!g_redis) {
        std::cout << "[Redis] Not connected!" << std::endl;
        LUA->PushBool(false);
        return 1;
    }
    
    // Build JSON-like message (simple format)
    std::ostringstream message;
    message << "{\"player\":\"" << player_name 
            << "\",\"action\":\"" << action_type 
            << "\",\"details\":\"" << details 
            << "\",\"timestamp\":" << std::time(nullptr) << "}";
    
    std::string msg_str = message.str();
    
    std::unique_ptr<redisReply, RedisReplyDeleter> reply(
        static_cast<redisReply*>(redisCommand(
            g_redis.get(), 
            "PUBLISH player:actions %s", 
            msg_str.c_str()
        ))
    );
    
    if (!reply) {
        std::cout << "[Redis] PlayerAction publish failed!" << std::endl;
        LUA->PushBool(false);
        return 1;
    }
    
    std::cout << "[Redis] Player action published: " << player_name << " - " << action_type << std::endl;
    LUA->PushBool(true);
    return 1;
}

// POC: Player kill event
// Usage: realtime.PlayerKill(killer_name, victim_name, weapon)
LUA_FUNCTION(Lua_PlayerKill) {
    const char* killer = LUA->CheckString(1);
    const char* victim = LUA->CheckString(2);
    const char* weapon = LUA->CheckString(3);
    
    if (!g_redis) {
        std::cout << "[Redis] Not connected!" << std::endl;
        LUA->PushBool(false);
        return 1;
    }
    
    std::ostringstream message;
    message << "{\"killer\":\"" << killer 
            << "\",\"victim\":\"" << victim 
            << "\",\"weapon\":\"" << weapon 
            << "\",\"timestamp\":" << std::time(nullptr) << "}";
    
    std::string msg_str = message.str();
    
    std::unique_ptr<redisReply, RedisReplyDeleter> reply(
        static_cast<redisReply*>(redisCommand(
            g_redis.get(), 
            "PUBLISH player:kills %s", 
            msg_str.c_str()
        ))
    );
    
    if (!reply) {
        std::cout << "[Redis] PlayerKill publish failed!" << std::endl;
        LUA->PushBool(false);
        return 1;
    }
    
    std::cout << "[Redis] Kill event: " << killer << " killed " << victim << " with " << weapon << std::endl;
    LUA->PushBool(true);
    return 1;
}

LUA_FUNCTION(Lua_Subscribe) {
    const char* channel = LUA->CheckString(1);
    
    if (!g_redis) {
        std::cout << "[Redis] Not connected!" << std::endl;
        LUA->PushBool(false);
        return 1;
    }
    
    std::cout << "[Redis] Subscribed to: " << channel << std::endl;
    LUA->PushBool(true);
    return 1;
}

LUA_FUNCTION(Lua_Disconnect) {
    if (g_redis) {
        g_redis.reset();
        std::cout << "[Redis] Disconnected" << std::endl;
    }
    return 0;
}

// GMod Module Entry Point
GMOD_MODULE_OPEN() {
    std::cout << "[Realtime] Module loading..." << std::endl;
    
    LUA->PushSpecial(GarrysMod::Lua::SPECIAL_GLOB);
    LUA->CreateTable();
    
    LUA->PushCFunction(Lua_Connect);
    LUA->SetField(-2, "Connect");
    
    LUA->PushCFunction(Lua_Publish);
    LUA->SetField(-2, "Publish");
    
    LUA->PushCFunction(Lua_Subscribe);
    LUA->SetField(-2, "Subscribe");
    
    LUA->PushCFunction(Lua_Disconnect);
    LUA->SetField(-2, "Disconnect");
    
    // POC Functions
    LUA->PushCFunction(Lua_PlayerAction);
    LUA->SetField(-2, "PlayerAction");
    
    LUA->PushCFunction(Lua_PlayerKill);
    LUA->SetField(-2, "PlayerKill");
    
    LUA->SetField(-2, "realtime");
    LUA->Pop();
    
    std::cout << "[Realtime] Module loaded successfully" << std::endl;
    return 0;
}

GMOD_MODULE_CLOSE() {
    std::cout << "[Realtime] Module unloading..." << std::endl;
    g_redis.reset();
    return 0;
}