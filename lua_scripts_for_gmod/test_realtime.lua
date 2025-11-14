-- POC Realtime Module Test - Vehicle Spawn Tracking
-- Place this file in your GMod server's lua/autorun/server directory
-- DLL must be in: garrysmod/lua/bin/gmsv_realtime_win64.dll or gmsv_realtime_win32.dll

if SERVER then
    print("=== Realtime Vehicle Tracking POC ===")
    
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
    print("[OK] Available functions: Connect, Publish, Subscribe, Disconnect")
    print("[OK] POC functions: PlayerAction, PlayerKill, VehicleSpawned, VehicleRemoved")
    
    -- Connect to Redis
    local connected = realtime.Connect("127.0.0.1", 6379)
    
    if connected then
        print("[OK] Connected to Redis at 127.0.0.1:6379")
        print("[INFO] Vehicle spawn tracking is now active!")
        
        -- Track vehicle spawns
        hook.Add("PlayerSpawnedVehicle", "RealtimeVehicleTracking", function(ply, vehicle)
            if not IsValid(ply) or not IsValid(vehicle) then return end
            
            local player_name = ply:Nick()
            local vehicle_class = vehicle:GetClass()
            local vehicle_model = vehicle:GetModel()
            local pos = vehicle:GetPos()
            
            -- Send to Redis
            local success = realtime.VehicleSpawned(
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
        
        -- Track vehicle removal
        hook.Add("EntityRemoved", "RealtimeVehicleRemoval", function(ent)
            if not IsValid(ent) or not ent:IsVehicle() then return end
            
            local owner = ent:GetOwner()
            if not IsValid(owner) then return end
            
            local player_name = owner:Nick()
            local vehicle_class = ent:GetClass()
            
            realtime.VehicleRemoved(player_name, vehicle_class, "removed")
            print(string.format("[VEHICLE] %s's %s was removed", player_name, vehicle_class))
        end)
        
        -- Track player kills (bonus)
        hook.Add("PlayerDeath", "RealtimeKillTracking", function(victim, inflictor, attacker)
            if IsValid(attacker) and attacker:IsPlayer() and IsValid(victim) then
                local weapon = "unknown"
                if IsValid(inflictor) and inflictor:IsWeapon() then
                    weapon = inflictor:GetClass()
                end
                
                realtime.PlayerKill(attacker:Nick(), victim:Nick(), weapon)
                print(string.format("[KILL] %s killed %s with %s", 
                    attacker:Nick(), victim:Nick(), weapon))
                
                -- ✅ Si c'est Etoile_Bleue qui meurt, affiche un message dans le chat
                if victim:Nick() == "Etoile_Bleue" then
                    local msg = "🔴 " .. attacker:Nick() .. " a tué ETOILE_BLEUE avec " .. weapon .. "!"
                    
                    -- Envoie le message à TOUS les joueurs
                    for _, ply in ipairs(player.GetAll()) do
                        ply:ChatPrint(msg)
                    end
                    
                    print("\n" .. string.rep("=", 50))
                    print("[DEATH] " .. msg)
                    print(string.rep("=", 50) .. "\n")
                    
                    -- ✅ Envoyer à Redis aussi
                    realtime.Publish("special:etoile_death", msg)
                end
            end
        end)
        
        -- Subscribe to vehicle events from other servers
        realtime.Subscribe("vehicle:spawned")
        realtime.Subscribe("vehicle:removed")
        print("[OK] Subscribed to vehicle:spawned and vehicle:removed channels")
        
        -- Test: Spawn a vehicle after 3 seconds
        timer.Simple(3, function()
            print("\n[TEST] Simulating vehicle spawn event...")
            realtime.VehicleSpawned("TestPlayer", "prop_vehicle_jeep", "models/buggy.mdl", 0, 0, 100)
            print("[TEST] Check your Redis subscriber to see the message!\n")
        end)
        
    else
        print("[ERROR] Failed to connect to Redis")
        print("[INFO] Make sure Redis server is running on 127.0.0.1:6379")
        print("[INFO] You can start Redis with: redis-server")
    end
    
    -- Cleanup on server shutdown
    hook.Add("ShutDown", "RealtimeCleanup", function()
        print("[SHUTDOWN] Cleaning up realtime module...")
        if realtime then
            realtime.Disconnect()
        end
    end)
    
    -- Console commands for testing
    concommand.Add("realtime_test_vehicle", function(ply, cmd, args)
        if not realtime then 
            print("[ERROR] Realtime module not loaded")
            return 
        end
        
        local player_name = IsValid(ply) and ply:Nick() or "Console"
        realtime.VehicleSpawned(player_name, "prop_vehicle_airboat", "models/airboat.mdl", 0, 0, 50)
        print("[TEST] Vehicle spawn event sent to Redis")
    end)
    
    concommand.Add("realtime_test_kill", function(ply, cmd, args)
        if not realtime then 
            print("[ERROR] Realtime module not loaded")
            return 
        end
        
        realtime.PlayerKill("Attacker", "Victim", "weapon_crowbar")
        print("[TEST] Kill event sent to Redis")
    end)
    
    print("\n[INFO] Console commands available:")
    print("  - realtime_test_vehicle : Test vehicle spawn event")
    print("  - realtime_test_kill : Test kill event")
    print("\n[INFO] To monitor events, run in another terminal:")
    print("  redis-cli SUBSCRIBE vehicle:spawned vehicle:removed player:kills")
    
end
