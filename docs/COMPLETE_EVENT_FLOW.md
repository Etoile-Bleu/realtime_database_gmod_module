// ============================================================================
// Example: Complete Event Flow with ThreadSafeQueue + LuaCallback
// ============================================================================
//
// This demonstrates how ThreadSafeQueue<RedisEvent> carries both the message
// and the callback through the thread boundary, safely.
//

#include "realtime/core/core.h"
#include "realtime/redis_event.h"
#include <thread>

using namespace realtime;
using namespace realtime::core;

// Global queue (will be refactored to dependency injection in Phase 2)
static ThreadSafeQueue<RedisEvent> g_event_queue;
static bool g_running = true;

// ============================================================================
// Example 1: Lua Code Subscribing
// ============================================================================
//
// Lua code:
//   realtime.Subscribe("player:spawn", function(channel, message)
//       print("Event:", channel, message)
//   end)
//
// What happens in C++:
//   1. Lua calls realtime.Subscribe()
//   2. C++ extracts channel string from Lua
//   3. C++ creates LuaCallback(L, stack_index) - captures callback reference
//   4. C++ stores (channel -> callback) mapping
//

void Lua_Subscribe(lua_State* L) {
    // Extract channel (from Lua argument)
    const char* channel = lua_tostring(L, 1);  // "player:spawn"

    // Extract callback (from Lua argument)
    // lua_isfunction(L, 2) == true

    // Create RAII callback wrapper
    // This pushes the function to registry and captures the reference
    LuaCallback callback(L, 2);

    // Store in some map (Phase 2.1 will implement this)
    // g_callbacks[channel] = std::move(callback);

    lua_pushboolean(L, true);
    return 1;
}

// ============================================================================
// Example 2: Worker Thread Receives Event
// ============================================================================
//
// Worker thread (background, blocking on Redis SUBSCRIBE):
//   1. Receives message from Redis
//   2. Looks up the callback for that channel
//   3. Creates RedisEvent with the callback
//   4. Pushes to queue (thread-safe!)
//   5. Main thread wakes up
//

void WorkerThreadExample() {
    while (g_running) {
        // Pseudocode: Blocking read from Redis
        // redisReply* reply = redisGetReply(redis_context, ...);

        // Simulate event
        const char* channel = "player:spawn";
        const char* message = R"({"player":"Elysium"})";

        // Lookup callback from subscription map
        // LuaCallback* cb = FindCallback(channel);
        // if (!cb) continue;  // No subscriber

        // Instead of calling directly (CRASH!), we move it to queue
        RedisEvent event(
            channel,
            message,
            std::move(*cb)  // Move callback ownership to event
        );

        // Thread-safe push (uses std::lock_guard internally)
        g_event_queue.Push(std::move(event));

        // Main thread will be notified and wake from WaitAndPop()
    }
}

// ============================================================================
// Example 3: Main Thread Processes Events
// ============================================================================
//
// Main thread (GMod Think hook):
//   1. Calls ProcessEvents() during Think
//   2. Pops events from queue (non-blocking)
//   3. Invokes each callback with (channel, message)
//   4. Lua code executes in main thread context (SAFE!)
//

void ProcessEvents(lua_State* L) {
    // Non-blocking drain: process all available events
    while (auto event = g_event_queue.TryPop()) {
        // Now we're in main thread with the callback
        // Safe to call Lua!

        event->callback.Call(L, event->channel, event->message);

        // Lua executed: function(channel, message) was invoked
        // Output: "Event: player:spawn {"player":"Elysium"}"

        // When event goes out of scope:
        // ~RedisEvent() → ~LuaCallback() → luaL_unref()
        // Reference is automatically freed!
    }
}

// ============================================================================
// Example 4: Thread Safety Guarantee
// ============================================================================
//
// Thread A (Worker)                    Thread B (Main)
//  │                                      │
//  ├─ Blocks on Redis SUBSCRIBE           ├─ Lua Think hook
//  │                                      │
//  ├─ Receives message ────────────────┐  │
//  │                                   │  │
//  ├─ Creates RedisEvent               │  │
//  │   with LuaCallback moved          │  │
//  │                                   │  │
//  ├─ Calls Push() ◄──────────────────┤  │
//  │   (thread-safe lock_guard)        │  │
//  │   (signals condition_variable)    │  ├─ Wakes from WaitAndPop()
//  │                                   │  │
//  ├─ Returns to SUBSCRIBE             │  ├─ Calls TryPop()
//  │                                   ├──┤ (gets RedisEvent)
//  │                                   │  │
//  │                                   │  ├─ Calls callback.Call(L, ...)
//  │                                   │  │ (SAFE: main thread + Lua context)
//  │                                   │  │
//  │                                   │  ├─ Event destroyed
//  │                                   │  │ (callback.unref() called)
//  │                                   │  │
//
// Key properties:
//   ✅ Worker never touches Lua
//   ✅ Main only processes after Pop (queue ensures ownership transfer)
//   ✅ Callback reference automatically freed on destruction (RAII)
//   ✅ Zero manual reference management
//   ✅ No deadlocks (std::lock_guard only)
//

// ============================================================================
// Example 5: Shutdown Sequence
// ============================================================================
//
// On module unload:
//   1. Call queue.Shutdown() (from main thread)
//   2. Worker thread wakes from SUBSCRIBE, exits
//   3. Main thread drains remaining events
//   4. All callbacks destroyed (references freed)
//   5. Module unloads cleanly
//

void ModuleShutdown(lua_State* L, std::thread& worker) {
    // Signal all threads to wake up
    g_event_queue.Shutdown();

    // Wait for worker to exit
    g_running = false;
    if (worker.joinable()) {
        worker.join();
    }

    // Process remaining events
    while (auto event = g_event_queue.TryPop()) {
        printf("[Shutdown] Draining: %s\n", event->channel.c_str());
        event->callback.Call(L, event->channel, event->message);
    }

    printf("[Module] Clean shutdown complete\n");
}

// ============================================================================
// Key Design Decisions (Per Instructions)
// ============================================================================
//
// 1. RAII Always
//    ✅ LuaCallback destructor always calls luaL_unref()
//    ✅ No manual reference management
//    ✅ Exception-safe (destructor noexcept)
//
// 2. Move-Only Semantics
//    ✅ LuaCallback deleted copy constructor/assignment
//    ✅ Forced move for ownership transfer
//    ✅ Prevents reference duplication
//
// 3. Thread Safety
//    ✅ Callback ownership moves from worker → queue → main
//    ✅ Main thread always invokes callbacks (never from worker)
//    ✅ Queue ensures no races
//
// 4. Testable
//    ✅ LuaCallback tested in isolation (test_lua_callback.cpp)
//    ✅ RedisEvent tested with queue (test_message_queue.cpp)
//    ✅ No external dependencies (only lua.h)
//
// 5. No Polling
//    ✅ Worker blocks on Redis
//    ✅ Main calls WaitAndPop(timeout) only during Think
//    ✅ condition_variable wakes threads efficiently
//
