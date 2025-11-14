#include "realtime/performance_stats.h"
#include <sstream>
#include <iomanip>

namespace realtime {

std::string PerformanceStats::GetStatsString() const noexcept {
    std::ostringstream oss;
    auto& stats = stats_;

    // Calculate throughput
    auto now = std::chrono::high_resolution_clock::now();
    auto elapsed = std::chrono::duration_cast<std::chrono::duration<double>>(
        now - stats_.last_throughput_calc
    ).count();

    double throughput = 0.0;
    if (elapsed > 0) {
        auto events_since_last = static_cast<int64_t>(stats.total_events) - static_cast<int64_t>(stats.last_event_count);
        throughput = events_since_last / elapsed;
    }

    oss << "\n=== REALTIME MODULE PERFORMANCE STATS ===\n";
    oss << "Total Events Processed: " << stats.total_events << "\n";
    oss << "Total Callbacks Triggered: " << stats.total_callbacks << "\n";
    oss << std::fixed << std::setprecision(3);
    oss << "Avg Queue Wait Time: " << stats.avg_queue_wait_ms << " ms\n";
    oss << "Avg Lua Callback Time: " << stats.avg_lua_time_ms << " ms\n";
    oss << "Max Lua Callback Time: " << stats.max_lua_time_ms << " ms\n";
    oss << "Avg Total Latency (Redis→Callback): " << stats.avg_total_latency_ms << " ms\n";
    oss << std::fixed << std::setprecision(0);
    oss << "Throughput: " << throughput << " events/sec\n";
    oss << "========================================\n";

    return oss.str();
}

}  // namespace realtime
