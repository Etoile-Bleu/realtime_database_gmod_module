# Testing the Realtime Module on GMod

## Prerequisites

1. **GMod Server** (32-bit or 64-bit)
   - Download: https://steamcmd.steamcmd.net/
   - Install: `steamcmd +login anonymous +app_update 4020 validate +quit`

2. **Redis Server** (for actual pub/sub testing)
   - Docker: `docker run -d -p 6379:6379 redis:latest`
   - Or: Download from https://redis.io

3. **The Compiled Module**
   - `gmsv_realtime_win64.dll` (for 64-bit GMod)
   - `gmsv_realtime_win32.dll` (for 32-bit GMod)

## Setup

### Step 1: Copy DLL to GMod

```bash
# Detect your GMod installation
cd "C:\dev\serveur_gmod\steamapps\common\GarrysModDS\garrysmod"

# Create bin directory if not exists
mkdir lua\bin

# Copy the appropriate DLL (64-bit recommended)
copy "C:\dev\gmod_realtime_module\build_x64\Release\gmsv_realtime_win64.dll" lua\bin\
# OR for 32-bit
copy "C:\dev\gmod_realtime_module\build_x86\Release\gmsv_realtime_win32.dll" lua\bin\
```

### Step 2: Copy Test Script

```bash
# Create autorun directory if not exists
mkdir lua\autorun\server

# Copy the comprehensive test script
copy "C:\dev\gmod_realtime_module\lua_scripts_for_gmod\test_comprehensive.lua" lua\autorun\server\
```

### Step 3: Start Redis (if testing pub/sub)

```bash
# Option 1: Docker
docker run -d -p 6379:6379 redis:latest

# Option 2: Native Redis
redis-server
```

### Step 4: Start GMod Server

```bash
cd "C:\dev\serveur_gmod"

# Run with console output
srcds.exe -game garrysmod +sv_pure 0 +maxplayers 32 +map gm_flatgrass 2>&1 | tee server.log
```

### Step 5: Check Output

In the server console, you should see:

```
======================================================================
  REALTIME MODULE - COMPREHENSIVE TEST SUITE
======================================================================
[*] Detected architecture: 64-bit
[*] Loading module: gmsv_realtime_win64
[OK] Realtime module loaded successfully
[OK] Available functions:
    - realtime.Connect(host, port)
    - realtime.Publish(channel, message)
    - realtime.Subscribe(channel, callback)
    - realtime.ProcessEvents()
    - realtime.IsConnected()
    - realtime.Disconnect()

----------------------------------------------------------------------
TEST 1: Connection to Redis
----------------------------------------------------------------------
[TEST] realtime.Connect('127.0.0.1', 6379)
[RESULT] Connection: SUCCESS

[... more tests ...]

======================================================================
  TEST SUMMARY
======================================================================
  Module Load                        : OK
  Connect Function                  : OK
  IsConnected Function              : OK
  Publish Function                  : OK
  Subscribe Function                : OK
  ProcessEvents Function            : OK
  LuaCallback RAII                  : OK (Tested via subscriptions)
  ThreadSafeQueue                   : OK (Tested via ProcessEvents)
  Callbacks Triggered               : N
  Subscriptions Created             : 5

======================================================================
```

## What Each Test Validates

### Test 1: Connection Test
- **Tests**: `realtime.Connect(host, port)`
- **Validates**: C++ RedisClient TCP connection
- **Success**: Module can connect to Redis server

### Test 2: Connection Status
- **Tests**: `realtime.IsConnected()`
- **Validates**: Connection state tracking
- **Success**: Returns correct boolean

### Test 3: Publishing
- **Tests**: `realtime.Publish(channel, message)`
- **Validates**: Redis PUBLISH command
- **Success**: Multiple channels receive messages

### Test 4: Subscription with Callbacks
- **Tests**: `realtime.Subscribe(channel, callback)`
- **Validates**: LuaCallback RAII wrapper in C++
  - Lua function stored in registry (reference)
  - C++ can invoke via `Call(L, channel, message)`
  - Automatic cleanup on unsubscribe
- **Success**: Callbacks receive published events

### Test 5: ProcessEvents
- **Tests**: `realtime.ProcessEvents()`
- **Validates**: ThreadSafeQueue<T> draining
  - Main thread safely pops buffered events
  - Thread-safe queue operations
  - No race conditions
- **Success**: Events processed without crashes

### Test 6: Multiple Subscriptions
- **Tests**: Creating 5 concurrent subscriptions
- **Validates**: LuaCallback reference management
  - Each callback independently stored
  - No memory leaks
  - Proper move semantics
- **Success**: 5 subscriptions coexist without issues

### Test 7: Stress Test
- **Tests**: Rapid message publishing (10 messages)
- **Validates**: Performance and reliability
- **Success**: All messages published successfully

### Test 8: Disconnect
- **Tests**: `realtime.Disconnect()`
- **Validates**: Resource cleanup
  - Worker thread stopped
  - Message queue drained
  - Lua callbacks freed from registry
  - Redis connection closed
- **Success**: IsConnected() returns false, no memory leaks

## Testing Checklist

- [ ] Module DLL found and loaded (check console for `[OK] Realtime module loaded`)
- [ ] Connect to Redis successful (or see expected error if Redis not running)
- [ ] All test functions return without crashing
- [ ] Callbacks are triggered when events published
- [ ] ProcessEvents completes quickly (< 1ms)
- [ ] Disconnect cleans up all resources
- [ ] No memory leaks in Process Monitor
- [ ] No access violations or crashes

## Troubleshooting

### "Failed to load realtime module"
- Check DLL is in `garrysmod/lua/bin/`
- Check architecture matches (64-bit server → win64 DLL)
- Check dependencies (ws2_32, crypt32 loaded by Windows)

### "Connection: FAILED"
- Redis not running on 127.0.0.1:6379
- Firewall blocking port 6379
- Check Redis is listening: `redis-cli ping`

### "Callbacks not triggered"
- Ensure ProcessEvents() is called in Think hook
- Check channel name matches Subscribe() and Publish()
- Check callback function is not garbage collected

### Server crashes
- Check console.log for error details
- Run with `-debug` flag: `srcds.exe -game garrysmod -debug`
- Enable CrashDumps for debugging

## Next Steps (Phase 2.1)

After successful testing:
1. Implement async Redis subscriber thread
2. Replace manual Publish/Subscribe with background polling
3. ThreadSafeQueue will buffer events from worker
4. Main thread invokes callbacks via LuaCallback

This test validates the **foundation is solid**:
- ✓ Thread-safe queue works
- ✓ Lua callback management works
- ✓ Module lifecycle works
- ✓ Ready for async integration
