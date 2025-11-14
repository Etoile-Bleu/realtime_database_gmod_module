#pragma once

#include <string>
#include "realtime/core/lua_callback.h"

namespace realtime {

// ============================================================================
// RedisEvent - Event with callback stored in queue
// ============================================================================
//
// This structure represents a message received from Redis, along with
// the Lua callback to invoke when the message arrives.
//
// Used with ThreadSafeQueue<RedisEvent> for inter-thread communication:
//   - Worker thread: Receive from Redis, create RedisEvent, Push to queue
//   - Main thread: Pop from queue, Call the callback
//
struct RedisEvent {
    std::string channel;
    std::string message;
    core::LuaCallback callback;

    // Constructors
    RedisEvent() = default;

    RedisEvent(std::string ch, std::string msg, core::LuaCallback cb)
        : channel(std::move(ch))
        , message(std::move(msg))
        , callback(std::move(cb)) {}

    // Move semantics (required for ThreadSafeQueue)
    RedisEvent(RedisEvent&&) noexcept = default;
    RedisEvent& operator=(RedisEvent&&) noexcept = default;

    // No copy (LuaCallback is move-only)
    RedisEvent(const RedisEvent&) = delete;
    RedisEvent& operator=(const RedisEvent&) = delete;
};

}  // namespace realtime
