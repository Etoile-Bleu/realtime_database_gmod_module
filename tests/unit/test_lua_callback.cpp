#include <cassert>
#include <cstdio>
#include <stdexcept>
#include <lua.hpp>
#include "realtime/core/lua_callback.h"

using namespace realtime::core;

// ============================================================================
// Test 1: Create and Destroy
// ============================================================================
void TestCreateAndDestroy() {
    lua_State* L = luaL_newstate();
    assert(L != nullptr);

    // Create a function on stack
    luaL_loadstring(L, "return function(ch, msg) print('Got:', ch, msg) end");
    lua_call(L, 0, 1);  // Execute, leaves function on stack

    {
        LuaCallback cb(L, -1);
        assert(cb.IsValid());
    }
    // Destructor should have cleaned up

    lua_close(L);
    printf("[✓] Test 1: Create and Destroy\n");
}

// ============================================================================
// Test 2: Call Callback
// ============================================================================
void TestCallCallback() {
    lua_State* L = luaL_newstate();
    luaL_openlibs(L);

    // Create callback that sets a global variable
    luaL_loadstring(L, "return function(ch, msg) _test_result = ch .. ':' .. msg end");
    lua_call(L, 0, 1);

    LuaCallback cb(L, -1);
    lua_pop(L, 1);  // Pop function from stack

    // Call the callback
    cb.Call(L, "player:spawn", "test_message");

    // Check the global was set
    lua_getglobal(L, "_test_result");
    assert(lua_isstring(L, -1));
    [[maybe_unused]] const char* result = lua_tostring(L, -1);
    assert(std::string(result) == "player:spawn:test_message");
    lua_pop(L, 1);

    lua_close(L);
    printf("[✓] Test 2: Call Callback\n");
}

// ============================================================================
// Test 3: Move Constructor
// ============================================================================
void TestMoveConstructor() {
    lua_State* L = luaL_newstate();

    luaL_loadstring(L, "return function() end");
    lua_call(L, 0, 1);

    LuaCallback cb1(L, -1);
    lua_pop(L, 1);
    assert(cb1.IsValid());

    // Move construct
    LuaCallback cb2 = std::move(cb1);

    // cb2 should be valid, cb1 should be invalid
    assert(cb2.IsValid());
    assert(!cb1.IsValid());

    lua_close(L);
    printf("[✓] Test 3: Move Constructor\n");
}

// ============================================================================
// Test 4: Move Assignment
// ============================================================================
void TestMoveAssignment() {
    lua_State* L = luaL_newstate();

    luaL_loadstring(L, "return function() end");
    lua_call(L, 0, 1);
    LuaCallback cb1(L, -1);
    lua_pop(L, 1);

    luaL_loadstring(L, "return function() end");
    lua_call(L, 0, 1);
    LuaCallback cb2(L, -1);
    lua_pop(L, 1);

    // Move assign
    cb1 = std::move(cb2);

    assert(cb1.IsValid());
    assert(!cb2.IsValid());

    lua_close(L);
    printf("[✓] Test 4: Move Assignment\n");
}

// ============================================================================
// Test 5: Multiple Callbacks
// ============================================================================
void TestMultipleCallbacks() {
    lua_State* L = luaL_newstate();
    luaL_openlibs(L);

    // Create two independent callbacks
    luaL_loadstring(L, "return function() _cb1 = true end");
    lua_call(L, 0, 1);
    LuaCallback cb1(L, -1);
    lua_pop(L, 1);

    luaL_loadstring(L, "return function() _cb2 = true end");
    lua_call(L, 0, 1);
    LuaCallback cb2(L, -1);
    lua_pop(L, 1);

    // Call both
    cb1.Call(L, "", "");
    cb2.Call(L, "", "");

    // Both should have executed
    lua_getglobal(L, "_cb1");
    assert(lua_toboolean(L, -1));
    lua_pop(L, 1);

    lua_getglobal(L, "_cb2");
    assert(lua_toboolean(L, -1));
    lua_pop(L, 1);

    lua_close(L);
    printf("[✓] Test 5: Multiple Callbacks\n");
}

// ============================================================================
// Test 6: Error Handling
// ============================================================================
void TestErrorHandling() {
    lua_State* L = luaL_newstate();
    luaL_openlibs(L);

    // Create callback that throws an error
    luaL_loadstring(L, "return function() error('Test error') end");
    lua_call(L, 0, 1);
    LuaCallback cb(L, -1);
    lua_pop(L, 1);

    // Call should handle error gracefully (no crash)
    cb.Call(L, "", "");

    // Stack should be clean
    [[maybe_unused]] int stack_size = lua_gettop(L);
    assert(stack_size == 0);

    lua_close(L);
    printf("[✓] Test 6: Error Handling\n");
}

// ============================================================================
// Test 7: Invalid Callback
// ============================================================================
void TestInvalidCallback() {
    lua_State* L = luaL_newstate();

    // Create default (invalid) callback
    LuaCallback cb(L, 1);  // Stack empty, invalid index
    assert(!cb.IsValid());

    // Call should do nothing
    cb.Call(L, "test", "test");

    lua_close(L);
    printf("[✓] Test 7: Invalid Callback\n");
}

// ============================================================================
// Test 8: Callback with Arguments
// ============================================================================
void TestCallbackWithArguments() {
    lua_State* L = luaL_newstate();
    luaL_openlibs(L);

    // Create callback that concatenates arguments
    luaL_loadstring(L, 
        "return function(ch, msg)\n"
        "  _result = 'Ch:' .. tostring(ch) .. ' Msg:' .. tostring(msg)\n"
        "end"
    );
    lua_call(L, 0, 1);
    LuaCallback cb(L, -1);
    lua_pop(L, 1);

    cb.Call(L, "myChannel", "myMessage");

    lua_getglobal(L, "_result");
    [[maybe_unused]] const char* result = lua_tostring(L, -1);
    assert(std::string(result) == "Ch:myChannel Msg:myMessage");
    lua_pop(L, 1);

    lua_close(L);
    printf("[✓] Test 8: Callback with Arguments\n");
}

// ============================================================================
// Main
// ============================================================================
int main() {
    printf("\n");
    printf("=============================================================\n");
    printf("LuaCallback RAII Unit Tests\n");
    printf("=============================================================\n\n");

    try {
        TestCreateAndDestroy();
        TestCallCallback();
        TestMoveConstructor();
        TestMoveAssignment();
        TestMultipleCallbacks();
        TestErrorHandling();
        TestInvalidCallback();
        TestCallbackWithArguments();

        printf("\n=============================================================\n");
        printf("All 8 tests passed! ✓\n");
        printf("=============================================================\n\n");
        return 0;
    } catch (const std::exception& e) {
        printf("\n[✗] Exception: %s\n", e.what());
        return 1;
    }
}
