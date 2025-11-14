-- ============================================================================
-- DIRECT PUB/SUB TEST - Verify callbacks actually trigger
-- ============================================================================
-- Place in: garrysmod/lua/autorun/server/test_pubsub_direct.lua

if not SERVER then return end

-- Wait for module
timer.Simple(2, function()
    if not realtime then
        print("[TEST] Module not loaded!")
        return
    end
    
    print("\n" .. string.rep("=", 80))
    print("  DIRECT PUB/SUB TEST - Callbacks Should Trigger")
    print(string.rep("=", 80) .. "\n")
    
    -- Track callbacks
    local callback_count = 0
    local callback_messages = {}
    
    -- Subscribe FIRST
    print("[1] Creating subscription on 'test_channel'...")
    local sub = realtime.Subscribe("test_channel", function(channel, message)
        callback_count = callback_count + 1
        table.insert(callback_messages, {
            channel = channel,
            message = message,
            time = SysTime()
        })
        print("[CALLBACK] Triggered! Count: " .. callback_count)
        print("  Channel: " .. channel)
        print("  Message: " .. string.sub(message, 1, 60) .. "...")
    end)
    
    if sub then
        print("[✓] Subscription created\n")
    else
        print("[✗] Subscription FAILED\n")
        return
    end
    
    -- Give Redis time to register subscription
    timer.Simple(0.5, function()
        print("[2] Publishing 3 test messages...\n")
        
        local results = {}
        
        -- Publish message 1
        local pub1 = realtime.Publish("test_channel", "Message 1: Hello")
        print("[PUBLISH] Message 1: " .. (pub1 and "SUCCESS" or "FAILED"))
        table.insert(results, pub1)
        
        -- Publish message 2
        local pub2 = realtime.Publish("test_channel", "Message 2: World")
        print("[PUBLISH] Message 2: " .. (pub2 and "SUCCESS" or "FAILED"))
        table.insert(results, pub2)
        
        -- Publish message 3
        local pub3 = realtime.Publish("test_channel", "Message 3: Test Data")
        print("[PUBLISH] Message 3: " .. (pub3 and "SUCCESS" or "FAILED"))
        table.insert(results, pub3)
        
        print()
        
        -- Wait for events to be processed
        timer.Simple(0.2, function()
            print("[3] Processing queued events...\n")
            realtime.ProcessEvents()
            
            timer.Simple(0.1, function()
                print("\n" .. string.rep("=", 80))
                print("  TEST RESULTS")
                print(string.rep("=", 80))
                
                print("\n[PUBLISH RESULTS]")
                print("  Message 1: " .. (results[1] and "✓ Published" or "✗ Failed"))
                print("  Message 2: " .. (results[2] and "✓ Published" or "✗ Failed"))
                print("  Message 3: " .. (results[3] and "✓ Published" or "✗ Failed"))
                
                print("\n[CALLBACK RESULTS]")
                print("  Callbacks triggered: " .. callback_count)
                print("  Messages received: " .. #callback_messages)
                
                if callback_count > 0 then
                    print("\n[MESSAGES]")
                    for i, msg in ipairs(callback_messages) do
                        print(string.format(
                            "  [%d] Channel: %s | Message: %s",
                            i, msg.channel, string.sub(msg.message, 1, 40)
                        ))
                    end
                end
                
                print("\n[STATUS]")
                if callback_count >= 3 then
                    print("  ✅ ALL TESTS PASSED - Pub/Sub working correctly!")
                elseif callback_count > 0 then
                    print("  ⚠️ PARTIAL - Some callbacks triggered but not all")
                else
                    print("  ❌ FAILED - No callbacks triggered (check Redis connection)")
                end
                
                print("\n" .. string.rep("=", 80) .. "\n")
            end)
        end)
    end)
end)

-- Console command to re-run test
concommand.Add("test_pubsub", function()
    print("[TEST] Running direct pub/sub test...")
    timer.Simple(0, function()
        -- Execute same test as above
        if not realtime then
            print("[TEST] Module not loaded!")
            return
        end
        
        local callback_count = 0
        print("\n[TEST] Subscribe to 'manual_test'")
        
        realtime.Subscribe("manual_test", function(ch, msg)
            callback_count = callback_count + 1
            print("[CALLBACK #" .. callback_count .. "] " .. msg)
        end)
        
        timer.Simple(0.2, function()
            print("[TEST] Publishing message...")
            realtime.Publish("manual_test", "Test message at " .. os.date())
            
            timer.Simple(0.1, function()
                print("[TEST] Processing events...")
                realtime.ProcessEvents()
                
                timer.Simple(0.1, function()
                    print("[TEST] Total callbacks: " .. callback_count)
                end)
            end)
        end)
    end)
end, nil, "Run direct pub/sub test")
