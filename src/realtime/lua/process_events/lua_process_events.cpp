#include "realtime/lua_bindings.h"
#include "realtime/subscription_manager.h"
#include "realtime/performance_stats.h"
#include <iostream>
#include <chrono>

using namespace GarrysMod;

namespace realtime::lua::process_events {

LUA_FUNCTION(Lua_ProcessEvents) {
    auto& subscription_mgr = GetSubscriptionManager();
    auto& perf_stats = PerformanceStats::GetInstance();

    // Process all pending events and invoke Lua callbacks
    int processed = 0;
    auto process_start = PerformanceStats::Clock::now();

    while (auto event = subscription_mgr.ProcessEvent()) {
        auto callback_start = PerformanceStats::Clock::now();

        // Calculate queue wait time (how long event was in queue)
        auto queue_duration = std::chrono::duration_cast<std::chrono::duration<double, std::milli>>(
            callback_start - event->timestamp
        );

        // Look up callback in Lua table: realtime._callbacks[channel]
        LUA->PushSpecial(Lua::SPECIAL_GLOB);
        LUA->GetField(-1, "realtime");
        
        if (!LUA->IsType(-1, Lua::Type::Table)) {
            LUA->Pop(2);
            processed++;
            continue;
        }

        LUA->GetField(-1, "_callbacks");
        if (!LUA->IsType(-1, Lua::Type::Table)) {
            LUA->Pop(3);
            processed++;
            continue;
        }

        // Get callback for this channel
        LUA->GetField(-1, event->channel.c_str());
        if (!LUA->IsType(-1, Lua::Type::Function)) {
            LUA->Pop(4);
            processed++;
            continue;
        }

        // Call callback(channel, message)
        LUA->PushString(event->channel.c_str());
        LUA->PushString(event->message.c_str());

        if (LUA->PCall(2, 0, 0) != 0) {
            // Error in callback
            const char* error = LUA->GetString(-1);
            std::cerr << "[realtime] Lua callback error: " << (error ? error : "unknown") << std::endl;
            LUA->Pop(1);
        }

        auto callback_end = PerformanceStats::Clock::now();
        auto lua_duration = std::chrono::duration_cast<std::chrono::duration<double, std::milli>>(
            callback_end - callback_start
        );

        LUA->Pop(3);  // Pop _callbacks, realtime, global table
        
        // Record performance metrics
        auto total_latency = std::chrono::duration_cast<std::chrono::duration<double, std::milli>>(
            callback_end - event->timestamp
        );
        perf_stats.RecordEventProcessed(
            event->channel,
            queue_duration.count(),
            lua_duration.count(),
            total_latency.count()
        );
        
        processed++;
    }

    LUA->PushNumber(processed);
    return 1;
}

} // namespace realtime::lua::process_events
