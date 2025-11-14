-- This is the whole implementation of the mini map.
-- If the minimap is disabled, this file won't load.

if !MG_CTF.Config.EnableMiniMap then return end

local use_font = system.IsWindows() and "Tahoma" or "Verdana"

surface.CreateFont("MG_CTF_MiniMap_Main", {font = "Roboto", size = 18, weight = 400, shadow = false})

surface.CreateFont("MG_CTF_MiniMap_Object", {font = "Roboto", size = 14, weight = 400, shadow = false})
surface.CreateFont("MG_CTF_MiniMap_SmallObject", {font = "Roboto", size = 12, weight = 400, shadow = false})

local minimapdata = {}
net.Receive("MG_CTF_MiniMap", function()
	minimapdata = MG_CTF.Decompress(net.ReadData(net.ReadUInt(16))) or {} -- Decompress minimap data sent over the network
end)

local nextopen = 0

local drag_spd = 2
local scroll_spd = 0.2

local max_map_size = 32768
local map_maxz

local circle32_mat = Material("mg_ctf/circle_32.png", "smooth ignorez")
local circle48_mat = Material("mg_ctf/circle_48.png", "smooth ignorez")
local circle512_mat = Material("mg_ctf/circle_512.png", "smooth ignorez")

local color_opacity = 100

function MG_CTF.OpenMiniMap()
	if IsValid(minimap) then return end

	local ply = LocalPlayer()
	local ang = Angle(0, 0, 0)

	local sizemult = {math.Clamp(MG_CTF.Config.MiniMapSize and MG_CTF.Config.MiniMapSize[1] or 0.6, 0.1, 1), math.Clamp(MG_CTF.Config.MiniMapSize and MG_CTF.Config.MiniMapSize[2] or 0.8, 0.2, 1)}
	local windowsize = {ScrW() * sizemult[1], ScrH() * sizemult[2]}

	local viewmult = math.Clamp(MG_CTF.Config.MiniMapDefaultZoom, MG_CTF.Config.MiniMapMinZoom, MG_CTF.Config.MiniMapMaxZoom)

	minimap = vgui.Create("DFrame")
	minimap:SetSize(windowsize[1], windowsize[2])
	minimap:SetTitle(MG_CTF.Translate("minimap_main"))
	minimap:SetDraggable(false)
	minimap:Center()
	minimap:MakePopup()
	minimap:ParentToHUD()

	MG_CTF.Theme.Frame.Setup(minimap)

	if MG_CTF.Config.MiniMapMovement then -- Enable movement via keyboard
		minimap:SetKeyboardInputEnabled(false)
	end

	minimap.MousePosX = 0
	minimap.MousePosY = 0

	minimap.OffsetVector = Vector(0, 0, 0)

	minimap.LockedOnPlayer = true

	local ready = false

	local oldThink = minimap.Think
	minimap.Think = function(self)
		oldThink(self)

		if MG_CTF.Config.MiniMapButton and input.IsKeyDown(MG_CTF.Config.MiniMapButton) then -- Close mechanic
			if !ready then return end
			self:Remove()
			nextopen = SysTime() + 0.1

			return

		else
			ready = true
		end

		if !self:IsHovered() then return end -- Drag logic

		local mx, my = gui.MousePos()

		local tb = self:GetTable()

		if input.IsMouseDown(MOUSE_LEFT) then
			if !tb.LM then
				tb.LM = true
			else
				local nx, ny = tb.MousePosX - mx, tb.MousePosY - my

				self:StopLock()

				tb.OffsetVector.x = tb.OffsetVector.x - (ny * viewmult * drag_spd)
				tb.OffsetVector.y = tb.OffsetVector.y - (nx * viewmult * drag_spd)
			end
		else
			tb.LM = false
		end

		tb.MousePosX, tb.MousePosY = mx, my
	end

	minimap.OnMouseWheeled = function(self, scroll) -- Scrolling in and out
		viewmult = math.Clamp(viewmult - (scroll * scroll_spd), MG_CTF.Config.MiniMapMinZoom, MG_CTF.Config.MiniMapMaxZoom)
	end

	minimap.viewdata = { -- Caching the view table
		w = minimap:GetWide() - 20,
		h = minimap:GetTall() - 40,

		drawviewmodel = false,
		drawhud = false,
		drawmonitors = false,
		bloomtone = false,
	}

	minimap.GetViewPos = function(self) -- Get view pos
		local tb = self:GetTable()

		return tb.LockedOnPlayer and ply:EyePos() or Vector(tb.LockPos.x, tb.LockPos.y, tb.LockPos.z)
	end

	minimap.GetViewAng = function(self) -- Get view angle
		return ang
	end

	minimap.StopLock = function(self) -- Stop locking the view to the player
		if self.LockedOnPlayer then
			self.LockedOnPlayer = false

			self.LockPos = ply:EyePos()
		end
	end

	minimap.GenerateMaxHeight = function() -- Cache max map height
		if !map_minz or !map_maxz then
			local _, maxs = game.GetWorld():GetRenderBounds()

			map_maxz = maxs.z
		end
	end

	minimap.GetMaxHeight = function() -- Get max map height
		minimap.GenerateMaxHeight()

		return map_maxz
	end

	minimap.To2D = function(self, pos, campos) -- Function for converting something from 3D to 2D.
		local w, h = self:GetWide() / 2, self:GetTall() / 2

		return w + ((campos.y - pos.y) / viewmult) / 2, h + ((campos.x - pos.x) / viewmult) / 2
	end

	minimap.DrawPlayer = function(self, ply, campos, ang) -- Draw player(s)
		local x, y = self:To2D(ply:GetPos(), campos + self.OffsetVector, ang)
		y = y + 10

		surface.SetMaterial(circle32_mat)

		surface.SetDrawColor(color_black)
		surface.DrawTexturedRectRotated(x, y, 34, 34, ang.y)

		surface.SetDrawColor(MG_CTF.GetTeamColor(ply))
		surface.DrawTexturedRectRotated(x, y, 32, 32, ang.y)

		draw.SimpleTextOutlined(ply:Name(), "MG_CTF_MiniMap_Object", x, y, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black)
	end

	minimap.DrawZones = function(self, campos, ang) -- Draw zones
		for _, v in ipairs(minimapdata["zones"] or {}) do
			v.color.a = color_opacity

			if v.radius then
				local x, y = self:To2D(v.pos, campos + self.OffsetVector, ang)
				y = y + 10

				surface.SetMaterial(circle512_mat)
				surface.SetDrawColor(v.color)
				surface.DrawTexturedRectRotated(x, y, v.radius / viewmult, v.radius / viewmult, ang.y)
			else
				local pos = Vector(0, 0, 0)

				pos.x = v.min.x > v.max.x and v.min.x or v.max.x
				pos.y = v.min.y > v.max.y and v.min.y or v.max.y

				local x, y = self:To2D(pos, campos + self.OffsetVector, ang)
				y = y + 10

				local draw_x = math.abs(v.max.y - v.min.y) / 2
				local draw_y = math.abs(v.max.x - v.min.x) / 2

				surface.SetDrawColor(v.color)
				surface.DrawRect(x, y, draw_x / viewmult, draw_y / viewmult, ang.y)
			end
		end
	end

	minimap.DrawFlags = function(self, campos, ang) -- Draw flag entities
		for _, v in ipairs(minimapdata["flags"] or {}) do
			local x, y = self:To2D(v.pos, campos + self.OffsetVector, ang)
			y = y + 10

			surface.SetMaterial(circle48_mat)

			surface.SetDrawColor(0, 0, 0)
			surface.DrawTexturedRectRotated(x, y, 51, 51, ang.y)

			surface.SetDrawColor(v.color)
			surface.DrawTexturedRectRotated(x, y, 48, 48, ang.y)

			draw.SimpleTextOutlined(v.name, "MG_CTF_MiniMap_Object", x, y - 6, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black)
			draw.SimpleTextOutlined(v.owner != "" and v.owner or MG_CTF.Translate("area_vacant"), "MG_CTF_MiniMap_SmallObject", x, y + 6, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black)
		end
	end

	local oldPaint = minimap.Paint
	minimap.Paint = function(self, w, h) -- Painting the view
		oldPaint(self, w, h)

		local tb = self:GetTable()

		local campos = minimap:GetViewPos()

		local ang = minimap:GetViewAng()

		local trace = util.TraceLine({ -- Make a trace to check for the current max height
			start = campos,
			endpos = campos + Vector(0, 0, max_map_size),
			filter = ply
		})

		local max_z = self.GetMaxHeight() -- Get max height of current map

		campos.z = max_z

		local znear = max_z - trace.HitPos.z

		local viewdata = minimap.viewdata

		viewdata.origin = campos + tb.OffsetVector
		viewdata.znear = znear
		viewdata.zfar = max_map_size

		viewdata.angles = Angle(90, 0, 0)

		local x, y = self:GetPos()

		viewdata.x = x + 10
		viewdata.y = y + 30

		viewdata.ortho = { -- Setup ortho view
			top = -viewdata.h * viewmult,
			bottom = viewdata.h * viewmult,

			left = -viewdata.w * viewmult,
			right = viewdata.w * viewmult,
		}

		render.SuppressEngineLighting(true) -- Some parameters to optimise the ongoing render view
		render.SetShadowsDisabled(true)
		render.PushFlashlightMode(false)

		local hide_tbl = {}

		if MG_CTF.Config.MiniMapHideEntities then -- Hide entities
			local factions = MG_CTF.GetFactionsOfPlayer(ply)

			for _, v in ipairs(ents.GetAll()) do
				local nodraw = v:GetNoDraw()
				if nodraw then continue end

				if MG_CTF.Config.MiniMapShowPlayers and v:IsPlayer() then
					if MG_CTF.Config.MiniMapOnlyShowAllies then
						local found = false
						for _, faction in ipairs(factions) do
							if MG_CTF.BelongsToFaction(v, faction) then
								found = true
								break
							end
						end
						if found then continue end
					else
						continue
					end
				end

				hide_tbl[v] = true
				v:SetNoDraw(true)
			end
		end

		render.RenderView(viewdata)

		for k in pairs(hide_tbl) do -- Show entities again
			k:SetNoDraw(false)
			k:CreateShadow() -- Fixes a bug with permanent shadow destruction
		end

		render.PopFlashlightMode()
		render.SetShadowsDisabled(false)
		render.SuppressEngineLighting(false)

		render.SetScissorRect(viewdata.x, viewdata.y, viewdata.x + viewdata.w, viewdata.y + viewdata.h, true) -- Cut off text outside of the rendered view.

			if !MG_CTF.Config.MiniMapHideZones then -- Hide zones
				self:DrawZones(campos, ang)

				self:DrawFlags(campos, ang)
			end

			self:DrawPlayer(ply, campos, ang) -- Draw local player

			if MG_CTF.Config.MiniMapShowPlayers then -- Show other players
				local factions = MG_CTF.GetFactionsOfPlayer(ply)

				for _, v in ipairs(player.GetAll()) do
					if ply != v and v:GetNoDraw() then continue end

					if MG_CTF.Config.MiniMapOnlyShowAllies then
						local found = false
						for _, faction in ipairs(factions) do
							if MG_CTF.BelongsToFaction(v, faction) then
								found = true
								break
							end
						end
						if !found then continue end
					end

					self:DrawPlayer(v, campos, ang)
				end
			end

		render.SetScissorRect(0, 0, 0, 0, false)

		draw.SimpleTextOutlined(MG_CTF.Translate("minimap_drag"), "MG_CTF_MiniMap_Main", 15, h - 45, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, color_black) -- Print instructions
		draw.SimpleTextOutlined(MG_CTF.Translate("minimap_scroll"), "MG_CTF_MiniMap_Main", 15, h - 30, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, color_black)
	end

	local x = MG_CTF.GetTextSize(MG_CTF.Translate("minimap_lock"), "MG_CTF_MiniMap_Main") -- Adjust button size to weight

	local lockbutton = vgui.Create("DButton", minimap)
	lockbutton:SetSize(x + 20, 25)
	lockbutton:SetPos(minimap:GetWide() - lockbutton:GetWide() - 15, minimap:GetTall() - lockbutton:GetTall() - 15)
	lockbutton:SetFont("MG_CTF_MiniMap_Main")
	lockbutton:SetText(MG_CTF.Translate("minimap_lock"))

	lockbutton.DoClick = function()
		minimap.LockedOnPlayer = true -- Reset everything and lock the view to the player again
		minimap.OffsetVector = Vector(0, 0, 0)

		surface.PlaySound("ui/buttonclick.wav")
	end

	MG_CTF.Theme.Button.Setup(lockbutton)
end

if MG_CTF.Config.MiniMapButton then -- Open the mini map with pressing a button
	hook.Add("PlayerButtonDown", "MG_CTF_MiniMap", function(ply, button)
		if MG_CTF.Config.MiniMapButton != button or nextopen > SysTime() then return end

		if !IsFirstTimePredicted() then return end

		if ply != LocalPlayer() or ply:IsTyping() then return end

		MG_CTF.OpenMiniMap()
	end)
end

if MG_CTF.Config.MiniMapCommand then -- Open the mini map with a command
	hook.Add("OnPlayerChat", "MG_CTF_MiniMap", function(ply, text)
		if MG_CTF.Config.MiniMapCommand and MG_CTF.Config.MiniMapCommand != "" and string.lower(text) == MG_CTF.Config.MiniMapCommand then

			if ply != LocalPlayer() then return true end

			MG_CTF.OpenMiniMap()

			return true
		end
	end)
end