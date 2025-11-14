#pragma once

#include <chrono>
#include <atomic>
#include <string>
#include <unordered_map>
#include <mutex>

namespace realtime {

// Performance statistics for real-time event processing
class PerformanceStats {
public:
    using Clock = std::chrono::high_resolution_clock;
    using Duration = std::chrono::duration<double, std::milli>;  // milliseconds

    struct EventMetrics {
        double queue_wait_ms = 0.0;      // Time in ThreadSafeQueue
        double lua_callback_ms = 0.0;    // Time in Lua callback
        double total_latency_ms = 0.0;   // Total time from Redis to callback completion
    };

    struct ChannelStats {
        uint64_t event_count = 0;
        double avg_lua_time_ms = 0.0;
        double max_lua_time_ms = 0.0;
        double min_lua_time_ms = std::numeric_limits<double>::max();
    };

    // Statistics
    struct Stats {
        std::atomic<uint64_t> total_events{0};           // Total events processed
        std::atomic<uint64_t> total_callbacks{0};        // Total callbacks triggered
        std::atomic<double> avg_queue_wait_ms{0.0};      // Average queue wait time
        std::atomic<double> avg_lua_time_ms{0.0};        // Average Lua callback time
        std::atomic<double> avg_total_latency_ms{0.0};   // Average end-to-end latency
        std::atomic<double> max_lua_time_ms{0.0};        // Max single Lua callback time
        std::atomic<double> min_lua_time_ms{std::numeric_limits<double>::max()};  // Min Lua time
        std::atomic<double> throughput_events_per_sec{0.0};  // Events processed per second
        std::atomic<uint64_t> last_event_count{0};       // For throughput calculation
        std::chrono::high_resolution_clock::time_point last_throughput_calc = std::chrono::high_resolution_clock::now();
    };

    static PerformanceStats& GetInstance() {
        static PerformanceStats instance;
        return instance;
    }

    // Record an event being queued
    void RecordEventQueued(const std::string& /* channel */) noexcept {
        // Can add channel-specific stats here if needed
    }

    // Record event processing with channel info
    void RecordEventProcessed(
        const std::string& channel,
        double queue_wait_ms,
        double lua_callback_ms,
        double total_latency_ms
    ) noexcept {
        stats_.total_events++;
        stats_.total_callbacks++;
        
        // Update running averages (simplified - not a true running avg)
        stats_.avg_queue_wait_ms = queue_wait_ms;
        stats_.avg_lua_time_ms = lua_callback_ms;
        stats_.avg_total_latency_ms = total_latency_ms;
        
        if (lua_callback_ms > stats_.max_lua_time_ms) {
            stats_.max_lua_time_ms = lua_callback_ms;
        }
        if (lua_callback_ms < stats_.min_lua_time_ms) {
            stats_.min_lua_time_ms = lua_callback_ms;
        }

        // Update channel-specific stats
        {
            std::lock_guard<std::mutex> lock(channel_stats_mtx_);
            auto& ch_stats = channel_stats_[channel];
            ch_stats.event_count++;
            ch_stats.avg_lua_time_ms = lua_callback_ms;
            if (lua_callback_ms > ch_stats.max_lua_time_ms) {
                ch_stats.max_lua_time_ms = lua_callback_ms;
            }
            if (lua_callback_ms < ch_stats.min_lua_time_ms) {
                ch_stats.min_lua_time_ms = lua_callback_ms;
            }
        }
    }

    // Get current statistics
    const Stats& GetStats() const noexcept {
        return stats_;
    }

    // Get channel statistics
    std::unordered_map<std::string, ChannelStats> GetChannelStats() const noexcept {
        std::lock_guard<std::mutex> lock(channel_stats_mtx_);
        return channel_stats_;
    }

    // Reset statistics
    void Reset() noexcept {
        stats_.total_events = 0;
        stats_.total_callbacks = 0;
        stats_.avg_queue_wait_ms = 0.0;
        stats_.avg_lua_time_ms = 0.0;
        stats_.avg_total_latency_ms = 0.0;
        stats_.max_lua_time_ms = 0.0;
        stats_.min_lua_time_ms = std::numeric_limits<double>::max();
        stats_.throughput_events_per_sec = 0.0;
        {
            std::lock_guard<std::mutex> lock(channel_stats_mtx_);
            channel_stats_.clear();
        }
    }

    // Get formatted stats string for logging
    std::string GetStatsString() const noexcept;

private:
    PerformanceStats() noexcept = default;
    ~PerformanceStats() noexcept = default;

    // Delete copy/move
    PerformanceStats(const PerformanceStats&) = delete;
    PerformanceStats& operator=(const PerformanceStats&) = delete;

    mutable Stats stats_;
    mutable std::mutex channel_stats_mtx_;
    std::unordered_map<std::string, ChannelStats> channel_stats_;
};

}  // namespace realtime
