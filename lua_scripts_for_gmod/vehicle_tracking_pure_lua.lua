-- Pure Lua Vehicle Tracking System (No Redis, No DLL)
-- Track vehicle spawns exactly like our C++ Redis module
-- Place this file in your GMod server's lua/autorun/server directory

if SERVER then
    print("=== Pure Lua Vehicle Tracking System ===")
    
    -- In-memory storage for tracking
    local vehicle_tracking = {
        spawned_vehicles = {},      -- Currently active vehicles
        events_log = {},            -- Event history
        stats = {
            total_spawned = 0,
            total_removed = 0,
            active_vehicles = 0
        }
    }
    
    -- Store vehicle references with owner info
    local function TrackVehicleSpawn(ply, vehicle)
        if not IsValid(ply) or not IsValid(vehicle) then return end
        
        local vehicle_id = tostring(vehicle)
        local player_name = ply:Nick()
        local vehicle_class = vehicle:GetClass()
        local vehicle_model = vehicle:GetModel()
        local pos = vehicle:GetPos()
        local timestamp = os.time()
        
        -- Store vehicle data
        vehicle_tracking.spawned_vehicles[vehicle_id] = {
            entity = vehicle,
            player = ply,
            player_name = player_name,
            vehicle_class = vehicle_class,
            model = vehicle_model,
            position = {x = pos.x, y = pos.y, z = pos.z},
            spawned_at = timestamp
        }
        
        -- Log event
        table.insert(vehicle_tracking.events_log, {
            type = "spawned",
            player = player_name,
            vehicle_class = vehicle_class,
            model = vehicle_model,
            position = {x = pos.x, y = pos.y, z = pos.z},
            timestamp = timestamp
        })
        
        -- Update stats
        vehicle_tracking.stats.total_spawned = vehicle_tracking.stats.total_spawned + 1
        vehicle_tracking.stats.active_vehicles = table.Count(vehicle_tracking.spawned_vehicles)
        
        print(string.format("[VEHICLE] %s spawned %s at (%.0f, %.0f, %.0f)", 
            player_name, vehicle_class, pos.x, pos.y, pos.z))
    end
    
    -- Remove vehicle from tracking
    local function TrackVehicleRemoval(vehicle)
        if not IsValid(vehicle) then return end
        
        local vehicle_id = tostring(vehicle)
        local data = vehicle_tracking.spawned_vehicles[vehicle_id]
        
        if not data then return end
        
        local timestamp = os.time()
        
        -- Log removal event
        table.insert(vehicle_tracking.events_log, {
            type = "removed",
            player = data.player_name,
            vehicle_class = data.vehicle_class,
            duration = timestamp - data.spawned_at,
            timestamp = timestamp
        })
        
        -- Remove from tracking
        vehicle_tracking.spawned_vehicles[vehicle_id] = nil
        
        -- Update stats
        vehicle_tracking.stats.total_removed = vehicle_tracking.stats.total_removed + 1
        vehicle_tracking.stats.active_vehicles = table.Count(vehicle_tracking.spawned_vehicles)
        
        print(string.format("[VEHICLE] %s's %s was removed (duration: %ds)", 
            data.player_name, data.vehicle_class, timestamp - data.spawned_at))
    end
    
    -- Track kills
    local function TrackKill(victim, inflictor, attacker)
        if IsValid(attacker) and attacker:IsPlayer() and IsValid(victim) then
            local weapon = "unknown"
            if IsValid(inflictor) and inflictor:IsWeapon() then
                weapon = inflictor:GetClass()
            end
            
            local timestamp = os.time()
            
            table.insert(vehicle_tracking.events_log, {
                type = "kill",
                killer = attacker:Nick(),
                victim = victim:Nick(),
                weapon = weapon,
                timestamp = timestamp
            })
            
            print(string.format("[KILL] %s killed %s with %s", 
                attacker:Nick(), victim:Nick(), weapon))
        end
    end
    
    -- Hook: Track vehicle spawns
    hook.Add("PlayerSpawnedVehicle", "PureLuaVehicleTracking", function(ply, vehicle)
        TrackVehicleSpawn(ply, vehicle)
    end)
    
    -- Hook: Track vehicle removal
    hook.Add("EntityRemoved", "PureLuaVehicleRemoval", function(ent)
        if IsValid(ent) and ent:IsVehicle() then
            TrackVehicleRemoval(ent)
        end
    end)
    
    -- Hook: Track kills
    hook.Add("PlayerDeath", "PureLuaKillTracking", function(victim, inflictor, attacker)
        TrackKill(victim, inflictor, attacker)
    end)
    
    -- Console command: Get current tracked vehicles
    concommand.Add("vehicle_tracking_list", function(ply, cmd, args)
        print("\n=== Currently Tracked Vehicles ===")
        local count = 0
        for vehicle_id, data in pairs(vehicle_tracking.spawned_vehicles) do
            count = count + 1
            print(string.format(
                "[%d] %s - %s (Model: %s) | Owner: %s | Age: %ds",
                count,
                vehicle_id:sub(1, 8),
                data.vehicle_class,
                data.model,
                data.player_name,
                os.time() - data.spawned_at
            ))
        end
        print(string.format("\nTotal active vehicles: %d\n", count))
    end)
    
    -- Console command: Get stats
    concommand.Add("vehicle_tracking_stats", function(ply, cmd, args)
        print("\n=== Vehicle Tracking Statistics ===")
        print(string.format("Total spawned: %d", vehicle_tracking.stats.total_spawned))
        print(string.format("Total removed: %d", vehicle_tracking.stats.total_removed))
        print(string.format("Currently active: %d", vehicle_tracking.stats.active_vehicles))
        print(string.format("Total events logged: %d\n", table.Count(vehicle_tracking.events_log)))
    end)
    
    -- Console command: View recent events
    concommand.Add("vehicle_tracking_events", function(ply, cmd, args)
        local count = tonumber(args[1]) or 10
        
        print(string.format("\n=== Last %d Events ===", count))
        
        local start_idx = math.max(1, table.Count(vehicle_tracking.events_log) - count + 1)
        for i = start_idx, table.Count(vehicle_tracking.events_log) do
            local event = vehicle_tracking.events_log[i]
            
            if event.type == "spawned" then
                print(string.format("[%s] SPAWN: %s - %s", 
                    os.date("%H:%M:%S", event.timestamp), event.player, event.vehicle_class))
            elseif event.type == "removed" then
                print(string.format("[%s] REMOVE: %s's %s (duration: %ds)", 
                    os.date("%H:%M:%S", event.timestamp), event.player, event.vehicle_class, event.duration))
            elseif event.type == "kill" then
                print(string.format("[%s] KILL: %s killed %s with %s", 
                    os.date("%H:%M:%S", event.timestamp), event.killer, event.victim, event.weapon))
            end
        end
        print()
    end)
    
    -- Console command: Clear logs (memory cleanup)
    concommand.Add("vehicle_tracking_clear", function(ply, cmd, args)
        vehicle_tracking.events_log = {}
        vehicle_tracking.spawned_vehicles = {}
        vehicle_tracking.stats = {
            total_spawned = 0,
            total_removed = 0,
            active_vehicles = 0
        }
        print("[INFO] Vehicle tracking cleared")
    end)
    
    -- Test command
    concommand.Add("vehicle_tracking_test", function(ply, cmd, args)
        if IsValid(ply) then
            -- Simulate vehicle spawn
            table.insert(vehicle_tracking.events_log, {
                type = "spawned",
                player = ply:Nick(),
                vehicle_class = "prop_vehicle_jeep",
                model = "models/buggy.mdl",
                position = {x = 0, y = 0, z = 100},
                timestamp = os.time()
            })
            vehicle_tracking.stats.total_spawned = vehicle_tracking.stats.total_spawned + 1
            print("[TEST] Simulated vehicle spawn")
        end
    end)
    
    -- Memory monitoring
    local last_cleanup = os.time()
    hook.Add("Think", "PureLuaMemoryCleanup", function()
        -- Every 5 minutes, cleanup removed/invalid vehicles
        if os.time() - last_cleanup > 300 then
            local removed_count = 0
            for vehicle_id, data in pairs(vehicle_tracking.spawned_vehicles) do
                if not IsValid(data.entity) then
                    vehicle_tracking.spawned_vehicles[vehicle_id] = nil
                    removed_count = removed_count + 1
                end
            end
            
            -- Keep only last 10000 events to prevent memory overflow
            if table.Count(vehicle_tracking.events_log) > 10000 then
                local new_log = {}
                for i = table.Count(vehicle_tracking.events_log) - 10000 + 1, table.Count(vehicle_tracking.events_log) do
                    table.insert(new_log, vehicle_tracking.events_log[i])
                end
                vehicle_tracking.events_log = new_log
            end
            
            if removed_count > 0 then
                print(string.format("[CLEANUP] Removed %d invalid vehicle references from memory", removed_count))
            end
            
            last_cleanup = os.time()
        end
    end)
    
    -- Cleanup on shutdown
    hook.Add("ShutDown", "PureLuaTrackingCleanup", function()
        print("[SHUTDOWN] Clearing vehicle tracking data...")
        vehicle_tracking.spawned_vehicles = {}
        vehicle_tracking.events_log = {}
    end)
    
    print("[OK] Pure Lua vehicle tracking system loaded")
    print("\n[INFO] Available console commands:")
    print("  - vehicle_tracking_list : List currently tracked vehicles")
    print("  - vehicle_tracking_stats : Show tracking statistics")
    print("  - vehicle_tracking_events [count] : View last N events (default: 10)")
    print("  - vehicle_tracking_clear : Clear all tracking data")
    print("  - vehicle_tracking_test : Simulate a vehicle spawn event\n")
    
end
