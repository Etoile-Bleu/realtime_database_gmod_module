#pragma once

#include <lua.hpp>
#include <string_view>
#include <utility>
#include <cstdio>

namespace realtime::core {

// ============================================================================
// LuaCallback - RAII Wrapper for Lua Registry References
// ============================================================================
//
// Per instructions: "Lua Reference Management (RAII Always)"
//
// Problem:
//   lua_State has a registry where Lua references are stored. If you don't
//   properly unreference them, they leak indefinitely. Manual management is
//   error-prone and violates RAII.
//
// Solution:
//   LuaCallback wraps the reference lifecycle:
//   - Constructor: Pushes value, stores reference in LUA_REGISTRYINDEX
//   - Destructor: Unreferences, returns slot to pool
//   - Move-only: No copying (references are unique per L)
//   - Exception-safe: Destructor always cleans up
//
// Usage:
//   // Store callback when Lua calls realtime.Subscribe()
//   LuaCallback cb(L, stack_index);  // Takes ownership of reference
//
//   // Call it later from main thread
//   cb.Call(L, "player:spawn", "{...}");
//
//   // Automatic cleanup on destruction
//   ~LuaCallback() → luaL_unref(L, LUA_REGISTRYINDEX, ref)
//
// ============================================================================

class LuaCallback {
private:
    lua_State* L_;
    int ref_;

public:
    // ========================================================================
    // Constructor - Capture Lua value and reference it
    // ========================================================================
    // Precondition:
    //   - L is valid lua_State
    //   - stack_index points to valid Lua value (usually a function)
    // Postcondition:
    //   - Reference stored, value pushed to registry
    //   - Stack unchanged (we push/pop internally)
    // Throws: Never (noexcept)
    //
    explicit LuaCallback(lua_State* L, int stack_index) noexcept
        : L_(L) {
        // Push the value to reference
        lua_pushvalue(L_, stack_index);
        // Create reference in LUA_REGISTRYINDEX
        ref_ = luaL_ref(L_, LUA_REGISTRYINDEX);
    }

    // ========================================================================
    // Destructor - Unreference and cleanup
    // ========================================================================
    // Postcondition:
    //   - Reference freed, slot returned to pool
    //   - No memory leaks
    // Exception safety: noexcept (must be!)
    //
    ~LuaCallback() noexcept {
        if (ref_ != LUA_NOREF && L_ != nullptr) {
            luaL_unref(L_, LUA_REGISTRYINDEX, ref_);
        }
    }

    // ========================================================================
    // Move Constructor - Transfer ownership
    // ========================================================================
    // Takes reference from source, source becomes invalid
    // This allows ThreadSafeQueue<LuaCallback> to work
    //
    LuaCallback(LuaCallback&& other) noexcept
        : L_(other.L_), ref_(other.ref_) {
        // Invalidate source
        other.ref_ = LUA_NOREF;
        other.L_ = nullptr;
    }

    // ========================================================================
    // Move Assignment - Transfer ownership
    // ========================================================================
    LuaCallback& operator=(LuaCallback&& other) noexcept {
        // Clean up our own reference first
        if (ref_ != LUA_NOREF && L_ != nullptr) {
            luaL_unref(L_, LUA_REGISTRYINDEX, ref_);
        }

        // Take ownership of source's reference
        L_ = other.L_;
        ref_ = other.ref_;

        // Invalidate source
        other.ref_ = LUA_NOREF;
        other.L_ = nullptr;

        return *this;
    }

    // Delete copy operations (references are move-only)
    LuaCallback(const LuaCallback&) = delete;
    LuaCallback& operator=(const LuaCallback&) = delete;

    // ========================================================================
    // Call() - Invoke the stored Lua callback
    // ========================================================================
    // Parameters:
    //   L - Lua state (must be main thread)
    //   channel - Channel name (passed as arg 1)
    //   message - Message content (passed as arg 2)
    //
    // Precondition:
    //   - L is the main Lua thread (same as when callback was created)
    //   - callback_ref must be valid
    //
    // Behavior:
    //   - Retrieves callback from registry
    //   - Pushes arguments (channel, message)
    //   - Calls lua_pcall with error handling
    //   - Pops result
    //   - Logs errors if callback fails
    //
    // Exception safety: Strong (no state changes on error)
    //
    void Call(lua_State* L, std::string_view channel, std::string_view message) const noexcept {
        // Safety check
        if (ref_ == LUA_NOREF || L == nullptr) {
            return;
        }

        // Retrieve callback from registry
        lua_rawgeti(L, LUA_REGISTRYINDEX, ref_);

        // Check it's still a function
        if (!lua_isfunction(L, -1)) {
            lua_pop(L, 1);
            return;
        }

        // Push arguments
        lua_pushlstring(L, channel.data(), channel.size());
        lua_pushlstring(L, message.data(), message.size());

        // Call with 2 args, 0 results
        int result = lua_pcall(L, 2, 0, 0);

        if (result != 0) {  // 0 = LUA_OK
            // Error occurred
            const char* error_msg = lua_tostring(L, -1);
            fprintf(stderr, "[Lua Error] %s\n", error_msg ? error_msg : "Unknown error");
            lua_pop(L, 1);  // Pop error message
        }
    }

    // ========================================================================
    // IsValid() - Check if callback is still valid
    // ========================================================================
    [[nodiscard]] bool IsValid() const noexcept {
        return ref_ != LUA_NOREF && L_ != nullptr;
    }

    // ========================================================================
    // GetRef() - Get raw reference (for debugging)
    // ========================================================================
    [[nodiscard]] int GetRef() const noexcept {
        return ref_;
    }

private:
    // No other public methods
};

}  // namespace realtime::core
