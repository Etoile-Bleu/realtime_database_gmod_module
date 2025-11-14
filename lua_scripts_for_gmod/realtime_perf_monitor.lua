-- ============================================================================
-- REALTIME PERFORMANCE MONITOR
-- ============================================================================
-- Commandes pour monitorer les performances du module realtime
-- Place in: garrysmod/lua/autorun/server/realtime_perf_monitor.lua
--
-- Commands:
--   realtime_perf_start   : Démarre le monitoring (affiche toutes les 5 sec)
--   realtime_perf_stop    : Arrête le monitoring
--   realtime_perf_stats   : Affiche les stats une seule fois
--   realtime_perf_reset   : Réinitialise les stats
-- ============================================================================

if not SERVER then return end

-- ============================================================================
-- MONITORING STATE
-- ============================================================================

local PERF_MONITOR = {
    enabled = false,
    last_check = 0,
    check_interval = 5,  -- Check toutes les 5 secondes
    start_time = 0,
    events_at_start = 0,
}

-- ============================================================================
-- HELPER FUNCTIONS
-- ============================================================================

local function PrintPerfStats()
    if not realtime or not realtime.GetPerfStats then
        print("[PERF] Error: realtime module not loaded!")
        return
    end

    local stats = realtime.GetPerfStats()

    print("\n" .. string.rep("=", 100))
    print("  REALTIME PERFORMANCE STATISTICS")
    print(string.rep("=", 100))
    print(string.format("  Total Events Processed:        %d", stats.total_events))
    print(string.format("  Total Callbacks Triggered:     %d", stats.total_callbacks))
    print("")
    print(string.format("  Queue Wait Time (Redis latency):")
        .. string.format("      %.3f ms (avg)", stats.avg_queue_wait_ms))
    print(string.format("  Lua Callback Execution Time:   %.3f ms (avg) | %.3f ms (max) | %.3f ms (min)", 
        stats.avg_lua_time_ms, stats.max_lua_time_ms, stats.min_lua_time_ms))
    print(string.format("  Total Latency (Redis→Callback): %.3f ms", stats.avg_total_latency_ms))
    print("")
    print(string.format("  Throughput:                    %.0f events/sec", stats.throughput_events_per_sec))
    
    -- Channel-specific stats
    if stats.channels and next(stats.channels) then
        print("")
        print("  CHANNEL BREAKDOWN:")
        print("  " .. string.rep("-", 96))
        
        for channel, ch_stats in pairs(stats.channels) do
            print(string.format("    %-25s | Events: %6d | Avg: %.3f ms | Max: %.3f ms | Min: %.3f ms",
                channel,
                ch_stats.event_count,
                ch_stats.avg_lua_time_ms,
                ch_stats.max_lua_time_ms,
                ch_stats.min_lua_time_ms
            ))
        end
        print("  " .. string.rep("-", 96))
    end
    
    print(string.rep("=", 100) .. "\n")
end

local function FormatPerfLine()
    if not realtime or not realtime.GetPerfStats then
        return "[PERF] Error: realtime module not loaded!"
    end

    local stats = realtime.GetPerfStats()
    local uptime = CurTime() - PERF_MONITOR.start_time
    local events_since_start = stats.total_events - PERF_MONITOR.events_at_start

    return string.format(
        "[PERF] Uptime: %ds | Events: %d (+%d) | Queue: %.2fms | Lua: %.2fms | Total: %.2fms | Throughput: %.0f/sec",
        math.floor(uptime),
        stats.total_events,
        events_since_start,
        stats.avg_queue_wait_ms,
        stats.avg_lua_time_ms,
        stats.avg_total_latency_ms,
        stats.throughput_events_per_sec
    )
end

-- ============================================================================
-- THINK HOOK FOR CONTINUOUS MONITORING
-- ============================================================================

hook.Add("Think", "RealtimePerfMonitor", function()
    if not PERF_MONITOR.enabled then return end

    local now = CurTime()
    if now - PERF_MONITOR.last_check >= PERF_MONITOR.check_interval then
        print(FormatPerfLine())
        PERF_MONITOR.last_check = now
    end
end)

-- ============================================================================
-- CONSOLE COMMANDS
-- ============================================================================

concommand.Add("realtime_perf_start", function(ply, cmd, args)
    if PERF_MONITOR.enabled then
        print("[PERF] Monitoring already running!")
        return
    end

    PERF_MONITOR.enabled = true
    PERF_MONITOR.last_check = CurTime()
    PERF_MONITOR.start_time = CurTime()

    if realtime and realtime.GetPerfStats then
        local stats = realtime.GetPerfStats()
        PERF_MONITOR.events_at_start = stats.total_events
    end

    print("[PERF] ✓ Performance monitoring STARTED")
    print("[PERF] Stats will be printed every " .. PERF_MONITOR.check_interval .. " seconds")
    print("[PERF] Use 'realtime_perf_stop' to stop monitoring")
end, nil, "Start realtime performance monitoring")

concommand.Add("realtime_perf_stop", function(ply, cmd, args)
    if not PERF_MONITOR.enabled then
        print("[PERF] Monitoring not running!")
        return
    end

    PERF_MONITOR.enabled = false
    print("[PERF] ✗ Performance monitoring STOPPED")
    print("[PERF] Use 'realtime_perf_start' to resume")
end, nil, "Stop realtime performance monitoring")

concommand.Add("realtime_perf_stats", function(ply, cmd, args)
    PrintPerfStats()
end, nil, "Display realtime performance statistics")

concommand.Add("realtime_perf_reset", function(ply, cmd, args)
    if not realtime or not realtime.ResetPerfStats then
        print("[PERF] Error: realtime module not loaded!")
        return
    end

    realtime.ResetPerfStats()
    PERF_MONITOR.start_time = CurTime()
    PERF_MONITOR.events_at_start = 0

    print("[PERF] ✓ Performance statistics RESET")
end, nil, "Reset realtime performance statistics")

-- ============================================================================
-- INITIALIZATION MESSAGE
-- ============================================================================

print("\n" .. string.rep("=", 80))
print("  REALTIME PERFORMANCE MONITOR - Commands Available")
print(string.rep("=", 80))
print("  realtime_perf_start   : Start monitoring (prints stats every 5 sec)")
print("  realtime_perf_stop    : Stop monitoring")
print("  realtime_perf_stats   : Display stats once")
print("  realtime_perf_reset   : Reset statistics")
print(string.rep("=", 80) .. "\n")
