-- Zones init

MG_CTF.SaveLocation = "mg_ctf" -- Default save location
MG_CTF.MaxSaveSize = 15 -- Default save size
MG_CTF.MaxSaveSize = 15 -- Default save size

-- Setup of zones

function MG_CTF.SetUp(first)
	print("[MG CTF] Preparing to load capture zones...")

	local map = string.lower(game.GetMap())

	local zones = {}
	for _, name in pairs(file.Find(MG_CTF.SaveLocation.."/"..map.."/*.txt", "DATA")) do
		local config = file.Read(MG_CTF.SaveLocation.."/"..map.."/"..name, "DATA")
		if config then
			local zone = util.JSONToTable(config)
			if zone then
				table.insert(zones, zone)
			end
		end
	end

	local allowed = true
	if !zones then
		allowed = false
		print("[MG CTF] Hurt CTF config file found for map "..map..".")
	end

	if #zones <= 0 then
		allowed = false
		print("[MG CTF] No CTF config file found for map "..map..".")
	end

	if allowed then
		local count = 0

		for _, tab in ipairs(zones) do
			local zone = ents.Create("ctf_area")
			if !IsValid(zone) then return end

			zone.name = tab.name

			zone.capture_team = tab.capture_team

			zone.rewards = tab.rewards
			zone.taken = tab.taken

			zone.custom_data = tab.custom_data or {}

			zone.SaveID = tab.id
			
			zone:Spawn()

			count = count + 1
		end

		print("[MG CTF] Created "..count.." capture zones.")
	end
end

hook.Add("InitPostEntity", "MG_CTF_SetUp", MG_CTF.SetUp)
hook.Add("PostCleanupMap", "MG_CTF_SetUp", MG_CTF.SetUp)

-- Saving of zones

function MG_CTF.Save() -- Save all zones
	local map = string.lower(game.GetMap())

	MG_CTF.DeleteMapData(map)

	local zones = {}
	local cnt = 0
	for _, v in pairs(MG_CTF.CaptureArea) do
		if !IsValid(v) or !v.MainZone or v:IsMarkedForDeletion() then continue end

		local flag_ent = v.FlagEntity
		if !IsValid(flag_ent) then continue end

		local id = v.SaveID

		if !id or id == -1 then continue end

		zones[id] = {
			capture_team = v.CaptureID,
			rewards = v.StashedRewards,
			taken = v.TakenRewards,
			id = id
		}

		local zone = zones[id]

		zone.custom_data = v.custom_data or {}
	
		zone.custom_data.pos = flag_ent:GetPos()
		zone.custom_data.ang = flag_ent:GetAngles()
		zone.custom_data.material = flag_ent:GetMaterial()
		zone.custom_data.name = flag_ent:GetZoneName()
		zone.custom_data.nodraw = flag_ent:GetNoDraw()
		zone.custom_data.not_solid = !flag_ent:IsSolid()
		zone.custom_data.dont_color = flag_ent.NoColor
		zone.custom_data.render_mode = flag_ent:GetRenderMode()
		zone.custom_data.render_fx = flag_ent:GetRenderFX()
	end

	for k, v in pairs(zones) do
		cnt = cnt + 1
		file.Write(MG_CTF.SaveLocation.."/"..map.."/"..string.lower(v.id)..".txt", util.TableToJSON(v))
	end

	MG_CTF.UpdateMiniMapPositions() -- Optional update, because some positions might need to be updated.

	print("[MG CTF] "..cnt.." capture zone(s) saved.")

	return cnt
end

function MG_CTF.SaveZone(tb) -- Save specific zone
	if !tb.SaveID or tb.SaveID == -1 then return end

	local map = string.lower(game.GetMap())
	local filename = MG_CTF.SaveLocation.."/"..map.."/"..string.lower(tb.SaveID)..".txt"

	local config = file.Read(filename, "DATA")
	if !config then return end

	local zone = util.JSONToTable(config)
	if !zone then return end

	zone.capture_team = tb.CaptureID

	zone.rewards = tb.StashedRewards
	zone.taken = tb.TakenRewards

	file.Write(filename, util.TableToJSON(zone))
end

function MG_CTF.DeleteMapData(map) -- Wipes data for map
	file.CreateDir(MG_CTF.SaveLocation)
	file.CreateDir(MG_CTF.SaveLocation.."/"..map)

	for _, name in pairs(file.Find(MG_CTF.SaveLocation.."/"..map.."/*.txt", "DATA")) do
		file.Delete(MG_CTF.SaveLocation.."/"..map.."/"..name)
	end
end

function MG_CTF.Clear() -- Removes all zones
	for _, v in pairs(MG_CTF.CaptureArea) do
		if !IsValid(v) or !v.MainZone or v:IsMarkedForDeletion() then continue end
		v:Remove()
	end
end

-- Adding zones

function MG_CTF.AddZone(tool)
	custom_data = table.Copy(tool.Data or {})

	if !tool:GetUseSphere() then
		custom_data.zone_sphere = false

		custom_data.min = tool:GetMinPos()
		custom_data.max = tool:GetMaxPos()

		custom_data.zone_pos = nil
	else
		custom_data.zone_sphere = true

		custom_data.zone_pos = tool:GetSpherePos()
		custom_data.zone_size = MG_CTF.GetZoneSphereSize(tool:GetSphereSize())

		custom_data.min = nil
		custom_data.max = nil
	end

	local zone = ents.Create("ctf_area")
	if !IsValid(zone) then
		return false, MG_CTF.Translate("admin_invalid_entity")
	end

	zone.custom_data = custom_data

	zone:Spawn()

	return true, zone
end

function MG_CTF.EditZone(tool)
	local id = tool:GetZoneID()
	local ent = tool:GetEditEntity()
	
	if !IsValid(ent) then
		return false, MG_CTF.Translate("admin_invalid_entity")
	end

	local area = ent.Area
	if !IsValid(area) then
		return false, MG_CTF.Translate("admin_invalid_entity")
	end

	local zones = area.custom_data.zones or {}
	if id == 0 or zones[id] then -- Edit existing zone
		local zone = zones[id] or area
		zone.custom_data = zone.custom_data or {}

		if !tool:GetUseSphere() then
			zone.custom_data.zone_sphere = false

			zone.custom_data.min = tool:GetMinPos()
			zone.custom_data.max = tool:GetMaxPos()

			zone.custom_data.zone_pos = nil
		else
			zone.custom_data.zone_sphere = true

			zone.custom_data.zone_pos = tool:GetSpherePos()
			zone.custom_data.zone_size = MG_CTF.GetZoneSphereSize(tool:GetSphereSize())

			zone.custom_data.min = nil
			zone.custom_data.max = nil
		end

		if id != 0 then
			area.custom_data = area.custom_data or {}
			area.custom_data.zones = area.custom_data.zones or {}

			area.custom_data.zones[id] = {zone_sphere = zone.custom_data.zone_sphere, zone_pos = zone.custom_data.zone_pos, min = zone.custom_data.min, max = zone.custom_data.max} -- Save zone

			area:InitZones()
		else
			area:InitCollisions()
		end
	elseif !zones[id] then -- Create new zone
		local custom_data = {}

		if !tool:GetUseSphere() then
			custom_data.zone_sphere = false

			custom_data.min = tool:GetMinPos()
			custom_data.max = tool:GetMaxPos()

			custom_data.zone_pos = nil
		else
			custom_data.zone_sphere = true

			custom_data.zone_pos = tool:GetSpherePos()
			custom_data.zone_size = MG_CTF.GetZoneSphereSize(tool:GetSphereSize())

			custom_data.min = nil
			custom_data.max = nil
		end

		area.custom_data = area.custom_data or {}
		area.custom_data.zones = area.custom_data.zones or {}

		area.custom_data.zones[id] = {zone_sphere = custom_data.zone_sphere, zone_pos = custom_data.zone_pos, min = custom_data.min, max = custom_data.max} -- Save zone

		area:InitZones()
	end

	MG_CTF.UpdateAll()

	return true, area
end

-- Networking utility

function MG_CTF.ValidateZones() -- Validates zone data, which are frequently sent to players.
	MG_CTF.AdminToolNetwork = {}

	for _, v in pairs(MG_CTF.CaptureArea) do
		if !IsValid(v) or v:IsMarkedForDeletion() then continue end

		local tb = v:GetTable()
		local custom_data = tb.custom_data

		if custom_data then
			if custom_data.zone_sphere then
				table.insert(MG_CTF.AdminToolNetwork, {id = tb.ID, main = tb.MainZone, pos = custom_data.zone_pos, radius = MG_CTF.GetZoneSphereSize(custom_data.zone_size)})
			else
				table.insert(MG_CTF.AdminToolNetwork, {id = tb.ID, main = tb.MainZone, min = custom_data.min, max = custom_data.max})
			end
		end
	end

	MG_CTF.AdminToolNetwork, MG_CTF.AdminToolNetworkSize = MG_CTF.Compress(MG_CTF.AdminToolNetwork)
end

function MG_CTF.NetworkZones(ply) -- Quick network zones
	if !MG_CTF.AdminToolNetwork or !MG_CTF.AdminToolNetworkSize then return end

	net.Start("MG_CTF_RequestData")
		net.WriteUInt(MG_CTF.AdminToolNetworkSize, 16)
		net.WriteData(MG_CTF.AdminToolNetwork, MG_CTF.AdminToolNetworkSize)
	if ply then
		net.Send(ply)
	else
		net.Broadcast()
	end
end

function MG_CTF.UpdateZones(ply) -- Update zone positions for player(s).
	if ply and !MG_CTF.IsAdmin(ply) then return end

	timer.Create("MG_CTF_UpdateZones", 0.1, 1, function() -- Delay by 0.1 seconds to prevent stacking of messages
		if !ply then
			MG_CTF.ValidateZones()
		end

		if ply then
			if ply:IsValid() then -- Check if the player actually exists
				MG_CTF.NetworkZones(ply)
			end
		else
			for ply in pairs(MG_CTF.PlayerEntities) do
				if MG_CTF.IsAdmin(ply) then
					local wep = ply:GetActiveWeapon()
					if IsValid(wep) and wep:GetClass() == "mg_ctf_setup" then
						MG_CTF.NetworkZones(ply)
					end
				end
			end
		end
	end)
end