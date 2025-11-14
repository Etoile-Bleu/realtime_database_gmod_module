local config = MG_CTF.Config -- Don't touch this!

--[[ Addon config (Most is ingame) --]]--

-- Select language --

config.Language = "fr" -- Setup the language of the addon. (English = en, German = de, Spanish = es, French = fr, Polish = pl, Russian = ru, Turkish = tr)
-- You can add your own languages in "lua/mg_ctf/languages/" and set it here, using the name of the file.
-- For example: If you name your file "xy.lua", do config.Language = "xy". Now you're set up! :)


-- Setup developer groups --

config.DeveloperGroups = { -- These groups are allowed to access the admin tool + ingame config.
	["owner"] = true,
	["superadmin"] = true,

	-- ["default"] = true, -- To enable it for everybody, for whatever reason...
}

-- Donator groups

config.DonatorGroups = { -- This is the multiplier for payouts of money and xp. (eg. 1 = 100%, 1.5 = 150%)
	["default"] = 1, -- This is the default multiplier.
	-- ["donator"] = 1.1,
}

-- Reward types

config.RewardTypes = { -- Here you can add up to an infinite number of reward types, thus making creating your own gamemode with this addon much easier!
	{
		id = "money", -- ID for reward type
		name = function()
			return MG_CTF.Translate("editor_rewards_cat_money") -- Name of the reward type, can be function or a string
		end,
		format = function(str) -- Format the reward type, can be a function or a string
			return MG_CTF.FormatMoney(str)
		end,
		give = function(ply, amt, flag, area) -- Function for giving the reward to players
			MG_CTF.GiveMoney(ply, amt)
		end,
	},
	{
		id = "xp", -- ID for reward type
		name = function()
			return MG_CTF.Translate("editor_rewards_cat_xp") -- Name of the reward type, can be function or a string
		end,
		format = function(str) -- Format the reward type, can be a function or a string
			return MG_CTF.FormatXP(str)
		end,
		give = function(ply, amt, flag, area) -- Function for giving the reward to players
			MG_CTF.GiveXP(ply, amt)
		end,
	},
}

-- Hour Restrictions --

config.HourRestrictionEnabled = false -- Restrict capturing and uncapturing zones to real time hours.

config.ActiveHours = { -- Possible times to capture zones. 0 = 0am, 12 = 12am, 18 = 6pm, etc...
	["default"] = {min = 16, max = 22},

	-- ["Mon"] = {min = 16, max = 21}, -- Restrict per day.
	-- ["Tue"] = {min = 16, max = 21},
	-- ["Wed"] = {min = 16, max = 21},
	-- ["Thu"] = {min = 16, max = 21},

	["Fri"] = {min = 16, max = 24},
	["Sat"] = {min = 16, max = 24},
}

--[[ Client settings ]]--

-- Mini map

config.EnableMiniMap = true -- Enable the mini map to be opened.

config.MiniMapCommand = "!minimap" -- Command to open the mini map. (false to disable)
config.MiniMapButton = KEY_M -- Button to open the mini map. (false to disable) (https://wiki.facepunch.com/gmod/Enums/KEY)

config.MiniMapSize = {0.6, 0.8} -- Size of the mini map (Screen size * number)

config.MiniMapShowPlayers = true -- Show players on the mini map.
config.MiniMapOnlyShowAllies = true -- Only show allied players.

config.MiniMapHideEntities = true -- Hide entities from the mini map.
config.MiniMapHideZones = false -- Hide zones from the mini map.

config.MiniMapDefaultZoom = 20 -- Default zoom, when opening the mini map.
config.MiniMapMinZoom = 0.5 -- Minimum zoom for the mini map. (This is a dangerous number to play around with)
config.MiniMapMaxZoom = 20 -- Maximum zoom for the mini map.

config.MiniMapMovement = true -- Allow moving while the mini map is open.


-- HUD

config.HUDStyle = 1 -- 2 HUD styles come included with this addon. 1 = Intentional design, 2 = Alternate fixated look

-- For HUD style 2:
config.HUDStyleYOffset = 65 -- Y offset in pixels from screen. (To base on screen resolution, do something like this: ScrH() * 0.75)


-- Adverts

config.AdvertMode = 1 -- 2 advert modes come included in this addon. 1 = Our own design, 2 = Basic notifications
config.AdvertLength = 8 -- Staytime of adverts in seconds.

-- For Advert style 1:
config.AdvertTextColor = Color(255, 255, 255) -- Background color for adverts.
config.AdvertBGColor = Color(54, 54, 54) -- Background color for adverts.
config.AdvertYOffset = 100 -- Y offset in pixels from screen. (To base on screen resolution, do something like this: ScrH() * 0.75)
config.AdvertYSize = 30 -- Y size in pixels.
config.AdvertInvertList = false -- Invert advert queue
config.AdvertSound = Sound("garrysmod/content_downloaded.wav") -- Sound on advert. (false to disable) (https://maurits.tv/data/garrysmod/wiki/wiki.garrysmod.com/index8f77.html)


-- Editor

config.EditorSize = {0.35, 0.6} -- Size of the editor window (Screen size * number)

--[[ External addons ]]--


-- bLogs

config.SupportbLogs = true -- Use bLogs implementation to log all sorts of stuff coming from this addon.
config.bLogsCategory = "DarkRP" -- Category name
config.bLogsName = "[MG] CTF" -- Name name (lol)
config.bLogsColor = Color(100, 200, 100)

config.bLogsMinimizedLogs = { -- Configure, what you want to log. (Set to true to enable or false to disable)
	["capturesuccess"] = true, -- Successful capture
	["collect"] = true, -- Collecting resources like money or xp

	["enterzone"] = false, -- Entering a zone
	["exitzone"] = false, -- Exiting a zone

	["capturebegin"] = false, -- Capture begin
	["capturecancel"] = false, -- Capture cancel

	["contested"] = false, -- When a zone becomes contested
}


-- Download mode --

config.UseWorkshop = true -- Set to false, to disable all sorts of downloads for this addon.


-- Default settings --

config.SphereCheckDelay = 0.2 -- Change the time between checking for players in spheres. (Higher number = better performance, lower number = better tracking)
-- Spheres eat more resources, because they check their area periodically, while boxes use engine implementations, which make things go a lot faster.

config.DefaultModel = Model("models/toju/mg_ctf/flag.mdl") -- Default model of the flag entity. Can be changed in game.

config.DefaultMinPlayers = 0 -- Default minimum players, required to be on the server, for capturing to work. Can be changed in game.
config.DefaultCaptureTime = 20 -- Default capture time. Can be changed in game.
config.DefaultUncaptureTime = 30 -- Default uncapture time. Can be changed in game.
config.DefaultSphereSize = 256 -- Default sphere size. Can be changed in game.


-- Developer config --

--[[These functions can be edited to modify the addon to all of your needs
    More functions can be found in all files with the name mg_ctf_main.lua.]]

-- Function for giving (and taking) money.
function MG_CTF.GiveMoney(ply, amount)
	if !isnumber(amount) then return end -- This is for safety purposes, but not important.

	amount = amount * (config.DonatorGroups[MG_CTF.GetUserGroup(ply)] or config.DonatorGroups["default"] or 1) -- Donator group rewards.

	return ply.addMoney and ply:addMoney(math.floor(amount)) -- Which currency system are you using?
end

-- Function for giving (and taking) XP.
function MG_CTF.GiveXP(ply, amount)
	if !isnumber(amount) then return end -- This is for safety purposes, but not important.

	amount = amount * (config.DonatorGroups[MG_CTF.GetUserGroup(ply)] or config.DonatorGroups["default"] or 1) -- Donator group rewards.

	return ply.addXP and ply:addXP(amount) or ply.AddXP and ply:AddXP(amount) -- Which levelling system are you using?
end

-- Determines the usergroup of a player.
function MG_CTF.GetUserGroup(ply)
	return ply:GetUserGroup() -- Default Garry's Mod implementation.
end

-- Determines who is considered an Admin by this addon.
function MG_CTF.IsAdmin(ply)
	return config.DeveloperGroups[MG_CTF.GetUserGroup(ply)] or config.DeveloperGroups["default"]
end

-- Formats money. Nothing important.
function MG_CTF.FormatMoney(money)
	if DarkRP then
		return DarkRP.formatMoney(money)
	else
		return "$"..string.Comma(money)
	end
end

-- Formats XP. Nothing important again.
function MG_CTF.FormatXP(xp)
	return string.Comma(xp).." XP"
end

-- Used to retrieve the player's team.
function MG_CTF.GetTeam(ply)
	return ply:Team()
end

-- Used to retrieve the player's team color.
function MG_CTF.GetTeamColor(ply)
	return team.GetColor(ply:Team())
end

-- Used to retrieve all teams.
function MG_CTF.GetTeams()
	return RPExtraTeams or team.GetAllTeams() -- If DarkRP teams exist, use those. Otherwise fallback to GMod implementations.
end

-- Used to retrieve all added factions.
function MG_CTF.GetFactions()
	return MG_CTF.Factions or {}
end

-- Used to retrieve a specific faction.
function MG_CTF.GetFaction(faction)
	local found = MG_CTF.GetFactions()[faction]
	return found or {}, found and true or false
end

-- Used to retrieve a team id, from a command name.
function MG_CTF.ResolveTeam(id)
	for k, v in pairs(RPExtraTeams or {}) do -- Check DarkRP teams
		if v.command == id then
			id = k
		end
	end

	return id
end

-- Used to retrieve a command name, from a team id.
function MG_CTF.ResolveID(id)
	for k, v in pairs(RPExtraTeams or {}) do -- Check DarkRP teams
		if k == tonumber(id) then
			id = v.command
		end
	end

	return id
end

-- Used to retrieve all factions of a player
function MG_CTF.GetFactionsOfPlayer(ply)
	local ret = {}
	local tm = MG_CTF.GetTeam(ply)

	for faction, tab in pairs(MG_CTF.GetFactions()) do
		if istable(tab.members) and tab.members[tm] == true then
			table.insert(ret, faction)
		end
	end

	return ret
end

-- Used to determine who belongs to which faction.
function MG_CTF.BelongsToFaction(ply, faction)
	local allowed = hook.Run("MG_CTF_BelongsToFaction", ply, faction)
	if allowed != nil then
		return allowed
	end

	local tm = MG_CTF.GetTeam(ply)
	for faction2, tab in pairs(MG_CTF.GetFactions()) do
		if istable(tab.members) and tab.members[tm] == true and faction == faction2 then
			return true
		end
	end

	return false
end

-- Used to determine, if a player is allowed to capture a zone.
function MG_CTF.CanCapture(ply, ent, enemy)
	local allowed, faction, mess = hook.Run("MG_CTF_CanCapture", ply, ent, enemy)
	if allowed != nil then
		return allowed, faction, mess
	end

	local tb = ent:GetTable()

	local tm = MG_CTF.GetTeam(ply)
	for faction, tab in pairs(MG_CTF.GetFactions()) do
		if faction != enemy and istable(tab.members) and tab.members[tm] == true and (istable(tab.enemies) and tab.enemies[enemy] or (enemy == nil)) then
			if tb.IgnoreFactions[faction] then continue end -- Check ignores

			if (tb.MinPlayersArea or 0) > 0 then -- Check if enough players are in area
				local count = 0

				for k in pairs(tb.Players or {}) do
					if !IsValid(k) then continue end
					if MG_CTF.BelongsToFaction(k, faction) then
						count = count + 1

						if count >= tb.MinPlayersArea then
							break
						end
					end
				end

				if count < tb.MinPlayersArea then
					return false, nil, MG_CTF.Translate("reason_minplayersarea")
				end
			end

			local maxzones = tonumber(tab.maxzones) or 0 -- Check max zones
			if maxzones > 0 then

				local count = 0
				for _, v in pairs(MG_CTF.CaptureArea) do -- Count zone
					if !IsValid(v) or v:IsMarkedForDeletion() then continue end

					local tb = v:GetTable()
					if !tb.MainZone then continue end

					if tb.CaptureID == faction then
						count = count + 1

						if count >= maxzones then
							return false, nil, MG_CTF.Translate("reason_maxzones")
						end
					end
				end
			end

			return true, faction
		end
	end

	return false, nil, MG_CTF.Translate("reason_factionrestriction")
end

-- Used to retrieve color of faction
function MG_CTF.RetrieveColor(name)
	for faction, tab in pairs(MG_CTF.GetFactions()) do
		if name == faction and !table.IsEmpty(tab.members) then
			return istable(tab.color) and Color(tonumber(tab.color[1]) or 255, tonumber(tab.color[2]) or 255, tonumber(tab.color[3]) or 255, tonumber(tab.color[4]) or 255) or team.GetColor(next(tab.members)) -- Disgusting color object creation
		end
	end

	return Color(255, 255, 255)
end