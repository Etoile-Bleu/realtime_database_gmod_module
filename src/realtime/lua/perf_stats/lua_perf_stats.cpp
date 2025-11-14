#include "realtime/lua_bindings.h"
#include "realtime/performance_stats.h"

using namespace GarrysMod;

namespace realtime::lua::perf_stats {

LUA_FUNCTION(Lua_GetPerfStats) {
    auto& perf_stats = PerformanceStats::GetInstance();
    const auto& stats = perf_stats.GetStats();

    // Create a Lua table with overall stats
    LUA->CreateTable();

    LUA->PushNumber(static_cast<double>(stats.total_events));
    LUA->SetField(-2, "total_events");

    LUA->PushNumber(static_cast<double>(stats.total_callbacks));
    LUA->SetField(-2, "total_callbacks");

    LUA->PushNumber(stats.avg_queue_wait_ms);
    LUA->SetField(-2, "avg_queue_wait_ms");

    LUA->PushNumber(stats.avg_lua_time_ms);
    LUA->SetField(-2, "avg_lua_time_ms");

    LUA->PushNumber(stats.avg_total_latency_ms);
    LUA->SetField(-2, "avg_total_latency_ms");

    LUA->PushNumber(stats.max_lua_time_ms);
    LUA->SetField(-2, "max_lua_time_ms");

    LUA->PushNumber(stats.min_lua_time_ms);
    LUA->SetField(-2, "min_lua_time_ms");

    LUA->PushNumber(stats.throughput_events_per_sec);
    LUA->SetField(-2, "throughput_events_per_sec");

    // Add channel-specific stats
    auto channel_stats = perf_stats.GetChannelStats();
    LUA->CreateTable();
    for (const auto& [channel, ch_stats] : channel_stats) {
        LUA->CreateTable();
        
        LUA->PushNumber(static_cast<double>(ch_stats.event_count));
        LUA->SetField(-2, "event_count");
        
        LUA->PushNumber(ch_stats.avg_lua_time_ms);
        LUA->SetField(-2, "avg_lua_time_ms");
        
        LUA->PushNumber(ch_stats.max_lua_time_ms);
        LUA->SetField(-2, "max_lua_time_ms");
        
        LUA->PushNumber(ch_stats.min_lua_time_ms);
        LUA->SetField(-2, "min_lua_time_ms");
        
        LUA->SetField(-2, channel.c_str());
    }
    LUA->SetField(-2, "channels");

    return 1;
}

LUA_FUNCTION(Lua_ResetPerfStats) {
    auto& perf_stats = PerformanceStats::GetInstance();
    perf_stats.Reset();
    LUA->PushBool(true);
    return 1;
}

} // namespace realtime::lua::perf_stats
