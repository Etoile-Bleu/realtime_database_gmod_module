MG_CTF.PlayerCount = MG_CTF.PlayerCount or 0
MG_CTF.PlayerEntities = MG_CTF.PlayerEntities or {}

MG_CTF.NetworkTimeoutTime = 0.1

if MG_CTF.Config.UseWorkshop then -- Workshop support.
	resource.AddWorkshop(2502619552)
end

-- Player counts (Own implementation, because calling player.GetAll() is slower)

hook.Add("PlayerInitialSpawn", "MG_CTF_PlayerCount", function(ply)
	MG_CTF.PlayerCount = MG_CTF.PlayerCount + 1
	MG_CTF.PlayerEntities[ply] = true
end)

hook.Add("PlayerDisconnected", "MG_CTF_PlayerCount", function(ply)
	MG_CTF.PlayerCount = math.max(0, MG_CTF.PlayerCount - 1)
	MG_CTF.PlayerEntities[ply] = nil
end)

-- Main networking

hook.Add("PlayerInitialSpawn", "MG_CTF_NetworkAll", function(ply)
	if !MG_CTF.LoadedFactions then -- Load up factions, if not loaded
		MG_CTF.LoadFactions()
	end

	timer.Simple(10, function() -- Delay by 10 seconds to not make the network crash, because of too many net messages.
		if !IsValid(ply) then return end

		MG_CTF.UpdateFactions(ply)

		MG_CTF.UpdateMiniMapPositions(ply)
	end)
end)

function MG_CTF.UpdateMiniMapPositions() -- Will be overridden in an external file. This is here to ensure, the calling of this function won't error.
end

function MG_CTF.UpdateAll(ply) -- Send current zones + mini map updates to player(s)
	MG_CTF.UpdateZones(ply)

	MG_CTF.UpdateMiniMapPositions(ply)
end

-- Notify system

function MG_CTF.Notify(ply, typ, leng, message)
	local allowed, message_override = hook.Run("MG_CTF_CanNotify", ply, typ, leng, message)

	if allowed == false then return end

	if DarkRP and DarkRP.notify then
		DarkRP.notify(ply, typ, leng, message_override or message)
	else
		ply:ChatPrint(message_override or message)
	end
end

-- Advert system

if MG_CTF.Config.AdvertMode == 1 then
	util.AddNetworkString("MG_CTF_Advert")
end

function MG_CTF.Advert(factions, message, ent)
	local plys = {}

	local tb = ent:GetTable()
	local data = tb.custom_data
	local tb_plys = tb.Players

	if !data.advert_global then -- Don't advert global, if configured
		for ply in pairs(MG_CTF.PlayerEntities) do
			for _, faction in ipairs(factions) do
				if MG_CTF.BelongsToFaction(ply, faction) then
					if !data.advert_transmit and tb_plys[ply] then continue end -- Don't advert to players inside the zone, if configured
					plys[ply] = true
					break
				end
			end
		end
	else
		for ply in pairs(MG_CTF.PlayerEntities) do
			if !data.advert_transmit and tb_plys[ply] then continue end -- Don't advert to players inside the zone, if configured
			plys[ply] = true
		end
		plys = MG_CTF.PlayerEntities
	end

	local allowed, message_override = hook.Run("MG_CTF_CanAdvert", plys, message, factions, ent)

	if allowed == false then return end

	for ply in pairs(plys) do
		if MG_CTF.Config.AdvertMode == 1 then -- Use advert mode 1? This is our custom one btw.
			net.Start("MG_CTF_Advert")
				net.WriteString(message_override or message)
			net.Send(ply)
		else
			MG_CTF.Notify(ply, 0, MG_CTF.Config.AdvertLength, message_override or message)
		end
	end
end

-- Network timeout

function MG_CTF.NetworkTimeout(ply, name)
	local tb = ply:GetTable()

	local timeout = tb.MG_CTF_NetworkTimeout 

	if timeout and timeout[name] and timeout[name] > CurTime() then
		return false
	else
		tb.MG_CTF_NetworkTimeout = tb.MG_CTF_NetworkTimeout or {} -- Create timeout table
		tb.MG_CTF_NetworkTimeout[name] = CurTime() + MG_CTF.NetworkTimeoutTime

		return true
	end
end

-- 76561198152707596