-- POC Realtime Module Test - Vehicle Spawn Tracking with .on() events
-- Place this file in your GMod server's lua/autorun/server directory
-- DLL must be in: garrysmod/lua/bin/gmsv_realtime_win64.dll or gmsv_realtime_win32.dll

if SERVER then
    print("=== Realtime Vehicle Tracking POC (Event System) ===")
    
    -- Detect architecture
    local arch = (jit.arch == "x64" and "64" or "32")
    print("[INFO] Detected architecture: " .. arch .. "-bit")
    print("[INFO] Loading module: realtime")
    
    -- Load the binary module
    local ok, err = pcall(require, "realtime")
    
    if not ok then
        print("[ERROR] Failed to load realtime module")
        print("[INFO] Make sure gmsv_realtime_win" .. arch .. ".dll is in garrysmod/lua/bin/")
        print("[ERROR] Details: " .. tostring(err))
        return
    end
    
    if not realtime then
        print("[ERROR] Module loaded but 'realtime' table not found")
        return
    end
    
    print("[OK] Realtime module loaded successfully")
    print("[OK] Available functions:")
    print("     - Connect(host, port)")
    print("     - Disconnect()")
    print("     - IsConnected()")
    print("     - Publish(channel, message)")
    print("     - On(channel, callback) - Event subscription")
    print("     - Off(channel) - Unsubscribe")
    print("     - Emit(channel, message) - Test events")
    print("     - PublishPlayerAction(name, action, details)")
    print("     - PublishPlayerKill(killer, victim, weapon)")
    print("     - PublishVehicleSpawned(player, class, model, x, y, z)")
    print("     - PublishVehicleRemoved(player, class, reason)")
    
    -- Connect to Redis
    local connected = realtime.Connect("127.0.0.1", 6379)
    
    if connected then
        print("[OK] Connected to Redis at 127.0.0.1:6379")
        print("[INFO] Event system is now active!")
        
        -- ========== SUBSCRIBE TO EVENTS USING .on() ==========
        
        -- Listen for vehicle spawned events
        realtime.On("vehicle:spawned", function(channel, message)
            print("[EVENT] Vehicle spawned: " .. message)
        end)
        
        -- Listen for vehicle removed events
        realtime.On("vehicle:removed", function(channel, message)
            print("[EVENT] Vehicle removed: " .. message)
        end)
        
        -- Listen for player kills
        realtime.On("player:kills", function(channel, message)
            print("[EVENT] Kill registered: " .. message)
        end)
        
        -- Listen for player actions
        realtime.On("player:actions", function(channel, message)
            print("[EVENT] Player action: " .. message)
        end)
        
        -- Listen for special Etoile_Bleue death events
        realtime.On("special:etoile_death", function(channel, message)
            print("\n" .. string.rep("=", 60))
            print("[SPECIAL EVENT] " .. message)
            print(string.rep("=", 60) .. "\n")
            
            -- Notify all players via chat
            for _, ply in ipairs(player.GetAll()) do
                ply:ChatPrint(message)
            end
        end)
        
        print("[OK] Event listeners registered:")
        print("     - vehicle:spawned")
        print("     - vehicle:removed")
        print("     - player:kills")
        print("     - player:actions")
        print("     - special:etoile_death")
        
        -- ========== TRACK VEHICLE SPAWNS ==========
        
        hook.Add("PlayerSpawnedVehicle", "RealtimeVehicleTracking", function(ply, vehicle)
            if not IsValid(ply) or not IsValid(vehicle) then return end
            
            local player_name = ply:Nick()
            local vehicle_class = vehicle:GetClass()
            local vehicle_model = vehicle:GetModel()
            local pos = vehicle:GetPos()
            
            -- Publish vehicle spawn event to Redis
            local success = realtime.PublishVehicleSpawned(
                player_name,
                vehicle_class,
                vehicle_model,
                pos.x, pos.y, pos.z
            )
            
            if success then
                print(string.format("[VEHICLE] %s spawned %s at (%.0f, %.0f, %.0f)", 
                    player_name, vehicle_class, pos.x, pos.y, pos.z))
            end
        end)
        
        -- ========== TRACK VEHICLE REMOVAL ==========
        
        hook.Add("EntityRemoved", "RealtimeVehicleRemoval", function(ent)
            if not IsValid(ent) or not ent:IsVehicle() then return end
            
            local owner = ent:GetOwner()
            if not IsValid(owner) then return end
            
            local player_name = owner:Nick()
            local vehicle_class = ent:GetClass()
            
            realtime.PublishVehicleRemoved(player_name, vehicle_class, "removed")
            print(string.format("[VEHICLE] %s's %s was removed", player_name, vehicle_class))
        end)
        
        -- ========== TRACK PLAYER KILLS ==========
        
        hook.Add("PlayerDeath", "RealtimeKillTracking", function(victim, inflictor, attacker)
            if IsValid(attacker) and attacker:IsPlayer() and IsValid(victim) then
                local weapon = "unknown"
                if IsValid(inflictor) and inflictor:IsWeapon() then
                    weapon = inflictor:GetClass()
                end
                
                -- Publish kill event
                realtime.PublishPlayerKill(attacker:Nick(), victim:Nick(), weapon)
                print(string.format("[KILL] %s killed %s with %s", 
                    attacker:Nick(), victim:Nick(), weapon))
                
                -- ✅ Special handling for Etoile_Bleue
                if victim:Nick() == "Etoile_Bleue" then
                    local msg = "🔴 " .. attacker:Nick() .. " a tué ETOILE_BLEUE avec " .. weapon .. "!"
                    
                    -- Publish to special event channel
                    -- This will trigger the .on() handler registered above
                    realtime.Publish("special:etoile_death", msg)
                end
            end
        end)
        
        -- ========== TEST: Simulate events after delay ==========
        
        timer.Simple(3, function()
            print("\n[TEST] Simulating vehicle spawn event...")
            realtime.PublishVehicleSpawned("TestPlayer", "prop_vehicle_jeep", "models/buggy.mdl", 0, 0, 100)
            print("[TEST] Check your Redis subscriber to see the message!\n")
        end)
        
        timer.Simple(6, function()
            print("\n[TEST] Simulating kill event...")
            realtime.PublishPlayerKill("Attacker", "Victim", "weapon_crowbar")
            print("[TEST] This event was published via .On() listener!\n")
        end)
        
    else
        print("[ERROR] Failed to connect to Redis")
        print("[INFO] Make sure Redis server is running on 127.0.0.1:6379")
        print("[INFO] You can start Redis with: redis-server")
    end
    
    -- ========== CLEANUP ON SERVER SHUTDOWN ==========
    
    hook.Add("ShutDown", "RealtimeCleanup", function()
        print("[SHUTDOWN] Cleaning up realtime module...")
        if realtime and realtime.IsConnected() then
            realtime.Off("vehicle:spawned")
            realtime.Off("vehicle:removed")
            realtime.Off("player:kills")
            realtime.Off("player:actions")
            realtime.Off("special:etoile_death")
            realtime.Disconnect()
        end
    end)
    
    -- ========== CONSOLE COMMANDS FOR TESTING ==========
    
    concommand.Add("realtime_test_vehicle", function(ply, cmd, args)
        if not realtime or not realtime.IsConnected() then 
            print("[ERROR] Realtime module not connected")
            return 
        end
        
        local player_name = IsValid(ply) and ply:Nick() or "Console"
        realtime.PublishVehicleSpawned(player_name, "prop_vehicle_airboat", "models/airboat.mdl", 0, 0, 50)
        print("[TEST] Vehicle spawn event sent to Redis and published via .on()")
    end)
    
    concommand.Add("realtime_test_kill", function(ply, cmd, args)
        if not realtime or not realtime.IsConnected() then 
            print("[ERROR] Realtime module not connected")
            return 
        end
        
        realtime.PublishPlayerKill("Attacker", "Victim", "weapon_crowbar")
        print("[TEST] Kill event sent to Redis and published via .on()")
    end)
    
    concommand.Add("realtime_test_action", function(ply, cmd, args)
        if not realtime or not realtime.IsConnected() then 
            print("[ERROR] Realtime module not connected")
            return 
        end
        
        realtime.PublishPlayerAction("TestPlayer", "spawn", "spawned at map start")
        print("[TEST] Player action sent to Redis and published via .on()")
    end)
    
    concommand.Add("realtime_test_emit", function(ply, cmd, args)
        if not realtime or not realtime.IsConnected() then 
            print("[ERROR] Realtime module not connected")
            return 
        end
        
        realtime.Emit("test:channel", "Hello from custom event!")
        print("[TEST] Custom event emitted and published via .on()")
    end)
    
    print("\n[INFO] Console commands available:")
    print("  - realtime_test_vehicle  : Test vehicle spawn event")
    print("  - realtime_test_kill     : Test kill event")
    print("  - realtime_test_action   : Test player action event")
    print("  - realtime_test_emit     : Test custom event emission")
    print("\n[INFO] To monitor events in Redis CLI, run:")
    print("  redis-cli SUBSCRIBE vehicle:spawned vehicle:removed player:kills player:actions special:etoile_death")
    print()
    
end
