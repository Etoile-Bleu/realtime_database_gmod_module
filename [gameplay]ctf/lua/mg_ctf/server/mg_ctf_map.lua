-- This is the whole implementation of the mini map.
-- If the minimap is disabled, this file won't load.

if !MG_CTF.Config.EnableMiniMap then return end

util.AddNetworkString("MG_CTF_MiniMap")

function MG_CTF.ValidateMiniMapPositions() -- Validates mini map positions, which are frequently sent to players.
	if !MG_CTF.Config.EnableMiniMap then return end

	MG_CTF.MiniMapNetwork = {}

	MG_CTF.MiniMapNetwork["zones"] = {}
	MG_CTF.MiniMapNetwork["flags"] = {}

	for _, v in pairs(MG_CTF.CaptureArea) do
		if !IsValid(v) or v:IsMarkedForDeletion() then continue end

		local tb = v:GetTable()
		local custom_data = tb.custom_data
		local parent = tb.ParentArea or tb

		if custom_data then
			if custom_data.zone_sphere then
				table.insert(MG_CTF.MiniMapNetwork["zones"], {pos = custom_data.zone_pos, radius = MG_CTF.GetZoneSphereSize(custom_data.zone_size), color = MG_CTF.RetrieveColor(parent.CaptureID)})
			else
				table.insert(MG_CTF.MiniMapNetwork["zones"], {min = custom_data.min, max = custom_data.max, color = MG_CTF.RetrieveColor(parent.CaptureID)})
			end
		end
	end

	for _, v in pairs(MG_CTF.FlagEntities) do
		if !IsValid(v) or v:IsMarkedForDeletion() then continue end

		local owner = v.Area.CaptureID

		table.insert(MG_CTF.MiniMapNetwork["flags"], {name = v:GetZoneName(), pos = v:GetPos(), owner = owner, color = MG_CTF.RetrieveColor(owner)})
	end

	MG_CTF.MiniMapNetwork, MG_CTF.MiniMapNetworkSize = MG_CTF.Compress(MG_CTF.MiniMapNetwork)
end

function MG_CTF.NetworkMiniMapPositions(ply) -- Quick network mini map positions
	if !MG_CTF.MiniMapNetwork or !MG_CTF.MiniMapNetworkSize then return end

	net.Start("MG_CTF_MiniMap")
		net.WriteUInt(MG_CTF.MiniMapNetworkSize, 16)
		net.WriteData(MG_CTF.MiniMapNetwork, MG_CTF.MiniMapNetworkSize)
	if ply then
		net.Send(ply)
	else
		net.Broadcast()
	end
end

function MG_CTF.UpdateMiniMapPositions(ply) -- Send minimap positions to player(s)
	if !MG_CTF.Config.EnableMiniMap then return end

	timer.Create("MG_CTF_UpdateMiniMapPositions", 0.1, 1, function() -- Delay by 0.1 seconds to prevent stacking of messages
		if !ply then
			MG_CTF.ValidateMiniMapPositions()
		end

		if ply then
			if ply:IsValid() then -- Check if the player actually exists
				MG_CTF.NetworkMiniMapPositions(ply)
			end
		else
			for ply in pairs(MG_CTF.PlayerEntities) do
				MG_CTF.NetworkMiniMapPositions(ply)
			end
		end
	end)
end