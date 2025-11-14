local surface = surface -- Minor optimisation

-- Fonts

surface.CreateFont("MG_CTF_Advert", {font = "Roboto", size = 22, weight = 400, shadow = false})

-- Adverts

local advert_tbl = {}

local hidespeed = 2
local showspeed = 2.5

local function DrawAdvertBox(x, y, w, h, bgcolor, color, font, text) -- Function for drawing a box with text inside
	surface.SetDrawColor(bgcolor)
	surface.DrawRect(x, y, w, h)
	surface.DrawRect(x - 2, y - 2, w + 4, h + 4)
	surface.SetFont(font)
	local tw, th = surface.GetTextSize(text)
	surface.SetTextColor(color)
	surface.SetTextPos(x + w / 2 - tw / 2, y + h / 2 - th / 2)
	surface.DrawText(text, 0, 0)
end

local function DrawAdvert() -- Calculation and drawing of our custom adverts system
	local systime = SysTime()
	local frametime = RealFrameTime()

	for i=#advert_tbl, 1, -1 do -- Remove old adverts
		local v = advert_tbl[i]

		local timeleft = v.staytime - systime
		if timeleft <= 0 then
			table.remove(advert_tbl, i)
		end
	end

	if #advert_tbl == 0 then -- Check if there are any adverts to draw
		hook.Remove("HUDPaint", "MG_CTF_Advert")
		return
	end

	local invert = MG_CTF.Config.AdvertInvertList
	local yoffset = MG_CTF.Config.AdvertYOffset

	for k, v in ipairs(advert_tbl) do -- Cycle through adverts
		local timeleft = v.staytime - systime
		local creationtime = systime - v.creationdate

		local alpha = 150
		local textalpha = 255

		if timeleft <= (1 / hidespeed) then -- Fade to nothing-ness
			alpha, textalpha = alpha * (timeleft * hidespeed), textalpha * (timeleft * hidespeed)
		elseif creationtime <= (1 / showspeed) then -- Fade to something
			alpha, textalpha = alpha * (creationtime * showspeed), textalpha * (creationtime * showspeed)
		end

		local w = 250
		local x, y = MG_CTF.GetTextSize(v.text, "MG_CTF_Advert")
		w = x + 20
		if w < 250 then
			w = 250
		end

		local col = MG_CTF.Config.AdvertBGColor
		col.a = alpha

		local textcolor = MG_CTF.Config.AdvertTextColor
		textcolor.a = textalpha

		local size = MG_CTF.Config.AdvertYSize

		v.offset = Lerp(frametime * 10, v.offset or yoffset, yoffset)

		DrawAdvertBox(ScrW() / 2 - w / 2, v.offset, w, size, col, textcolor, "MG_CTF_Advert", v.text)

		yoffset = invert and (yoffset - size - 10) or (yoffset + size + 10)
	end
end

net.Receive("MG_CTF_Advert", function() -- Receive an advert
	local text = net.ReadString()

	MsgC(Color(150, 200, 150), "[MG CTF] "..text.."\n")

	local data = {}
	data.text = text
	data.staytime = SysTime() + MG_CTF.Config.AdvertLength
	data.creationdate = SysTime()

	table.insert(advert_tbl, 1, data)

	if MG_CTF.Config.AdvertSound and MG_CTF.Config.AdvertSound != "" then
		surface.PlaySound(MG_CTF.Config.AdvertSound)
	end

	hook.Add("HUDPaint", "MG_CTF_Advert", DrawAdvert)
end)