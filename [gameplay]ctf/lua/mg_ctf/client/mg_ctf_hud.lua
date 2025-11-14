MG_CTF.Cache = MG_CTF.Cache or {}

MG_CTF.StashedRewards = MG_CTF.StashedRewards or {}
MG_CTF.MaxRewards = MG_CTF.MaxRewards or {}
MG_CTF.TakenRewards = MG_CTF.TakenRewards or {}

local draw, surface = draw, surface -- Minor optimisation

-- Fonts

surface.CreateFont("MG_CTF_HUD_1", {font = "Roboto Cn", size = 24, weight = 400, shadow = false})
surface.CreateFont("MG_CTF_HUD_2", {font = "Roboto Cn", size = 16, weight = 400, shadow = false})

-- HUD

local ply

local war_mat = Material("mg_ctf/war.png")

local function IsOnScreen(pos) -- Checks if position is on screen
	local pos_x = pos.x
	local pos_y = pos.y
	return pos_x > 0 and pos_x < ScrW() and pos_y > 0 and pos_y < ScrH()
end

local color_outline = Color(255, 255, 255, 200)
local function DrawProgressBar(x, y, w, h, label, color, filled, textclr, flag, tbl) -- Draws a fancy progress bar
	filled = math.Clamp(filled, 0, 1)
	local w, h = w, h
	local centerx, centery = x, y
	x, y = centerx - w / 2, centery - h / 2
	surface.SetDrawColor(color_outline)
	surface.DrawOutlinedRect(x, y, w, h)

	color.a = 225 -- Make transparent without creating a new color object

	surface.SetDrawColor(color)
	surface.DrawRect(x + 2, y + 2, (w - 4) * filled, h - 4)

	color.a = 255

	local perc = flag:GetRaiderName() != "" and " ("..math.Round(filled * 100).."%)" or ""
	draw.SimpleTextOutlined(label..perc, tbl.font2, centerx, centery - 2, textclr or color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black)
end

local color_cache = {}

local color_contested = Color(255, 100, 100)
local function DrawMainInfo(flag, tbl) -- Main drawing function
	tbl = tbl or {}

	local tb = flag:GetTable()
	local dt = tb.dt

	if !dt then return end

	local screenpos = tbl.screenpos

	local progress = dt.Progress

	local contested = dt.Contested
	contested = contested != 0 and contested

	local zone_name = dt.ZoneName
	zone_name = zone_name != "" and zone_name or MG_CTF.Translate("area_unknown")

	local tm_name = dt.TeamName
	tm_name = tm_name != "" and tm_name or MG_CTF.Translate("area_vacant")

	local tm_clr = dt.TeamColor

	if tm_clr then -- Color caching
		local cache = tm_clr[1].."/"..tm_clr[2].."/"..tm_clr[3]
		color_cache[cache] = color_cache[cache] or Color(tm_clr[1] * 255, tm_clr[2] * 255, tm_clr[3] * 255)

		tm_clr = tm_clr and color_cache[cache]
	end

	if contested then
		surface.SetMaterial(war_mat)
		surface.SetDrawColor(color_white)
		surface.DrawTexturedRect(screenpos.x - 16, screenpos.y - 60, 32, 32)
	elseif progress >= 100 and MG_CTF.BelongsToFaction(ply, tm_name) then

		local rewards = {}

		for _, v in ipairs(MG_CTF.Config.RewardTypes) do
			local id = tostring(v.id)
			if !id then continue end

			local stashed = MG_CTF.StashedRewards[id]
			if stashed then
				local amt = math.min(stashed - (MG_CTF.TakenRewards[id] or 0), MG_CTF.MaxRewards[id] or math.huge)
				if amt > 0 then
					if isfunction(v.format) then
						table.insert(rewards, v.format(amt))
					elseif isstring(v.format) then
						table.insert(rewards, string.format(v.format, amt))
					end
				end
			end
		end

		local rewardstr = table.concat(rewards, ", ")
		if rewardstr and rewardstr != "" then
			draw.SimpleTextOutlined(MG_CTF.Translate("area_reward")..rewardstr, tbl.font2, screenpos.x, screenpos.y + 10 + tbl.barheight + tbl.rewardoffset, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, color_black)
		end
	end

	draw.SimpleTextOutlined(zone_name, tbl.font1, screenpos.x, screenpos.y - 30, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, color_black)
	draw.SimpleTextOutlined(tm_name, tbl.font2, screenpos.x, screenpos.y - 10, tm_clr, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, color_black)

	local raider = dt.RaiderName
	raider = raider != "" and raider

	local raider_clr = raider and dt.RaiderColor

	if raider_clr then -- Color caching
		local cache = raider_clr[1].."/"..raider_clr[2].."/"..raider_clr[3]
		color_cache[cache] = color_cache[cache] or Color(raider_clr[1] * 255, raider_clr[2] * 255, raider_clr[3] * 255)

		raider_clr = raider_clr and color_cache[cache]
	end

	DrawProgressBar(screenpos.x, screenpos.y + tbl.barheight, tbl.barwide, tbl.barheight, dt.Disabled and MG_CTF.Translate("area_captureimpossible") or contested and MG_CTF.Translate("area_contested") or raider or "", raider_clr or tm_clr, !raider and 1 or progress / 100, contested and color_contested, flag, tbl)
end

local tbl = {}
local function RenderCTF() -- Draw interfaces
	ply = ply or LocalPlayer()

	for flag in pairs(MG_CTF.Cache) do
		if !IsValid(flag) then
			MG_CTF.Cache[flag] = nil
			if table.IsEmpty(MG_CTF.Cache) then
				hook.Remove("HUDPaint", "MG_CTF_RenderCTF")
			end
			continue
		end

		if MG_CTF.Config.HUDStyle == 1 then
			local screenpos = (flag:GetPos() + (flag:GetAngles():Up() * flag:OBBMaxs().z) + flag:GetDrawPos()):ToScreen()

			if IsOnScreen(screenpos) then

				tbl.screenpos = screenpos
				tbl.font1 = "MG_CTF_HUD_1"
				tbl.font2 = "MG_CTF_HUD_2"
				tbl.barwide = 200
				tbl.barheight = 20
				tbl.rewardoffset = 0

				DrawMainInfo(flag, tbl)
			end
		else
			local screenpos = {}
			screenpos.x = ScrW() / 2
			screenpos.y = MG_CTF.Config.HUDStyleYOffset

			tbl.screenpos = screenpos
			tbl.font1 = "MG_CTF_HUD_1"
			tbl.font2 = "MG_CTF_HUD_2"
			tbl.barwide = 300
			tbl.barheight = 25
			tbl.rewardoffset = 3

			DrawMainInfo(flag, tbl)

			break
		end
	end
end

net.Receive("MG_CTF_Cache", function() -- Receive HUD informations to begin drawing
	local flag = net.ReadEntity()
	local draw = net.ReadBool()

	local rewardcount = net.ReadUInt(8)

	MG_CTF.StashedRewards = {}
	MG_CTF.MaxRewards = {}
	MG_CTF.TakenRewards = {}

	if rewardcount > 0 then

		for i=1, rewardcount do

			local id = net.ReadString()

			local amt = net.ReadUInt(32)
			local max = net.ReadUInt(32)
			local taken = net.ReadUInt(32)

			MG_CTF.StashedRewards[id] = amt
			MG_CTF.MaxRewards[id] = max
			MG_CTF.TakenRewards[id] = taken
		end
	end

	if !IsValid(flag) then return end

	if draw and table.IsEmpty(MG_CTF.Cache) then
		hook.Add("HUDPaint", "MG_CTF_RenderCTF", RenderCTF, HOOK_MONITOR_HIGH)
	end

	MG_CTF.Cache[flag] = draw and true or nil
end)