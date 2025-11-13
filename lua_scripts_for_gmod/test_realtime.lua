-- POC Realtime Module Test
-- Place this file in your GMod server's lua/autorun/server directory
-- DLL must be in: garrysmod/lua/bin/gmsv_realtime_win64.dll or gmsv_realtime_win32.dll

if SERVER then
    print("=== Realtime Module POC ===")
    
    -- Detect architecture
    -- jit.arch returns "x86" for 32-bit or "x64" for 64-bit
    local arch = (jit.arch == "x64" and "64" or "32")
    local dll_name = "gmsv_realtime_win" .. arch
    
    print("[INFO] Detected architecture: " .. arch .. "-bit")
    print("[INFO] Loading: " .. dll_name .. ".dll")
    
    -- Load the module directly
    local realtime
    local ok, result = pcall(function()
        return require(dll_name)
    end)
    
    if ok and result then
        realtime = result
    else
        print("[ERROR] Failed to load realtime module: " .. dll_name)
        print("[INFO] Make sure " .. dll_name .. ".dll is in garrysmod/lua/bin/")
        print("[ERROR] Details: " .. tostring(result))
        return
    end
    
    print("[OK] Realtime module loaded successfully")
    print("[OK] Available functions: Connect, Publish, Subscribe, Disconnect")
    
    -- Test connection to Redis
    local success = realtime.Connect("127.0.0.1", 6379)
    
    if success then
        print("[OK] Connected to Redis at 127.0.0.1:6379")
    else
        print("[ERROR] Failed to connect to Redis")
        print("[INFO] Make sure Redis server is running on 127.0.0.1:6379")
        return
    end
    
    -- Test subscription with callback
    local channel = "test:channel"
    
    local callback = function(ch, msg)
        print(string.format("[MESSAGE] Channel: %s, Message: %s", ch, msg))
    end
    
    local sub_ok = realtime.Subscribe(channel, callback)
    if sub_ok then
        print(string.format("[OK] Subscribed to channel: %s", channel))
    else
        print(string.format("[ERROR] Failed to subscribe to channel: %s", channel))
    end
    
    -- Test publishing a message
    timer.Simple(1, function()
        local published = realtime.Publish("test:channel", "Hello from GMod!")
        if published then
            print("[OK] Published message to test:channel")
        else
            print("[ERROR] Failed to publish message")
        end
    end)
    
    -- Cleanup on server shutdown
    hook.Add("ShutDown", "RealtimeCleanup", function()
        print("[SHUTDOWN] Cleaning up realtime module...")
        realtime.Disconnect()
    end)
    
end
