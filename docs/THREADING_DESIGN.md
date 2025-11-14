// ============================================================================
// ThreadSafeQueue<T> - Usage Examples
// ============================================================================
//
// This file demonstrates how ThreadSafeQueue is used in the realtime module.
//

#include "realtime/core/message_queue.h"
#include <string>
#include <thread>

namespace realtime {

// ============================================================================
// Example 1: Event Structure
// ============================================================================

struct RedisEvent {
    std::string channel;
    std::string message;
};

// ============================================================================
// Example 2: Producer Thread (Worker - Redis subscriber)
// ============================================================================
//
// This would run in a background thread, blocking on Redis SUBSCRIBE.
// When messages arrive, push them to the queue.
//

void RedisWorkerThread(core::ThreadSafeQueue<RedisEvent>& event_queue) {
    // Pseudocode - actual Redis integration comes later
    
    while (true) {
        // Blocking read from Redis SUBSCRIBE
        // (this is what the worker thread does - never touches Lua!)
        
        RedisEvent event;
        event.channel = "player:spawn";
        event.message = R"({"player":"Elysium","team":1})";
        
        // Queue the event for Lua to process
        event_queue.Push(std::move(event));
        
        // If shutdown requested, loop ends
        if (event_queue.IsShutdown()) break;
    }
}

// ============================================================================
// Example 3: Consumer Thread (Main - Lua callbacks)
// ============================================================================
//
// This would run in GMod's main thread during Think hooks.
// Drain the event queue and trigger Lua callbacks.
//

void ProcessLuaCallbacksFromQueue(
    core::ThreadSafeQueue<RedisEvent>& event_queue,
    lua_State* L
) {
    // Non-blocking drain: process all available events
    while (auto event = event_queue.TryPop()) {
        // Safe to call Lua here (main thread)
        // Push callback, push channel and message, call lua_pcall()
        // (Lua binding implementation comes in phase 1.3)
        
        printf("[Event] %s: %s\n", event->channel.c_str(), event->message.c_str());
    }
}

// ============================================================================
// Example 4: Thread-Safe Shutdown
// ============================================================================
//
// When the module is unloaded, gracefully wake all threads.
//

void ModuleShutdown(core::ThreadSafeQueue<RedisEvent>& event_queue,
                    std::thread& worker_thread) {
    // Signal worker to stop
    event_queue.Shutdown();
    
    // Worker will eventually exit its loop
    worker_thread.join();
    
    // Process any remaining events
    while (auto event = event_queue.TryPop()) {
        printf("[Shutdown] Draining: %s\n", event->channel.c_str());
    }
}

// ============================================================================
// Key Design Principles (Per Instructions)
// ============================================================================
//
// 1. ZERO POLLING
//    Worker thread blocks on Redis, doesn't spin
//    Main thread uses WaitAndPop(timeout) only during Think hooks
//
// 2. RAII - No manual locks
//    Use std::lock_guard, std::unique_lock
//    Exception-safe, exception-neutral
//
// 3. Thread Safety
//    Worker thread: Push to queue, never touches Lua
//    Main thread: Pop from queue, calls Lua
//    Queue ensures no races, no deadlocks
//
// 4. Testable
//    ThreadSafeQueue can be tested without Redis or GMod
//    See tests/unit/test_message_queue.cpp
//

}  // namespace realtime
