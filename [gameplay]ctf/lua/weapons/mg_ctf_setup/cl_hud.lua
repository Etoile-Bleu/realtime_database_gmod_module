include("shared.lua")

-- Draw HUD for admin tool

MG_CTF.ZoneData = MG_CTF.ZoneData or {}

net.Receive("MG_CTF_RequestData", function()
	MG_CTF.ZoneData = MG_CTF.Decompress(net.ReadData(net.ReadUInt(16))) or {}
end)

function SWEP:CreateHooks()
	local ply = LocalPlayer()

	local color_zone_main = Color(155, 155, 155, 50) 
	local color_zone_extra = Color(50, 155, 155, 50)
	local color_zone_extra2 = Color(100, 255, 255)

	net.Start("MG_CTF_RequestData") -- Request zone infos.
	net.SendToServer()

	hook.Add("PostDrawTranslucentRenderables", "MG_CTF_Render", function(depth, skybox)
		if depth or skybox then return end

		local wep = ply:GetActiveWeapon()
		if !IsValid(wep) or wep:GetClass() != "mg_ctf_setup" then
			hook.Remove("PostDrawTranslucentRenderables", "MG_CTF_Render")
			return
		end

		render.SetColorMaterial()

		for k, v in pairs(MG_CTF.ZoneData) do
			if v.min and v.max then
				render.DrawBox(vector_origin, angle_zero, v.min, v.max, v.main and color_zone_main or color_zone_extra) 
				render.DrawWireframeBox(vector_origin, angle_zero, v.min, v.max, v.main and color_white or color_zone_extra2, true)
			elseif v.pos then
				render.DrawWireframeSphere(v.pos, v.radius, 25, 25, v.main and color_white or color_zone_extra2, true)
			end
		end

		local edit = self.GetEditEntity and IsValid(self:GetEditEntity()) and self:GetEditEntity() or false
		if self.GetMinPos and self.GetMaxPos and self.GetUseSphere and self.GetSphereSize then -- Come on, Garry..
			local min = self:GetMinPos()
			if min != vector_origin then
				local trace = self:EyeTrace(self.AimLength)

				local max = self:GetMaxPos()
				max = max != vector_origin and max or trace.HitPos

				if max then
					render.DrawBox(vector_origin, angle_zero, min, max, !edit and color_zone_main or color_zone_extra)
					render.DrawWireframeBox(vector_origin, angle_zero, min, max, !edit and color_white or color_zone_extra2, true)
				end
			end

			if self:GetUseSphere() then
				local pos = self:GetSpherePos()
				if self:GetStage() == MG_CTF.SPHERESET_STATE or pos != vector_origin then

					local trace = self:EyeTrace()
					pos = pos != vector_origin and pos or trace.HitPos

					render.DrawWireframeSphere(pos, MG_CTF.GetZoneSphereSize(self:GetSphereSize()), 25, 25, !edit and color_white or color_zone_extra2, true)
				end
			end
		end
	end)
end

surface.CreateFont("MG_CTF_Admin", {font = "Roboto", size = 20, weight = 800, shadow = false})
surface.CreateFont("MG_CTF_Admin2", {font = "Roboto", size = 18, weight = 800, shadow = false})
surface.CreateFont("MG_CTF_Admin3", {font = "Roboto", size = 14, weight = 800, shadow = false})

local function IsOnScreen(pos)
	local pos_x = pos.x
	local pos_y = pos.y
	return pos_x > 0 and pos_x < ScrW() and pos_y > 0 and pos_y < ScrH()
end

local vector_1 = Vector(0, 0, 1)
function SWEP:DrawHUD()
	for _, v in pairs(MG_CTF.FlagEntities) do
		if IsValid(v) then
			local pos = (v:GetPos() + vector_1 * (v:OBBMaxs().z / 2)):ToScreen()
			if IsOnScreen(pos) then
				draw.SimpleTextOutlined(v.GetZoneName and v:GetZoneName() or "", "MG_CTF_Admin2", pos.x, pos.y - 15, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black)
				draw.RoundedBox(0, pos.x - 3, pos.y - 3, 6, 6, color_black)
				draw.RoundedBox(0, pos.x - 2, pos.y - 2, 4, 4, color_white)
			end
		end
	end

	for _, v in pairs(MG_CTF.ZoneData) do
		if v.id == 0 then continue end
		local pos = (v.min and (v.min + (v.max - v.min) / 2) or v.pos):ToScreen()
		draw.SimpleTextOutlined("#"..v.id, "MG_CTF_Admin2", pos.x, pos.y, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black)
	end

	local scrw, scrh = ScrW() / 2, ScrH() - 100
	local stage = self:GetStage()

	local tr = IsValid(self:GetOwner()) and self:GetOwner():GetEyeTrace()
	local ent
	if tr then
		ent = tr.Entity
		ent = IsValid(ent) and ent:GetClass() == "ctf_flag" and ent or false
	end

	if ent then
		draw.SimpleTextOutlined(MG_CTF.Translate("admin_settings_ent"), "MG_CTF_Admin", scrw, scrh - 5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black)
	else
		draw.SimpleTextOutlined(MG_CTF.Translate("admin_settings"), "MG_CTF_Admin", scrw, scrh - 5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black)
	end

	if stage == MG_CTF.DEFAULT_STATE then

		draw.SimpleTextOutlined(MG_CTF.Translate("admin_new"), "MG_CTF_Admin", scrw, scrh - 45, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black)
		draw.SimpleTextOutlined(MG_CTF.Translate("admin_delete"), "MG_CTF_Admin", scrw, scrh - 25, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black)

	elseif stage == MG_CTF.AREASET_STATE1 then

		draw.SimpleTextOutlined(MG_CTF.Translate("admin_1stzone"), "MG_CTF_Admin", scrw, scrh - 45, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black)
		draw.SimpleTextOutlined(MG_CTF.Translate("admin_cancel"), "MG_CTF_Admin", scrw, scrh - 25, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black)
		
	elseif stage == MG_CTF.AREASET_STATE2 then

		draw.SimpleTextOutlined(MG_CTF.Translate("admin_2ndzone"), "MG_CTF_Admin", scrw, scrh - 45, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black)
		draw.SimpleTextOutlined(MG_CTF.Translate("admin_cancel"), "MG_CTF_Admin", scrw, scrh - 25, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black)

	elseif stage == MG_CTF.SPHERESET_STATE then

		draw.SimpleTextOutlined(MG_CTF.Translate("admin_zone"), "MG_CTF_Admin", scrw, scrh - 45, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black)
		draw.SimpleTextOutlined(MG_CTF.Translate("admin_cancel"), "MG_CTF_Admin", scrw, scrh - 25, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black)

	elseif stage == MG_CTF.FLAGPOLESET_STATE then

		draw.SimpleTextOutlined(MG_CTF.Translate("admin_flagpos"), "MG_CTF_Admin", scrw, scrh - 45, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black)
		draw.SimpleTextOutlined(MG_CTF.Translate("admin_cancel"), "MG_CTF_Admin", scrw, scrh - 25, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black)

	elseif stage == MG_CTF.FINALIZE_STATE then

		draw.SimpleTextOutlined(MG_CTF.Translate("admin_finish"), "MG_CTF_Admin", scrw, scrh - 45, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black)
		draw.SimpleTextOutlined(MG_CTF.Translate("admin_cancel"), "MG_CTF_Admin", scrw, scrh - 25, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black)

	end

	draw.SimpleTextOutlined(MG_CTF.Translate("admin_savecmd"), "MG_CTF_Admin", scrw, scrh + 20, Color(255, 200, 50), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black)
end