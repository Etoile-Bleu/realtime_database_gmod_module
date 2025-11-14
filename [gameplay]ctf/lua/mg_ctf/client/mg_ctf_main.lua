-- Receiving factions data

net.Receive("MG_CTF_NetworkFactions", function()
	local tab = MG_CTF.GetFactions()

	local factions = MG_CTF.Decompress(net.ReadData(net.ReadUInt(16))) or {} -- Decompress factions sent over the network

	table.Empty(tab) -- Merge the tables, but keep the same table object.

	table.Merge(tab, factions)
end)

-- Quick helper function to get width and height of a specified text

function MG_CTF.GetTextSize(text, font)
	surface.SetFont(font)
	return surface.GetTextSize(text)
end

-- 76561198152707596