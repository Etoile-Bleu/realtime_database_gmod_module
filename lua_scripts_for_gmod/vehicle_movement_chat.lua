-- ============================================================================
-- REALTIME VEHICLE MOVEMENT TRACKER - Chat Notifications
-- ============================================================================
-- Listens to Redis vehicle update events and displays them in chat
-- Place in: garrysmod/lua/autorun/server/vehicle_movement_chat.lua
--
-- Features:
-- - Real-time vehicle movement detection
-- - Chat notifications with player name, vehicle type, distance, and time
-- - Filters small movements (less than 10 units)
-- - Beautiful formatted output
-- - No polling overhead
-- ============================================================================

if not SERVER then return end

print("\n" .. string.rep("=", 80))
print("  VEHICLE MOVEMENT CHAT TRACKER - Initializing")
print(string.rep("=", 80) .. "\n")

-- Wait for module to load
timer.Simple(2, function()
    if not realtime then
        print("[MOVEMENT TRACKER] Error: realtime module not loaded!")
        return
    end
    
    if not realtime.IsConnected() then
        print("[MOVEMENT TRACKER] Error: Not connected to Redis!")
        print("[MOVEMENT TRACKER] Make sure Redis is running and module is connected")
        return
    end
    
    print("[MOVEMENT TRACKER] ✓ Module loaded and connected to Redis")
    
    -- ============================================================================
    -- CONFIGURATION
    -- ============================================================================
    
    local CONFIG = {
        min_distance = 10,              -- Only report movements > 10 units
        max_distance = 50000,           -- Ignore teleports (> 50km away)
        update_threshold = 20,          -- Only report every 20 units moved
        enable_chat = true,             -- Enable chat messages
        enable_console = true,          -- Enable console output
        vehicle_types = {
            ["prop_vehicle_jeep"] = "Jeep",
            ["prop_vehicle_airboat"] = "Airboat",
            ["prop_vehicle_alyx_jeep"] = "Alyx Jeep",
            ["prop_vehicle_prisoner_pod"] = "Pod",
        }
    }
    
    -- Movement tracking state
    local LAST_POSITIONS = {}           -- Cache last known position
    local LAST_NOTIFICATIONS = {}       -- Cache last notification time per vehicle
    local MOVEMENT_STATS = {
        total_events = 0,
        total_movements = 0,
        total_teleports = 0,
        total_distance = 0,
    }
    
    -- ============================================================================
    -- HELPER FUNCTIONS
    -- ============================================================================
    
    local function GetVehicleTypeName(class)
        return CONFIG.vehicle_types[class] or class
    end
    
    local function FormatDistance(distance)
        if distance < 100 then
            return math.floor(distance) .. "u"
        elseif distance < 1000 then
            return string.format("%.1f", distance / 100) .. "00u"
        else
            return string.format("%.0fk", distance / 1000) .. "u"
        end
    end
    
    local function GetTimeString()
        return os.date("%H:%M:%S")
    end
    
    local function SanitizePlayerName(name)
        -- Remove color codes and special characters from player names
        name = string.gsub(name, "%^%d", "")  -- Remove GMod color codes (^1, ^2, etc.)
        name = string.gsub(name, "[^%w%s%-%_]", "")  -- Remove special chars
        return string.sub(name, 1, 32)  -- Limit to 32 chars
    end
    
    local function PrintConsole(msg)
        if CONFIG.enable_console then
            print("[MOVEMENT] " .. msg)
        end
    end
    
    local function PrintChat(msg)
        if CONFIG.enable_chat then
            -- Broadcast to all players using PrintMessage (works better)
            PrintMessage(HUD_PRINTTALK, msg)
            -- Also print to server console
            print("[CHAT] " .. msg)
        end
    end
    
    -- ============================================================================
    -- SUBSCRIBE TO VEHICLE UPDATE EVENTS
    -- ============================================================================
    
    print("[MOVEMENT TRACKER] Subscribing to vehicle:update channel...")
    
    local subscription = realtime.Subscribe("vehicles:update", function(channel, message)
        PrintConsole("[DEBUG] Received update event!")
        
        -- Decode JSON event
        local event = util.JSONToTable(message)
        
        if not event then
            PrintConsole("Failed to decode event: " .. message)
            return
        end
        
        PrintConsole("[DEBUG] Decoded event: vehicle_id=" .. (event.vehicle_id or "?") .. ", owner=" .. (event.owner_name or "?"))
        
        MOVEMENT_STATS.total_events = MOVEMENT_STATS.total_events + 1
        
        -- Extract data
        local vehicle_id = event.vehicle_id
        local owner_id = event.owner_id
        local owner_name = SanitizePlayerName(event.owner_name or "Unknown")
        local vehicle_class = event.vehicle_class or "Unknown"
        local vehicle_type = GetVehicleTypeName(vehicle_class)
        local new_pos = Vector(event.position.x, event.position.y, event.position.z)
        local timestamp = GetTimeString()
        
        -- Get or create last position cache
        if not LAST_POSITIONS[vehicle_id] then
            LAST_POSITIONS[vehicle_id] = {
                pos = new_pos,
                owner = owner_name,
                type = vehicle_type,
                last_notify = 0,
            }
            return  -- First time seeing this vehicle, skip notification
        end
        
        local cache = LAST_POSITIONS[vehicle_id]
        local old_pos = cache.pos
        
        -- Calculate distance
        local distance = math.sqrt(
            (new_pos.x - old_pos.x)^2 + 
            (new_pos.y - old_pos.y)^2 + 
            (new_pos.z - old_pos.z)^2
        )
        
        -- Ignore tiny movements
        if distance < CONFIG.min_distance then
            cache.pos = new_pos
            return
        end
        
        -- Detect teleports (ignore them)
        if distance > CONFIG.max_distance then
            PrintConsole("Teleport detected: " .. owner_name .. " / " .. vehicle_type .. " (" .. FormatDistance(distance) .. ")")
            MOVEMENT_STATS.total_teleports = MOVEMENT_STATS.total_teleports + 1
            cache.pos = new_pos
            return
        end
        
        -- Update cache
        cache.pos = new_pos
        cache.owner = owner_name
        cache.type = vehicle_type
        
        -- Check if enough time passed since last notification (debounce)
        local now = SysTime()
        if not LAST_NOTIFICATIONS[vehicle_id] then
            LAST_NOTIFICATIONS[vehicle_id] = now
        end
        
        -- Send notification
        MOVEMENT_STATS.total_movements = MOVEMENT_STATS.total_movements + 1
        MOVEMENT_STATS.total_distance = MOVEMENT_STATS.total_distance + distance
        
        local formatted_distance = FormatDistance(distance)
        local message = string.format(
            "%s déplace un %s de %s [%s]",
            owner_name,
            vehicle_type,
            formatted_distance,
            timestamp
        )
        
        PrintChat(message)
        PrintConsole(message .. " (ID: " .. vehicle_id .. ")")
        
        LAST_NOTIFICATIONS[vehicle_id] = now
    end)
    
    if subscription then
        print("[MOVEMENT TRACKER] ✓ Successfully subscribed to vehicle:update")
    else
        print("[MOVEMENT TRACKER] ✗ Failed to subscribe!")
        return
    end
    
    -- ============================================================================
    -- PROCESS EVENTS HOOK
    -- ============================================================================
    
    hook.Add("Think", "MovementTrackerProcessEvents", function()
        if realtime and realtime.ProcessEvents then
            realtime.ProcessEvents()
        end
    end)
    
    -- ============================================================================
    -- CONSOLE COMMANDS
    -- ============================================================================
    
    concommand.Add("vehicle_movement_stats", function(ply, cmd, args)
        print("\n" .. string.rep("=", 80))
        print("  VEHICLE MOVEMENT TRACKER - STATISTICS")
        print(string.rep("=", 80))
        
        print("\n[EVENTS]")
        print("  Total update events received: " .. MOVEMENT_STATS.total_events)
        print("  Total movements detected: " .. MOVEMENT_STATS.total_movements)
        print("  Total teleports ignored: " .. MOVEMENT_STATS.total_teleports)
        
        print("\n[DISTANCE]")
        print(string.format(
            "  Total distance tracked: %s",
            FormatDistance(MOVEMENT_STATS.total_distance)
        ))
        if MOVEMENT_STATS.total_movements > 0 then
            local avg_distance = MOVEMENT_STATS.total_distance / MOVEMENT_STATS.total_movements
            print(string.format(
                "  Average movement: %s",
                FormatDistance(avg_distance)
            ))
        end
        
        print("\n[ACTIVE VEHICLES]")
        print("  Currently tracked: " .. table.Count(LAST_POSITIONS))
        
        local idx = 1
        for vehicle_id, cache in pairs(LAST_POSITIONS) do
            print(string.format(
                "    [%d] Vehicle #%d: %s (Owner: %s)",
                idx, vehicle_id, cache.type, cache.owner
            ))
            idx = idx + 1
        end
        
        print("\n[CONFIGURATION]")
        print("  Min distance threshold: " .. CONFIG.min_distance .. "u")
        print("  Max distance (teleport): " .. CONFIG.max_distance .. "u")
        print("  Chat enabled: " .. (CONFIG.enable_chat and "YES" or "NO"))
        print("  Console enabled: " .. (CONFIG.enable_console and "YES" or "NO"))
        
        print("\n" .. string.rep("=", 80) .. "\n")
    end, nil, "Show vehicle movement statistics")
    
    concommand.Add("vehicle_movement_toggle_chat", function(ply, cmd, args)
        CONFIG.enable_chat = not CONFIG.enable_chat
        print("[MOVEMENT TRACKER] Chat notifications: " .. (CONFIG.enable_chat and "ENABLED" or "DISABLED"))
    end, nil, "Toggle chat notifications")
    
    concommand.Add("vehicle_movement_toggle_console", function(ply, cmd, args)
        CONFIG.enable_console = not CONFIG.enable_console
        print("[MOVEMENT TRACKER] Console output: " .. (CONFIG.enable_console and "ENABLED" or "DISABLED"))
    end, nil, "Toggle console output")
    
    concommand.Add("vehicle_movement_clear", function(ply, cmd, args)
        LAST_POSITIONS = {}
        LAST_NOTIFICATIONS = {}
        MOVEMENT_STATS = {
            total_events = 0,
            total_movements = 0,
            total_teleports = 0,
            total_distance = 0,
        }
        print("[MOVEMENT TRACKER] ✓ All data cleared")
    end, nil, "Clear all tracking data")
    
    -- ============================================================================
    -- STARTUP LOG
    -- ============================================================================
    
    print("[MOVEMENT TRACKER] ✓ Vehicle movement tracker initialized")
    print("[MOVEMENT TRACKER] ✓ Listening for Redis events on 'vehicles:update'")
    print("[MOVEMENT TRACKER] Available commands:")
    print("    - vehicle_movement_stats        : Show statistics")
    print("    - vehicle_movement_toggle_chat  : Toggle chat messages")
    print("    - vehicle_movement_toggle_console : Toggle console output")
    print("    - vehicle_movement_clear        : Clear all data")
    
    print(string.rep("=", 80) .. "\n")
end)
