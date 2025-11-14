AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:InitServer()
	if !IsValid(self.Area) then
		print("[MG CTF] Missing capture zone for flag entity! Removing...")
		self:Remove()
		return
	end

	self.Data = self.Data or {}

	local data = self.Data

	self:SetModel(MG_CTF.GetFlagEntityModel(data.model))

	self:SetModelScale(isnumber(data.modelscale) and data.modelscale or 1, 0)

	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)

	self:SetColor(istable(data.color) and Color(tonumber(data.color[1]) or 255, tonumber(data.color[2]) or 255, tonumber(data.color[3]) or 255, tonumber(data.color[4]) or 255) or color_white)
	self:SetMaterial(isnumber(data.material) and data.material or "")

	self:SetRenderMode(isnumber(data.render_mode) and data.render_mode or RENDERMODE_NORMAL)
	self:SetRenderFX(isnumber(data.render_fx) and data.render_fx or kRenderFxNone)

	self:SetZoneName(MG_CTF.GetFlagEntityName(data.name))
	self:SetDrawPos(isvector(data.drawpos) and data.drawpos or Vector(0, 0, 25))

	if !data.eff_capture_prevent or !data.eff_collect_prevent then
		self:SetEffectNames((isstring(data.eff_capture_material) and data.eff_capture_material or "")..", "..(isstring(data.eff_collect_material) and data.eff_collect_material or ""))
	end

	self.NoColor = data.dont_color and tobool(data.dont_color) or false

	self:SetNoDraw(data.nodraw and tobool(data.nodraw) or false)
	self:SetNotSolid(data.not_solid and tobool(data.not_solid) or false)

	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:EnableMotion(false)
	end

	timer.Simple(0, function()
		if !IsValid(self) then return end
		self:ColorAccordingToFaction()
	end)
end

function ENT:ColorAccordingToFaction()
	local area = self.Area

	local color = MG_CTF.RetrieveColor(area.CaptureID)

	if !self.NoColor then
		self:SetColor(color)
	end

	self:SetTeamColor(color:ToVector())
end

function ENT:OnRemove()
	SafeRemoveEntity(self.Area)
end

function ENT:CashoutEffect()
	local data = self.Data
	if !data or data.eff_collect_prevent then return end

	local edata = EffectData()
	edata:SetEntity(self)
	edata:SetOrigin(self:GetPos())
	edata:SetScale(isnumber(data.eff_collect_size) and data.eff_collect_size or 1)
	edata:SetRadius(isnumber(data.eff_collect_particles) and data.eff_collect_particles or 50)
	edata:SetMagnitude(isnumber(data.eff_collect_lifetime) and data.eff_collect_lifetime or 4)
	edata:SetHitBox(isnumber(data.eff_collect_range) and data.eff_collect_range or 100)
	util.Effect("mg_ctf_cashout", edata, true, true)
end

function ENT:CollectRewards(ply, noMessage)
	local area = self.Area
	if !IsValid(area) then return end

	local area_tb = area:GetTable()

	local steamid = ply:SteamID()

	local received = false
	local rewards = {}

	for _, v in ipairs(MG_CTF.Config.RewardTypes) do -- Cycle through all possible reward types
		local id = tostring(v.id)
		if !id then continue end

		local rewardtbl = area_tb.Rewards[id] -- Cache table from area

		if rewardtbl and rewardtbl["Time"] then

			local collected = area_tb.TakenRewards[id] and area_tb.TakenRewards[id][steamid] or 0
			local stashed = area_tb.StashedRewards[id] or 0

			local subtract = math.min(rewardtbl.Max, stashed - collected) -- Calculate endamount for the user to receive
			if subtract > 0 then
				if hook.Run("MG_CTF_CanCollect", ply, self, subtract, area) == false then continue end

				if isfunction(v.give) then
					v.give(ply, subtract, self, area) -- Give the reward type to the player
				end

				if isfunction(v.format) then
					table.insert(rewards, v.format(subtract))
				elseif isstring(v.format) then
					table.insert(rewards, string.format(v.format, subtract))
				end

				if !area_tb.NoSharing then
					area_tb.TakenRewards[id] = area_tb.TakenRewards[id] or {}

					area_tb.TakenRewards[id][steamid] = stashed
				else
					area_tb:SetInterest(area_tb, id, 0)
				end

				received = true

				hook.Run("MG_CTF_Collect", ply, self, id, subtract, area)
			end
		end
	end

	if received then
		if area_tb.Players[ply] then
			area:SendData(ply, true, area_tb)
		end

		MG_CTF.SaveZone(area_tb)

		local rewardstr = table.concat(rewards, ", ")

		if rewardstr and rewardstr != "" and !message then
			MG_CTF.Notify(ply, 0, 4, MG_CTF.Translate("flag_retrieved", rewardstr, self:GetZoneName()))
		end
	end
end

function ENT:Use(ply)
	local area = self.Area
	if !IsValid(area) then return end

	local area_tb = area:GetTable()
	local tm_name = self:GetTeamName()

	if tm_name == "" and !area_tb.UseToStart then
		MG_CTF.Notify(ply, 1, 4, MG_CTF.Translate("flag_notcaptured"))
		return
	end

	local belongs = MG_CTF.BelongsToFaction(ply, tm_name)

	if !belongs and !area_tb.UseToStart then
		MG_CTF.Notify(ply, 1, 4, MG_CTF.Translate("flag_needtobe", tm_name))
		return
	end

	if belongs then
		if area_tb.RaiderTeam or area_tb.Contested then
			if area_tb.Contested then
				MG_CTF.Notify(ply, 1, 4, MG_CTF.Translate("flag_contested"))
			else
				MG_CTF.Notify(ply, 1, 4, MG_CTF.Translate("flag_notfullycaptured"))
			end
			return
		end

		local allowed = self:CollectRewards(ply, true)
		if allowed then
			self:CashoutEffect()
		end
	elseif area_tb.UseToStart then
		if area_tb.Disabled then
			MG_CTF.Notify(ply, 1, 4, MG_CTF.Translate("flag_captureforbidden", self:GetZoneName()))
			return
		end
		local can, faction, mess = area:CanCapture(ply, area_tb)
		if !area_tb.Occupied and !area_tb.Contested then
			if can then
				area_tb.AllowCapture = true
				area_tb.NextVerify = nil

				MG_CTF.Notify(ply, 0, 4, MG_CTF.Translate("flag_begincapture", self:GetZoneName()))
			else
				if mess then
					MG_CTF.Notify(ply, 1, 4, MG_CTF.Translate("flag_captureforbidden", self:GetZoneName()).."\n"..mess)
				else
					MG_CTF.Notify(ply, 1, 4, MG_CTF.Translate("flag_captureforbidden", self:GetZoneName()))
				end
			end
		end
	end
end

-- 76561198152707596