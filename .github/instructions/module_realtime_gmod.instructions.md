---
applyTo: '**'
---
# C++ Modern Development - No Compromises

## Project Mission

This is a **native C++ binary module for Garry's Mod** enabling **direct real-time connections** between GMod servers and external databases without intermediaries (no Node.js, no HTTP polling).

### Technical Scope
- **Target**: Persistent network connection with pub/sub databases (Redis primary, PostgreSQL secondary)
- **Deliverable**: `gmsv_realtime_win64.dll` / `gmsv_realtime_linux64.dll`
- **API**: Simple Lua functions exposed via `garrysmod_common` and `lua_shared.dll` headers
- **Backend**: hiredis SDK for Redis connectivity
- **Behavior**: Fully asynchronous - zero `Think()` loops, zero polling from Lua side

### Core Features
1. **Direct connection** to local/remote Redis server
2. **Publish**: `publish(channel, message)` from GLua
3. **Subscribe**: `subscribe(channel, callback)` with instant event delivery
4. **Async reception**: Internal C++ thread handles TCP stream, triggers Lua callbacks via thread-safe queue when messages arrive

### Architecture Goals
- **Zero polling**: Module handles network, threading, and Lua synchronization internally
- **Minimal footprint**: High performance, low memory usage
- **Self-contained**: No external scripts, timers, or HTTP bridges
- **Cross-platform**: Windows (MSVC) + Linux (GCC) compatibility
- **Open-source**: First native real-time data layer for GLua community

### Non-Negotiable Requirements
- **Modern C++**: C++17 minimum (C++20 preferred)
- **Scalable**: Easy to add new features, backends, or protocols
- **Maintainable**: Clean structure, zero technical debt from day one
- **Production-ready**: This is a foundational driver, not a prototype

---

## Philosophy
- Modern C++ or GTFO (C++17 minimum, C++20 preferred)
- Delete unused code on sight - no "maybe later", no comments, no dead functions
- RAII is religion - if you manually manage memory, you failed
- Thread safety is mandatory - shared state without locks = immediate rejection
- Explicit over implicit - crash loud, fail fast, no silent errors
- **Scalability first**: Design for extensibility, not just current requirements

## Hard Rules

### Memory Management
```cpp
// ✅ YES
std::unique_ptr<Client> client;
std::shared_ptr<Connection> conn;
std::vector<Message> messages;  // Always containers over raw arrays

// ❌ NO - Instant reject
Client* client = new Client();
char* buffer = malloc(256);
delete ptr;
free(buffer);
```

### Concurrency
```cpp
// ✅ YES
std::mutex mtx;
std::lock_guard<std::mutex> lock(mtx);
std::condition_variable cv;
std::atomic<bool> running{true};

// ❌ NO
pthread_mutex_t;
mtx.lock(); /* code */ mtx.unlock();  // Exception = deadlock
volatile bool flag;  // This isn't 2005
```

### Error Handling
```cpp
// ✅ YES
throw std::runtime_error("Clear error message");
std::optional<T> TryGet();
[[nodiscard]] Result<T, Error> Process();

// ❌ NO
return -1;  // Magic numbers
return nullptr;  // Silent failures
bool success; DoThing(&success);  // Out parameters
```

### Type Safety
```cpp
// ✅ YES
auto value = GetValue();
if (auto result = TryConnect(); result.has_value()) { }
std::string_view sv;  // Zero-copy string views

// ❌ NO
void* data;  // Type erasure without good reason
(SomeType*)ptr;  // C-style casts
NULL;  // Use nullptr
```

### Headers & Includes
```cpp
// ✅ YES - Order matters
#include <vector>      // STL
#include <hiredis.h>   // Third-party
#include "client.h"    // Project

// Use forward declarations
class RedisClient;  // Instead of #include "client.h"

// ❌ NO
#include "unused_header.h"  // Delete immediately
using namespace std;         // Namespace pollution
```

### Cleanup Policy
- See an unused function? Delete it NOW
- See commented code? Delete it NOW  
- See a TODO older than 1 week? Fix it or delete it NOW
- See a magic number? Make it a constexpr NOW

### Naming Conventions
```cpp
class RedisClient {};        // PascalCase classes
void ProcessMessage() {}     // PascalCase methods
std::string channel_name;    // snake_case variables
constexpr int kMaxRetries = 3;  // kPascalCase constants
```

### Forbidden Patterns
- Global mutable state (use dependency injection)
- Naked pointers (exception: API boundaries like lua_State*)
- Manual resource management (use RAII wrappers)
- Macros for logic (templates or constexpr functions)
- `#pragma once` without include guards fallback
- Empty catch blocks `catch(...) {}`

---

## GMod-Specific Rules

### Thread Safety (CRITICAL)
```cpp
// ✅ CORRECT - Never call Lua from worker thread
void WorkerThread() {
    while (running) {
        auto msg = ReceiveMessage();
        {
            std::lock_guard lock(queue_mtx);
            message_queue.push(std::move(msg));
        }
        cv.notify_one();
    }
}

// Main thread only
void ProcessLuaCallbacks(lua_State* L) {
    std::lock_guard lock(queue_mtx);
    while (!message_queue.empty()) {
        CallLuaCallback(L, message_queue.front());
        message_queue.pop();
    }
}

// ❌ FORBIDDEN - Calling Lua from any thread but main = INSTANT CRASH
void WorkerThread() {
    auto msg = ReceiveMessage();
    lua_getglobal(L, "callback");  // CRASH GUARANTEED
}
```

### Lua Reference Management (RAII Always)
```cpp
// ✅ CORRECT - RAII wrapper for Lua refs
class LuaCallback {
    lua_State* L;
    int ref;
public:
    LuaCallback(lua_State* L, int stack_idx) : L(L) {
        lua_pushvalue(L, stack_idx);
        ref = luaL_ref(L, LUA_REGISTRYINDEX);
    }
    ~LuaCallback() {
        if (ref != LUA_NOREF) {
            luaL_unref(L, LUA_REGISTRYINDEX, ref);
        }
    }
    // Delete copy, allow move
    LuaCallback(const LuaCallback&) = delete;
    LuaCallback& operator=(const LuaCallback&) = delete;
    LuaCallback(LuaCallback&& other) noexcept 
        : L(other.L), ref(other.ref) {
        other.ref = LUA_NOREF;
    }
    
    void Call(std::string_view channel, std::string_view message) {
        lua_rawgeti(L, LUA_REGISTRYINDEX, ref);
        lua_pushstring(L, channel.data());
        lua_pushstring(L, message.data());
        if (lua_pcall(L, 2, 0, 0) != 0) {
            const char* error = lua_tostring(L, -1);
            // Log error properly
            lua_pop(L, 1);
        }
    }
};

// ❌ NO - Manual ref management everywhere
int callback_ref = luaL_ref(L, LUA_REGISTRYINDEX);  // Who cleans this?
```

### Module Entry Points
```cpp
// ✅ Standard GMod module structure
GMOD_MODULE_OPEN() {
    // Initialize module
    LUA->PushSpecial(GarrysMod::Lua::SPECIAL_GLOB);
    LUA->CreateTable();
    
    // Register functions
    LUA->PushCFunction(Lua_Connect);
    LUA->SetField(-2, "Connect");
    
    LUA->PushCFunction(Lua_Publish);
    LUA->SetField(-2, "Publish");
    
    LUA->SetField(-2, "realtime");
    LUA->Pop();
    
    return 0;
}

GMOD_MODULE_CLOSE() {
    // Cleanup: stop threads, disconnect clients
    return 0;
}
```

---

## Scalability & Architecture

### Design for Extension
Every component must follow the **Open/Closed Principle**:
- Open for extension (new backends, protocols)
- Closed for modification (existing code stays stable)

### Interface-Based Design
```cpp
// ✅ Abstract backend interface
class IBackend {
public:
    virtual ~IBackend() = default;
    virtual bool Connect(std::string_view host, int port) = 0;
    virtual bool Publish(std::string_view channel, std::string_view msg) = 0;
    virtual void Subscribe(std::string_view channel, CallbackFn callback) = 0;
    virtual void Disconnect() = 0;
};

// Concrete implementations
class RedisBackend : public IBackend { /* ... */ };
class PostgreSQLBackend : public IBackend { /* ... */ };

// Factory pattern for extensibility
std::unique_ptr<IBackend> CreateBackend(BackendType type) {
    switch(type) {
        case BackendType::Redis: return std::make_unique<RedisBackend>();
        case BackendType::PostgreSQL: return std::make_unique<PostgreSQLBackend>();
    }
}
```

### Dependency Injection Pattern
```cpp
// ✅ Testable, extensible
class RealtimeModule {
    std::unique_ptr<IBackend> backend;
    std::unique_ptr<CallbackManager> callbacks;
    MessageQueue<Event> event_queue;

public:
    RealtimeModule(std::unique_ptr<IBackend> backend)
        : backend(std::move(backend)) {}
    
    void SetBackend(std::unique_ptr<IBackend> new_backend) {
        backend = std::move(new_backend);
    }
};

// ❌ Hardcoded dependencies
class RealtimeModule {
    RedisBackend redis;  // Can't swap, can't test
};
```

---

## Build System

### CMake Standards
```cmake
cmake_minimum_required(VERSION 3.15)
project(gmsv_realtime CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Warnings = errors
if(MSVC)
    add_compile_options(/W4 /WX /permissive-)
else()
    add_compile_options(-Wall -Wextra -Werror -pedantic)
endif()

# Modular target structure
add_library(realtime_core STATIC
    src/core/module_entry.cpp
    src/core/lua_bindings.cpp
)

add_library(realtime_backends STATIC
    src/backend/redis_backend.cpp
)

# Main module
add_library(gmsv_realtime SHARED
    $<TARGET_OBJECTS:realtime_core>
    $<TARGET_OBJECTS:realtime_backends>
)
```

### Testing Integration
```cmake
# Unit tests (fast, no external deps)
add_executable(unit_tests
    tests/unit/test_queue.cpp
    tests/unit/test_callbacks.cpp
)
target_link_libraries(unit_tests PRIVATE realtime_core)

# Integration tests (require Redis)
add_executable(integration_tests
    tests/integration/test_redis.cpp
)
target_link_libraries(integration_tests PRIVATE gmsv_realtime hiredis)
```

---

## Code Review Checklist
Before ANY commit, verify:
- [ ] Zero compiler warnings with -Wall -Wextra
- [ ] No raw pointers except API boundaries
- [ ] All resources managed by RAII
- [ ] Thread-safe or documented as single-threaded only
- [ ] No unused includes, functions, or variables
- [ ] All error paths handled explicitly
- [ ] No magic numbers (use constexpr)
- [ ] No TODO/FIXME older than current session
- [ ] **Can this be extended without modifying existing code?**
- [ ] **Is this component testable in isolation?**

---

## When Copilot Suggests Code, Ask:
1. Is this C++17+ or legacy garbage?
2. Who owns this memory?
3. What happens if an exception is thrown here?
4. Is this thread-safe? Prove it.
5. Can I delete any part of this?
6. **How easy is it to add a new backend/feature?**
7. **Can I test this without GMod running?**

---

## Examples of Excellence

### Thread-Safe Queue (Reusable Template)
```cpp
template<typename T>
class ThreadSafeQueue {
    mutable std::mutex mtx;
    std::queue<T> queue;
    std::condition_variable cv;
    std::atomic<bool> shutdown{false};

public:
    void Push(T value) {
        {
            std::lock_guard lock(mtx);
            if (shutdown) return;
            queue.push(std::move(value));
        }
        cv.notify_one();
    }

    std::optional<T> TryPop() {
        std::lock_guard lock(mtx);
        if (queue.empty()) return std::nullopt;
        T value = std::move(queue.front());
        queue.pop();
        return value;
    }

    std::optional<T> WaitAndPop(std::chrono::milliseconds timeout = std::chrono::milliseconds::max()) {
        std::unique_lock lock(mtx);
        if (!cv.wait_for(lock, timeout, [this]{ return !queue.empty() || shutdown; })) {
            return std::nullopt;
        }
        if (shutdown && queue.empty()) return std::nullopt;
        T value = std::move(queue.front());
        queue.pop();
        return value;
    }

    void Shutdown() {
        {
            std::lock_guard lock(mtx);
            shutdown = true;
        }
        cv.notify_all();
    }
};
```

### Backend Interface (Production-Ready)
```cpp
// Result type for error handling
template<typename T, typename E = std::string>
class Result {
    std::variant<T, E> data;
public:
    static Result Ok(T value) { return Result{std::move(value)}; }
    static Result Err(E error) { return Result{std::move(error)}; }
    
    bool IsOk() const { return std::holds_alternative<T>(data); }
    bool IsErr() const { return std::holds_alternative<E>(data); }
    
    T& Unwrap() { return std::get<T>(data); }
    const E& Error() const { return std::get<E>(data); }
};

// Backend interface
class IBackend {
public:
    virtual ~IBackend() = default;
    
    [[nodiscard]] virtual Result<void> Connect(
        std::string_view host, 
        uint16_t port,
        std::chrono::seconds timeout = std::chrono::seconds{5}
    ) = 0;
    
    [[nodiscard]] virtual Result<void> Publish(
        std::string_view channel, 
        std::string_view message
    ) = 0;
    
    [[nodiscard]] virtual Result<void> Subscribe(
        std::string_view channel,
        std::function<void(std::string_view, std::string_view)> callback
    ) = 0;
    
    virtual void Disconnect() noexcept = 0;
    virtual bool IsConnected() const noexcept = 0;
};
```

### Redis Backend Implementation
```cpp
class RedisBackend final : public IBackend {
    struct RedisContextDeleter {
        void operator()(redisContext* ctx) const { 
            if (ctx) redisFree(ctx); 
        }
    };
    
    std::unique_ptr<redisContext, RedisContextDeleter> context;
    std::atomic<bool> connected{false};
    std::thread subscriber_thread;
    ThreadSafeQueue<Event> event_queue;
    std::unordered_map<std::string, std::function<void(std::string_view, std::string_view)>> callbacks;
    std::mutex callbacks_mtx;

public:
    Result<void> Connect(std::string_view host, uint16_t port, std::chrono::seconds timeout) override {
        struct timeval tv { 
            .tv_sec = timeout.count(), 
            .tv_usec = 0 
        };
        
        context.reset(redisConnectWithTimeout(host.data(), port, tv));
        
        if (!context || context->err) {
            return Result<void>::Err(
                context ? context->errstr : "Failed to create context"
            );
        }
        
        connected = true;
        StartSubscriberThread();
        return Result<void>::Ok({});
    }

    Result<void> Publish(std::string_view channel, std::string_view message) override {
        if (!connected) {
            return Result<void>::Err("Not connected");
        }
        
        auto reply = std::unique_ptr<redisReply, decltype(&freeReplyObject)>(
            static_cast<redisReply*>(redisCommand(
                context.get(),
                "PUBLISH %b %b",
                channel.data(), channel.size(),
                message.data(), message.size()
            )),
            freeReplyObject
        );
        
        if (!reply || reply->type == REDIS_REPLY_ERROR) {
            return Result<void>::Err("Publish failed");
        }
        
        return Result<void>::Ok({});
    }

private:
    void StartSubscriberThread() {
        subscriber_thread = std::thread([this]() {
            while (connected) {
                redisReply* reply;
                if (redisGetReply(context.get(), reinterpret_cast<void**>(&reply)) == REDIS_OK) {
                    ProcessReply(reply);
                    freeReplyObject(reply);
                }
            }
        });
    }
    
    void ProcessReply(redisReply* reply) {
        if (reply->type == REDIS_REPLY_ARRAY && reply->elements == 3) {
            std::string channel{reply->element[1]->str, reply->element[1]->len};
            std::string message{reply->element[2]->str, reply->element[2]->len};
            
            event_queue.Push({std::move(channel), std::move(message)});
        }
    }
};
```

---

## Final Word

This is not a toy project. This is **infrastructure**.

Every line of code must be:
- **Production-ready**: No "TODO: improve this later"
- **Scalable**: Adding PostgreSQL backend shouldn't touch Redis code
- **Maintainable**: 6 months from now, adding features should be trivial
- **Testable**: Unit tests without GMod, integration tests with Redis

If the code wouldn't pass a 2025 C++ infrastructure review at a top-tier company, **delete it and start over**.

No excuses. No "it works". No "I'll refactor later".

**Modern C++ infrastructure or nothing.**