-- Admin tool

-- Networking init

util.AddNetworkString("MG_CTF_RequestData")

util.AddNetworkString("MG_CTF_AskZones")
util.AddNetworkString("MG_CTF_Edit")
util.AddNetworkString("MG_CTF_Reset")
util.AddNetworkString("MG_CTF_Zone")
util.AddNetworkString("MG_CTF_Copy")

-- Commands

local function Save(ply, cmd, args)
	if !IsValid(ply) or MG_CTF.IsAdmin(ply) then
		local cnt = MG_CTF.Save()

		MG_CTF.Notify(ply, 0, 5, MG_CTF.Translate("admin_save", cnt or 0))
	else
		MG_CTF.Notify(ply, 1, 4, MG_CTF.Translate("admin_notallowed"))
	end
end
concommand.Add("mg_ctf_save", Save)

local function Clear(ply, cmd, args)
	if !IsValid(ply) or MG_CTF.IsAdmin(ply) then
		MG_CTF.Clear()

		MG_CTF.Notify(ply, 0, 5, MG_CTF.Translate("admin_clear"))
	else
		MG_CTF.Notify(ply, 1, 4, MG_CTF.Translate("admin_notallowed"))
	end
end
concommand.Add("mg_ctf_clear", Clear)

local function ResetAllFlags(ply, cmd, args)
	if !IsValid(ply) or MG_CTF.IsAdmin(ply) then
		local count = 0
		
		for _, v in pairs(MG_CTF.CaptureArea) do
			if !IsValid(v) or !v.MainZone or v:IsMarkedForDeletion() then continue end
			
			local tb = v:GetTable()
			tb.CaptureID = nil
			tb.State = MG_CTF.STATE_UNCAPTURED
			tb.Progress = 0
			tb.RemoveProgress = nil
			tb.Occupied = nil
			tb.Capturing = nil
			tb.RaiderTeam = nil
			tb.Uncapturing = nil
			tb.Contested = nil
			tb.InterestTime = {}
			tb.StashedRewards = {}
			tb.TakenRewards = {}
			
			if IsValid(tb.FlagEntity) then
				tb:UpdateFlag(tb.FlagEntity, tb)
			end
			
			count = count + 1
		end
		
		MG_CTF.UpdateAll()
		MG_CTF.Notify(ply, 0, 5, MG_CTF.Translate("admin_clear").." ("..count.." flags)")
	else
		MG_CTF.Notify(ply, 1, 4, MG_CTF.Translate("admin_notallowed"))
	end
end
concommand.Add("anomalie_resetflags", ResetAllFlags)

-- Networking utility

function MG_CTF.NetworkTool(ply, ent) -- Send admin tool data to player
	local data, size = MG_CTF.Compress(ent.Data or {})

	net.Start("MG_CTF_Edit")
		net.WriteEntity(ent)
		net.WriteUInt(size, 16)
		net.WriteData(data, size)
	net.Send(ply)
end

-- Network traffic

net.Receive("MG_CTF_RequestData", function(len, ply) -- Request data when equipping the admin tool
	if !MG_CTF.NetworkTimeout(ply, "MG_CTF_RequestData") then return end

	MG_CTF.UpdateZones(ply)
end)

net.Receive("MG_CTF_AskZones", function(len, ply) -- For asking for zone information to load from
	if !MG_CTF.NetworkTimeout(ply, "MG_CTF_AskZones") then return end

	if !MG_CTF.IsAdmin(ply) then return end

	local send = net.ReadBool() -- Should we send or receive?

	if !send then
		local id = net.ReadString()

		local ent
		for _, v in pairs(MG_CTF.CaptureArea) do
			if !IsValid(v) or !v.MainZone or v:IsMarkedForDeletion() then continue end

			if v.SaveID == id then
				ent = v.FlagEntity
			end
		end

		if !IsValid(ent) then return end

		if ent:GetClass() == "ctf_flag" then
			local wep = ply:GetActiveWeapon()
			if IsValid(wep) and wep:GetClass() == "mg_ctf_setup" then
				MG_CTF.NetworkTool(ply, ent)
			end
		end
	else
		local zones = {} -- Collect zone information to send to the client

		for _, v in pairs(MG_CTF.CaptureArea) do
			if !IsValid(v) or !v.MainZone or v:IsMarkedForDeletion() then continue end

			local custom_data = v.custom_data
			if custom_data then
				table.insert(zones, {name = custom_data.name, id = v.SaveID})
			end
		end

		local data, size = MG_CTF.Compress(zones)

		net.Start("MG_CTF_AskZones")
			net.WriteUInt(size, 16)
			net.WriteData(data, size)
		net.Send(ply)
	end
end)

net.Receive("MG_CTF_Edit", function(len, ply) -- For editing zones
	if !MG_CTF.NetworkTimeout(ply, "MG_CTF_Edit") then return end

	if !MG_CTF.IsAdmin(ply) then return end

	local ent = net.ReadEntity()

	local tbl = MG_CTF.Decompress(net.ReadData(net.ReadUInt(16))) or {}

	if !IsValid(ent) then return end

	local class = ent:GetClass()

	if class == "mg_ctf_setup" then
		ent.Data = tbl

		-- Spheres and such
		if tbl.zone_sphere then
			if ent:GetUseSphere() != true then
				ent:SetStage(MG_CTF.DEFAULT_STATE)
				ent:SetUseSphere(true)
			end
			ent:SetSphereSize(MG_CTF.GetZoneSphereSize(tbl.zone_size))
		elseif ent:GetUseSphere() != false then
			ent:SetStage(MG_CTF.DEFAULT_STATE)
			ent:SetUseSphere(false)
			ent:SetSpherePos(vector_origin)
			ent:SetSphereSize(0)
		end

	elseif class == "ctf_flag" then

		local area = ent.Area

		area.custom_data = tbl

		area:InitServer()

		MG_CTF.Notify(ply, 0, 5, MG_CTF.Translate("admin_edit"))

		MG_CTF.UpdateAll()

		ServerLog("[MG CTF] "..ply:Name().." ("..ply:SteamID()..") edited "..ent:GetZoneName()..".\n")
	end
end)

net.Receive("MG_CTF_Reset", function(len, ply) -- For resetting rewards
	if !MG_CTF.NetworkTimeout(ply, "MG_CTF_Reset") then return end

	if !MG_CTF.IsAdmin(ply) then return end

	local ent = net.ReadEntity()

	if !IsValid(ent) or ent:GetClass() != "ctf_flag" then return end

	local area = ent.Area
	if area.CaptureID then
		area:SetNextInterest(nil, nil, area.MoneyTime or math.huge, area.XPTime or math.huge)

		area.MoneyTaken = {}
		area.XPTaken = {}

		MG_CTF.Notify(ply, 0, 4, MG_CTF.Translate("admin_reset"))

		ServerLog("[MG CTF] "..ply:Name().." ("..ply:SteamID()..") reset rewards of "..ent:GetZoneName()..".\n")
	else
		MG_CTF.Notify(ply, 1, 4, MG_CTF.Translate("admin_reset_error"))
	end
end)

net.Receive("MG_CTF_Zone", function(len, ply) -- Zone Editor
	if !MG_CTF.NetworkTimeout(ply, "MG_CTF_Zone") then return end

	if !MG_CTF.IsAdmin(ply) then return end

	local ent = net.ReadEntity()

	if !IsValid(ent) or ent:GetClass() != "ctf_flag" then return end

	local id = net.ReadUInt(16)

	local sphere = net.ReadBool()

	local remove = net.ReadBool()

	if id != 0 and remove then
		local area = ent.Area

		area.custom_data = area.custom_data or {}
		area.custom_data.zones = area.custom_data.zones or {}

		area.custom_data.zones[id] = nil -- Remove zone

		area:InitZones()

		MG_CTF.Notify(ply, 0, 4, MG_CTF.Translate("admin_remove", id))
		return
	end

	local wep = ply:GetActiveWeapon("mg_ctf_setup")
	if IsValid(wep) and wep:GetClass() == "mg_ctf_setup" then
		wep:ResetVariables()

		wep:SetStage(sphere and MG_CTF.SPHERESET_STATE or MG_CTF.AREASET_STATE1)

		wep:SetUseSphere(sphere and true or false)

		wep:SetEditEntity(ent)

		wep:SetZoneID(id)
	else
		MG_CTF.Notify(ply, 1, 4, MG_CTF.Translate("admin_tool_error"))
	end
end)

net.Receive("MG_CTF_Copy", function(len, ply) -- Support for copying another zone
	if !MG_CTF.NetworkTimeout(ply, "MG_CTF_Copy") then return end

	if !MG_CTF.IsAdmin(ply) then return end

	local send = net.ReadBool()
	if send then
		local cur_map = string.lower(game.GetMap())

		local zones = {} -- Collect zone information to send to the client

		for _, v in pairs(MG_CTF.CaptureArea) do
			if !IsValid(v) or !v.MainZone or v:IsMarkedForDeletion() then continue end

			local custom_data = v.custom_data
			if custom_data then
				zones[cur_map] = zones[cur_map] or {}
				table.insert(zones[cur_map], {name = custom_data.name, id = v.SaveID})
			end
		end

		local _, directories = file.Find(MG_CTF.SaveLocation.."/*", "DATA")
		for _, map in pairs(directories) do
			if map == cur_map then continue end

			for _, name in pairs(file.Find(MG_CTF.SaveLocation.."/"..map.."/*.txt", "DATA")) do
				local config = file.Read(MG_CTF.SaveLocation.."/"..map.."/"..name, "DATA")
				if config then
					local zone = util.JSONToTable(config)
					if zone then
						local custom_data = zone.custom_data
						if custom_data then
							zones[map] = zones[map] or {}
							table.insert(zones[map], {name = custom_data.name, id = zone.id})
						end
					end
				end
			end
		end

		local data, size = MG_CTF.Compress(zones)

		net.Start("MG_CTF_Copy")
			net.WriteBool(send)
			net.WriteUInt(size, 16)
			net.WriteData(data, size)
		net.Send(ply)
	else
		local map = net.ReadString()
		local name = net.ReadString()

		local custom_data = {}
		local full_name = MG_CTF.SaveLocation.."/"..map.."/"..name..".txt"
		local is_map = map == game.GetMap()

		if is_map or file.Exists(full_name, "DATA") then

			if is_map then
				for _, v in pairs(MG_CTF.CaptureArea) do
					if !IsValid(v) or !v.MainZone or v:IsMarkedForDeletion() then continue end

					if v.SaveID == name then
						if v.custom_data then
							custom_data = table.Copy(v.custom_data)
							break
						end
					end
				end
			else
				local config = file.Read(full_name, "DATA")
				if config then
					local zone = util.JSONToTable(config)
					if zone and zone.custom_data then
						custom_data = table.Copy(zone.custom_data)
					end
				end
			end

			local ent = net.ReadEntity()

			if IsValid(ent) and ent:GetClass() == "ctf_flag" then -- These shouldn't be copied across multiple entities
				custom_data.min = nil
				custom_data.max = nil
				custom_data.pos = nil
				custom_data.zone_pos = nil
				custom_data.zone_sphere = nil
			end

			custom_data.zones = nil -- This should never be copied

			local data, size = MG_CTF.Compress(custom_data)

			net.Start("MG_CTF_Copy")
				net.WriteBool(send)
				net.WriteUInt(size, 16)
				net.WriteData(data, size)
			net.Send(ply)

			MG_CTF.Notify(ply, 0, 4, MG_CTF.Translate("admin_settings_copied"))
		else
			MG_CTF.Notify(ply, 1, 4, MG_CTF.Translate("admin_file_not_found", full_name))
		end
	end
end)