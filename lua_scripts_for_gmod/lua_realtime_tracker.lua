-- ============================================================================
-- PURE LUA VEHICLE TRACKING - CLASSIC DEVELOPER APPROACH
-- ============================================================================
-- This is how a typical Lua developer would implement vehicle tracking
-- WITHOUT any fancy C++ module
--
-- Approach:
-- 1. Store vehicles in a table
-- 2. Poll them every frame (Think hook)
-- 3. Detect changes manually
-- 4. Print events in real-time to console
--
-- Place in: garrysmod/lua/autorun/server/lua_realtime_tracker.lua
-- ============================================================================

if not SERVER then return end

print("\n" .. string.rep("=", 80))
print("  PURE LUA REALTIME VEHICLE TRACKER - CLASSIC APPROACH")
print("  (How a normal Lua dev would do it)")
print(string.rep("=", 80) .. "\n")

-- ============================================================================
-- GLOBAL STATE
-- ============================================================================

local TRACKER = {
    -- Current vehicles being tracked
    vehicles = {},           -- {ent:EntIndex() = {data}}
    
    -- Performance metrics
    stats = {
        total_spawned = 0,
        total_removed = 0,
        total_polled = 0,
        total_updates = 0,
        last_check_time = 0,
    },
    
    -- Performance tracking
    perf = {
        poll_calls = 0,
        avg_check_ms = 0,
        max_check_ms = 0,
        total_check_ms = 0,
    }
}

-- ============================================================================
-- HELPER: Serialize vehicle to JSON (like C++ version does)
-- ============================================================================

local function VehicleToJSON(ent, action)
    local pos = ent:GetPos()
    local ang = ent:GetAngles()
    
    local json = "{"
    json = json .. '"action":"' .. action .. '"'
    json = json .. ',"vehicle_id":' .. ent:EntIndex()
    json = json .. ',"vehicle_class":"' .. ent:GetClass() .. '"'
    json = json .. ',"model":"' .. ent:GetModel() .. '"'
    json = json .. ',"position":{'
        json = json .. '"x":' .. math.floor(pos.x)
        json = json .. ',"y":' .. math.floor(pos.y)
        json = json .. ',"z":' .. math.floor(pos.z)
    json = json .. '}'
    json = json .. ',"angles":{'
        json = json .. '"p":' .. math.floor(ang.p)
        json = json .. ',"y":' .. math.floor(ang.y)
        json = json .. ',"r":' .. math.floor(ang.r)
    json = json .. '}'
    json = json .. ',"health":' .. ent:Health()
    json = json .. ',"timestamp":' .. os.time()
    json = json .. "}"
    
    return json
end

-- ============================================================================
-- POLL VEHICLES - Main tracking logic
-- ============================================================================

local function PollVehicles()
    local start_time = SysTime()
    local check_count = 0
    
    -- Check all entities in the world (INEFFICIENT - this is why C++ is better!)
    for ent_id, old_data in pairs(TRACKER.vehicles) do
        local ent = Entity(ent_id)
        
        -- Vehicle no longer exists?
        if not IsValid(ent) or not ent:IsVehicle() then
            local json = VehicleToJSON(old_data.last_state, "despawn")
            print("[REALTIME] DESPAWN: " .. old_data.class .. " (#" .. ent_id .. ") - Owner: " .. old_data.owner_name)
            print("  JSON: " .. json)
            
            TRACKER.vehicles[ent_id] = nil
            TRACKER.stats.total_removed = TRACKER.stats.total_removed + 1
            check_count = check_count + 1
            
        else
            -- Vehicle exists - check if it moved
            local new_pos = ent:GetPos()
            local old_pos = old_data.last_position
            
            local distance = math.sqrt(
                (new_pos.x - old_pos.x)^2 + 
                (new_pos.y - old_pos.y)^2 + 
                (new_pos.z - old_pos.z)^2
            )
            
            -- Did it move significantly? (more than 10 units)
            if distance > 10 then
                old_data.last_position = new_pos
                old_data.last_check = SysTime()
                
                local json = VehicleToJSON(ent, "update")
                print("[REALTIME] UPDATE: " .. old_data.class .. " (#" .. ent_id .. ") moved " .. math.floor(distance) .. "u")
                print("  POS: " .. math.floor(new_pos.x) .. ", " .. math.floor(new_pos.y) .. ", " .. math.floor(new_pos.z))
                
                TRACKER.stats.total_updates = TRACKER.stats.total_updates + 1
                check_count = check_count + 1
            end
        end
    end
    
    local elapsed_ms = (SysTime() - start_time) * 1000
    
    TRACKER.perf.poll_calls = TRACKER.perf.poll_calls + 1
    TRACKER.perf.total_check_ms = TRACKER.perf.total_check_ms + elapsed_ms
    
    if elapsed_ms > TRACKER.perf.max_check_ms then
        TRACKER.perf.max_check_ms = elapsed_ms
    end
    
    TRACKER.perf.avg_check_ms = TRACKER.perf.total_check_ms / TRACKER.perf.poll_calls
    TRACKER.stats.total_polled = TRACKER.stats.total_polled + check_count
    
    return check_count, elapsed_ms
end

-- ============================================================================
-- HOOK: Detect new vehicle spawns
-- ============================================================================

hook.Add("PlayerSpawnedVehicle", "LuaRealtimeSpawn", function(ply, vehicle)
    if not IsValid(ply) or not IsValid(vehicle) then return end
    
    local ent_id = vehicle:EntIndex()
    local pos = vehicle:GetPos()
    
    TRACKER.vehicles[ent_id] = {
        owner = ply,
        owner_name = ply:Nick(),
        class = vehicle:GetClass(),
        model = vehicle:GetModel(),
        first_position = pos,
        last_position = pos,
        last_check = SysTime(),
        last_state = vehicle,
    }
    
    TRACKER.stats.total_spawned = TRACKER.stats.total_spawned + 1
    
    local json = VehicleToJSON(vehicle, "spawn")
    print("[REALTIME] SPAWN: " .. vehicle:GetClass() .. " (#" .. ent_id .. ") - Owner: " .. ply:Nick())
    print("  JSON: " .. json)
end)

-- ============================================================================
-- HOOK: Main polling loop (runs every frame)
-- ============================================================================

local last_full_scan = 0
local poll_interval = 0.05  -- Poll every 50ms

hook.Add("Think", "LuaRealtimePolling", function()
    local now = SysTime()
    
    -- Poll vehicles at interval
    if (now - last_full_scan) >= poll_interval then
        last_full_scan = now
        PollVehicles()
    end
end)

-- ============================================================================
-- CONSOLE COMMAND: Show stats
-- ============================================================================

concommand.Add("lua_tracker_stats", function(ply, cmd, args)
    print("\n" .. string.rep("=", 80))
    print("  PURE LUA TRACKER - STATISTICS")
    print(string.rep("=", 80))
    
    print("\n[EVENTS]")
    print("  Total spawned: " .. TRACKER.stats.total_spawned)
    print("  Total removed: " .. TRACKER.stats.total_removed)
    print("  Total updates detected: " .. TRACKER.stats.total_updates)
    print("  Total checks performed: " .. TRACKER.stats.total_polled)
    
    print("\n[ACTIVE VEHICLES]")
    print("  Currently tracked: " .. table.Count(TRACKER.vehicles))
    
    local idx = 0
    for ent_id, data in pairs(TRACKER.vehicles) do
        if IsValid(data.owner) then
            idx = idx + 1
            print(string.format("    [%d] %s (owner: %s)", ent_id, data.class, data.owner_name))
        end
    end
    
    print("\n[PERFORMANCE METRICS]")
    print(string.format("  Poll calls: %d", TRACKER.perf.poll_calls))
    print(string.format("  Avg check time: %.3f ms", TRACKER.perf.avg_check_ms))
    print(string.format("  Max check time: %.3f ms", TRACKER.perf.max_check_ms))
    print(string.format("  Total check time: %.2f ms", TRACKER.perf.total_check_ms))
    
    print("\n[POLLING INFO]")
    print("  Interval: 50ms (20 polls/second)")
    print("  Method: Full table iteration + manual distance check")
    print("  Update threshold: 10 units")
    
    print("\n" .. string.rep("=", 80) .. "\n")
end, nil, "Show Lua tracker statistics")

-- ============================================================================
-- CONSOLE COMMAND: List vehicles
-- ============================================================================

concommand.Add("lua_tracker_list", function(ply, cmd, args)
    print("\n" .. string.rep("=", 80))
    print("  TRACKED VEHICLES")
    print(string.rep("=", 80))
    
    if table.Count(TRACKER.vehicles) == 0 then
        print("  (none)\n")
        return
    end
    
    local idx = 1
    for ent_id, data in pairs(TRACKER.vehicles) do
        local ent = Entity(ent_id)
        if IsValid(ent) then
            local pos = ent:GetPos()
            print(string.format(
                "\n[%d] %s (#%d)",
                idx, data.class, ent_id
            ))
            print(string.format(
                "  Owner: %s",
                data.owner_name
            ))
            print(string.format(
                "  Position: %.0f, %.0f, %.0f",
                pos.x, pos.y, pos.z
            ))
            print(string.format(
                "  Model: %s",
                data.model
            ))
            idx = idx + 1
        end
    end
    
    print("\n" .. string.rep("=", 80) .. "\n")
end, nil, "List all tracked vehicles")

-- ============================================================================
-- CONSOLE COMMAND: Clear tracking
-- ============================================================================

concommand.Add("lua_tracker_clear", function(ply, cmd, args)
    TRACKER.vehicles = {}
    TRACKER.stats = {
        total_spawned = 0,
        total_removed = 0,
        total_polled = 0,
        total_updates = 0,
    }
    TRACKER.perf = {
        poll_calls = 0,
        avg_check_ms = 0,
        max_check_ms = 0,
        total_check_ms = 0,
    }
    print("[OK] Lua tracker cleared")
end, nil, "Clear all tracking data")

-- ============================================================================
-- CONSOLE COMMAND: Stress test
-- ============================================================================

concommand.Add("lua_tracker_stress", function(ply, cmd, args)
    print("\n" .. string.rep("=", 80))
    print("  LUA TRACKER - STRESS TEST")
    print(string.rep("=", 80))
    
    local player = player.GetHumans()[1]
    if not player then player = ply end
    
    if not IsValid(player) then
        print("No players online!\n")
        return
    end
    
    print("\nSpawning 10 vehicles...")
    
    local spawn_pos = player:GetPos() + player:GetForward() * 500
    local vehicles_spawned = 0
    
    for i = 1, 10 do
        local ent = ents.Create("prop_vehicle_jeep")
        if ent then
            ent:SetPos(spawn_pos + Vector(i * 200, 0, 0))
            ent:SetAngles(Angle(0, 0, 0))
            ent:Spawn()
            ent:SetOwner(player)
            vehicles_spawned = vehicles_spawned + 1
            
            -- Manually trigger spawn hook for testing
            hook.Call("PlayerSpawnedVehicle", nil, player, ent)
        end
    end
    
    print("Spawned: " .. vehicles_spawned .. " vehicles")
    print("\nWaiting for polling...\n")
    print("Watch the console - you should see SPAWN, UPDATE, and DESPAWN events")
    print("Type 'lua_tracker_stats' to see performance metrics\n")
    
    print(string.rep("=", 80) .. "\n")
end, nil, "Spawn vehicles and test tracking")

-- ============================================================================
-- STARTUP MESSAGE
-- ============================================================================

print("[OK] Pure Lua realtime tracker loaded")
print("[INFO] Available commands:")
print("  lua_tracker_stats   - Show statistics and performance metrics")
print("  lua_tracker_list    - List all tracked vehicles")
print("  lua_tracker_clear   - Clear all tracking data")
print("  lua_tracker_stress  - Spawn vehicles for stress testing")
print("\n[INFO] Real-time console output:")
print("  SPAWN   - When a vehicle is created")
print("  UPDATE  - When a vehicle moves >10 units")
print("  DESPAWN - When a vehicle is removed")
print("\n" .. string.rep("=", 80) .. "\n")