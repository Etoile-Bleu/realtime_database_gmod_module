# Roadmap - GMod Realtime Module

**Status**: POC Phase ✅ → Production Phase 🚀

## Project Context
- **Scope**: Single GMod server + Redis local/remote
- **Goal**: Real-time event streaming with zero polling
- **Standards**: Modern C++17, RAII, thread-safe, production-ready

---

## Phase 1: Core Architecture (CRITICAL) 🔴

### 1.1 Refactor: Separate Concerns
**Why**: Current `main.cpp` is monolithic. Instructions demand scalability & testability.

**Tasks**:
- [ ] Create `src/core/redis_client.h` - Abstract `IBackend` interface
- [ ] Create `src/backend/redis_backend.cpp` - Redis implementation
- [ ] Create `src/core/message_queue.h` - Thread-safe queue (template)
- [ ] Create `src/core/lua_bindings.h` - Lua API wrapper
- [ ] Move `Lua_Connect`, `Lua_Publish`, etc. to separate file
- [ ] Delete global `g_redis` variable → use dependency injection

**Example Structure**:
```
src/
├── core/
│   ├── redis_client.h         (IBackend interface)
│   ├── message_queue.h        (ThreadSafeQueue<T>)
│   └── lua_bindings.h         (LuaCallback RAII wrapper)
├── backend/
│   ├── redis_backend.h
│   └── redis_backend.cpp
├── lua/
│   ├── module_entry.cpp       (GMOD_MODULE_OPEN/CLOSE)
│   └── lua_api.cpp            (Lua function wrappers)
└── main.cpp                   (stays minimal)
```

**Verification**: Can you add PostgreSQL backend without touching Redis code? If yes, done ✅

---

### 1.2 Implement Thread-Safe Event Queue
**Why**: Instructions demand threading without raw mutexes. Need RAII queue for worker thread → main thread communication.

**Implementation**:
```cpp
template<typename T>
class ThreadSafeQueue {
    // Per instructions: std::mutex + std::lock_guard + std::condition_variable
    // Methods: Push(), TryPop(), WaitAndPop(timeout), Shutdown()
};
```

**Tasks**:
- [ ] Create `src/core/message_queue.h` with full implementation
- [ ] Add unit tests: `tests/unit/test_message_queue.cpp`
- [ ] Verify: No deadlocks, no data races (use clang-tidy)

---

### 1.3 Implement Lua Reference Management (RAII)
**Why**: Instructions show `LuaCallback` wrapper. Critical for not leaking registry refs.

**Implementation**:
```cpp
class LuaCallback {
    lua_State* L;
    int ref;  // LUA_REGISTRYINDEX ref
public:
    LuaCallback(lua_State* L, int stack_idx);  // Push & ref
    ~LuaCallback();                             // Unref automatically
    LuaCallback(const LuaCallback&) = delete;  // No copy
    LuaCallback(LuaCallback&&) noexcept;       // Move allowed
    void Call(std::string_view channel, std::string_view msg);
};
```

**Tasks**:
- [ ] Create `src/core/lua_callback.h` with full RAII wrapper
- [ ] Add unit tests: `tests/unit/test_lua_callback.cpp`
- [ ] Verify: No registry leaks over 1000+ callbacks

---

## Phase 2: Async Architecture (BLOCKING FEATURE) 🔴

### 2.1 Implement Async Subscribe with Worker Thread
**Why**: Current subscribe is synchronous. Need background thread handling Redis stream.

**Design**:
```cpp
class RedisBackend final : public IBackend {
    std::thread subscriber_thread;      // Handles SUBSCRIBE
    ThreadSafeQueue<Event> event_queue; // Worker → Main thread
    std::atomic<bool> connected{false};
    
    void SubscriberLoop();  // Worker thread: reads Redis, queues events
    void ProcessEventQueue(lua_State* L);  // Main thread: triggers callbacks
};
```

**Tasks**:
- [ ] Implement `RedisBackend::SubscriberLoop()` - handles Redis SUBSCRIBE
- [ ] Implement event routing to Lua callbacks (from queue)
- [ ] Add timeout & error handling (connection loss, Redis crash)
- [ ] Thread-safe callback registry (`std::unordered_map<std::string, LuaCallback>`)

**Critical**: Worker thread NEVER calls Lua directly. Only queue events. Main thread triggers.

---

### 2.2 Implement Module Lifecycle Hooks
**Why**: Need proper startup/shutdown, cleanup resources gracefully.

**Tasks**:
- [ ] `GMOD_MODULE_OPEN()` → Initialize backend, start worker thread
- [ ] `GMOD_MODULE_CLOSE()` → Stop worker thread, cleanup connections
- [ ] Lua: `realtime.ProcessEvents()` → Call from `Think` hook to flush queue
- [ ] Error handling: Graceful fallback if Redis unavailable

---

## Phase 3: Production-Ready Implementation 🟡

### 3.1 Error Handling & Connection Management
**Why**: Current implementation assumes Redis always works. Need resilience.

**Tasks**:
- [ ] Implement `Result<T, E>` pattern (per instructions)
- [ ] Handle Redis connection failures (reconnect logic with backoff)
- [ ] Implement timeout handling (configurable)
- [ ] Add logging: `[Redis]`, `[Error]`, `[Warn]` prefixes
- [ ] Test: Behavior when Redis goes down mid-stream

**Error Cases**:
```cpp
// ❌ Current: Returns bool, silent failures
LUA->PushBool(false);  // Why did it fail?

// ✅ Better: Result type or exceptions
Result<void> Connect(...);  // Can check IsErr() and Error()
```

---

### 3.2 Extend POC Functions - Production Events
**Why**: Current POC has basic vehicle tracking. Need more realistic events.

**Add Functions**:
- [ ] `realtime.PlayerSpawn(player_name, team, pos)`
- [ ] `realtime.PlayerDeath(victim_name, attacker_name, weapon)`
- [ ] `realtime.ChatMessage(player_name, message)`
- [ ] `realtime.PlayerTakeDamage(victim_name, damage, attacker_name)`
- [ ] `realtime.RoundStart(gamemode, map)`
- [ ] `realtime.RoundEnd(winner_team, score)`

**Each function**:
- Publishes to appropriate channel (`player:spawn`, `chat:message`, etc.)
- JSON format with timestamp
- Error handling per Result<T> pattern

---

### 3.3 Configuration System
**Why**: Hardcoding `127.0.0.1:6379` won't work. Need env vars or config file.

**Tasks**:
- [ ] Add Lua config: `realtime.Config(host, port, password, timeout)`
- [ ] Add environment variable support: `REDIS_HOST`, `REDIS_PORT`, `REDIS_PASSWORD`
- [ ] Add `.env` file parsing (optional)
- [ ] Validate configuration before connection

**Example**:
```lua
-- In Lua startup
realtime.Config("redis.example.com", 6379, "mypassword", 5)
realtime.Connect()  -- Uses config
```

---

## Phase 4: Testing & Validation 🟡

### 4.1 Unit Tests (No Dependencies)
**Why**: Instructions demand testable code. Unit tests without Redis/GMod running.

**Test Files**:
- [ ] `tests/unit/test_message_queue.cpp` - Queue push/pop/shutdown
- [ ] `tests/unit/test_lua_callback.cpp` - RAII wrapper + registry
- [ ] `tests/unit/test_result_type.cpp` - Error handling pattern
- [ ] `tests/unit/test_config.cpp` - Config parsing

**CMake**:
```cmake
add_executable(unit_tests
    tests/unit/test_message_queue.cpp
    tests/unit/test_lua_callback.cpp
)
target_link_libraries(unit_tests PRIVATE realtime_core)
```

**Run**: `ctest` → should be <1 second, no external deps

---

### 4.2 Integration Tests (With Redis)
**Why**: Verify actual Redis communication works.

**Test Files**:
- [ ] `tests/integration/test_redis_connect.cpp` - Connection/disconnect
- [ ] `tests/integration/test_redis_publish.cpp` - Publish message
- [ ] `tests/integration/test_redis_subscribe.cpp` - Subscribe + receive
- [ ] `tests/integration/test_redis_threading.cpp` - Worker thread + events

**Requirement**: Redis running locally (skip if unavailable)

**CMake**:
```cmake
add_executable(integration_tests
    tests/integration/test_redis_publish.cpp
)
target_link_libraries(integration_tests PRIVATE gmsv_realtime hiredis)
```

**Run**: `ctest --label-regex integration` (only if Redis available)

---

### 4.3 Manual Testing (GMod Integration)
**Why**: Verify module loads in actual GMod, no crashes.

**Checklist**:
- [ ] Module loads: `require("realtime")` works
- [ ] Connection works: `realtime.Connect("127.0.0.1", 6379)` returns true
- [ ] Publish works: `realtime.Publish("test", "hello")` sends message
- [ ] Subscribe works: Messages arrive in callback (zero lag)
- [ ] Unload works: No crashes on `GMOD_MODULE_CLOSE()`
- [ ] 1000+ events: No memory leaks (profile with Valgrind)

---

## Phase 5: Documentation & Polish 🟢

### 5.1 API Documentation
**Tasks**:
- [ ] Create `docs/API.md` - All Lua functions with examples
- [ ] Create `docs/ARCHITECTURE.md` - Design decisions, threading model
- [ ] Create `docs/BUILD.md` - Windows (MSVC) + Linux (GCC) build guide
- [ ] Create `docs/TROUBLESHOOTING.md` - Common issues & fixes

---

### 5.2 Code Quality
**Tasks**:
- [ ] Run `clang-format` - Consistent style
- [ ] Run `clang-tidy` - Static analysis (catch bugs)
- [ ] Run `cppcheck` - Additional checks
- [ ] Verify: Zero compiler warnings with `/W4 /WX` (MSVC) and `-Wall -Wextra -Werror` (GCC)

---

### 5.3 Performance Profiling
**Why**: Verify latency meets real-time requirements.

**Tasks**:
- [ ] Measure latency: PUBLISH → Callback trigger (target: <5ms)
- [ ] Measure memory: 10,000 events in-flight (target: <10MB)
- [ ] Measure CPU: 100 concurrent callbacks (target: <5% CPU)
- [ ] Test: Sustained load (1000 events/sec for 1 hour)

---

## Phase 6: Advanced Features (Nice-to-Have) 🟢

### 6.1 Persistent Message Store
**Why**: Ensure no events are lost, even if subscriber temporarily unavailable.

**Implementation Options**:
- [ ] Use Redis `XREAD` (streams) instead of `SUBSCRIBE`
- [ ] Add local SQLite backup queue
- [ ] Implement: Fallback to disk if Redis down

---

### 6.2 Multi-Channel Filtering
**Why**: Allow Lua to subscribe to patterns, not just exact channels.

**Tasks**:
- [ ] Implement `PSUBSCRIBE` support (Redis pattern subscribe)
- [ ] Lua API: `realtime.SubscribePattern("player:*")`

---

### 6.3 Metrics & Monitoring
**Why**: Track module health in production.

**Tasks**:
- [ ] Expose counters: `realtime.GetStats()` → {published, received, dropped}
- [ ] Add redis command: `INFO gmod:realtime` (custom Redis command? Maybe)
- [ ] Add Lua metrics: Events per second, queue depth, etc.

---

## Implementation Order (Priority)

**Week 1-2 (Critical Path)**:
1. Phase 1.1 - Refactor into modules (architecture)
2. Phase 1.2 - Thread-safe queue + tests
3. Phase 2.1 - Async subscribe with worker thread
4. Phase 2.2 - Module lifecycle hooks

**Week 3 (Production)**:
5. Phase 3.1 - Error handling (Result<T>)
6. Phase 3.2 - More event types
7. Phase 4.1 - Unit tests

**Week 4 (Polish)**:
8. Phase 3.3 - Configuration system
9. Phase 4.2 - Integration tests
10. Phase 5.1 - Documentation

---

## Definition of Done ✅

### For Each Feature:
- [ ] Code follows instructions (C++17, RAII, no raw pointers, thread-safe)
- [ ] Unit tests pass
- [ ] Integration tests pass (if applicable)
- [ ] Zero compiler warnings
- [ ] Clang-tidy clean
- [ ] Code review checklist satisfied
- [ ] Documentation updated

### For Full Release:
- [ ] All phases 1-5 complete
- [ ] 0 memory leaks (Valgrind)
- [ ] Latency <5ms proven (benchmark)
- [ ] Handles 1000+ concurrent events
- [ ] Graceful shutdown
- [ ] README + API docs complete
- [ ] Example scripts for common use cases

---

## Technical Debt Cleanup

**Delete on sight** (per instructions):
- [ ] Remove `std::cout` → Use proper logging framework
- [ ] Remove magic numbers → `constexpr kMaxQueueSize = 10000;`
- [ ] Remove old POC functions once new ones exist
- [ ] Remove commented code immediately
- [ ] No `TODO`/`FIXME` older than current session

---

## Notes

- **Single Server Scope**: No multi-server arbitration needed (simplifies design)
- **Redis as Source of Truth**: All events flow through Redis pub/sub
- **Lua is Slow**: Keep heavy lifting in C++ (network, threading, JSON parsing)
- **GMod Restrictions**: Can only call Lua from main thread → worker thread must queue
- **No Polling**: This is the whole point. Events flow, not polling

---

## References

- See `module_realtime_gmod.instructions.md` for code standards
- See `ARCHITECTURE.md` (to be created) for design details
- See `tests/` folder for test examples
