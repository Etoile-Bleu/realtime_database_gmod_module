-- Factions

MG_CTF.LoadedFactions = MG_CTF.LoadedFactions or false

util.AddNetworkString("MG_CTF_NetworkFactions")
util.AddNetworkString("MG_CTF_EditFactions")

function MG_CTF.ClearFactions() -- Clears all factions, keeping the table object
	table.Empty(MG_CTF.GetFactions())
end

function MG_CTF.GetFactionsCompressed() -- Retrieve all factions, but compressed and networking ready.
	return MG_CTF.CompressedFactions, MG_CTF.CompressedFactionsLeng
end

function MG_CTF.AddFaction(name, tab) -- Used to add a faction to the server. (needs to be networked afterwards)
	if !name or !istable(tab) then
		print("[MG CTF] MG_CTF.AddFaction ("..(isstring(name) and name or "INVALID")..") with no name or table submitted! Ignoring...")
		return
	end

	MG_CTF.GetFactions()[name] = tab

	print("[MG CTF] Faction ("..(isstring(name) and name or "INVALID")..") successfully added.")
end

function MG_CTF.LoadFactions() -- Load up all factions
	MG_CTF.LoadedFactions = true

	MG_CTF.ClearFactions()

	file.CreateDir(MG_CTF.SaveLocation)
	local factions = file.Read(MG_CTF.SaveLocation.."/factions.txt", "DATA")
	factions = factions and util.JSONToTable(factions or {}) or {}

	for k, v in pairs(factions) do
		if istable(v.members) then
			local newmembers = {} -- Create new members table and delete old one

			for id, allowed in pairs(v.members) do
				if allowed then
					newmembers[MG_CTF.ResolveTeam(id)] = true -- Conversion to actual team IDs
				end
			end

			v.members = {}

			for id, allowed in pairs(newmembers) do
				v.members[id] = allowed
			end
		end

		MG_CTF.AddFaction(k, v)
	end

	MG_CTF.CompressedFactions, MG_CTF.CompressedFactionsLeng = MG_CTF.Compress(MG_CTF.GetFactions())
end

function MG_CTF.UpdateFactions(ply) -- Update factions for player.
	local data, size = MG_CTF.GetFactionsCompressed()

	if data then -- For the edge case, the compression failed.
		net.Start("MG_CTF_NetworkFactions")
			net.WriteUInt(size, 16)
			net.WriteData(data, size)
		if ply then
			net.Send(ply)
		else
			net.Broadcast()
		end
	end
end

net.Receive("MG_CTF_EditFactions", function(len, ply) -- Editing factions
	if !MG_CTF.NetworkTimeout(ply, "MG_CTF_EditFactions") then return end

	if !MG_CTF.IsAdmin(ply) then return end

	local factions = MG_CTF.Decompress(net.ReadData(net.ReadUInt(16))) or {}

	factions = util.TableToJSON(factions) -- Wow..

	file.CreateDir(MG_CTF.SaveLocation)
	file.Write(MG_CTF.SaveLocation.."/factions.txt", factions)

	MG_CTF.LoadFactions()

	MG_CTF.UpdateFactions()

	MG_CTF.Notify(ply, 0, 4, MG_CTF.Translate("admin_edit_faction"))

	ServerLog("[MG CTF] "..ply:Name().." ("..ply:SteamID()..") edited factions.\n")
end)