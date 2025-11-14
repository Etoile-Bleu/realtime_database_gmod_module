AddCSLuaFile("shared.lua")

AddCSLuaFile("cl_init.lua") -- Add client files
AddCSLuaFile("cl_hud.lua")
AddCSLuaFile("cl_theme.lua")
AddCSLuaFile("cl_menu.lua")

include("shared.lua")

-- Ghosting system

function SWEP:SetupModel(model)
	local prop = self.GhostEntity
	if IsValid(prop) then return prop end

	self.GhostEntity = ents.Create("prop_physics")

	prop = self.GhostEntity
	if !IsValid(prop) then return false end

	prop:SetModel(MG_CTF.GetFlagEntityModel(self.Data.Model))
	prop:Spawn()
	prop:SetMaterial("models/debug/debugwhite")
	prop:SetRenderMode(RENDERMODE_TRANSCOLOR)
	prop:SetColor(Color(50, 200, 50, 150))
	prop:PhysicsDestroy()
	prop:SetNotSolid(true)
	prop:DrawShadow(false)

	return prop
end

function SWEP:CreateOrUpdateGhost()
	local prop = self:SetupModel()
	if !IsValid(prop) then return prop end

	local owner = self:GetOwner()
	if !IsValid(owner) then return prop end

	local tr = self:EyeTrace()

	local pos, ang = MG_CTF.GuessPositions(owner, prop, tr)

	prop:SetPos(pos)
	prop:SetAngles(ang)

	return prop
end

function SWEP:Holster()
	SafeRemoveEntity(self.GhostEntity)
	return true
end

function SWEP:OnRemove()
	SafeRemoveEntity(self.GhostEntity)
end

function SWEP:Think()
	local stage = self:GetStage()

	if stage == MG_CTF.FINALIZE_STATE then return end

	if stage != MG_CTF.FLAGPOLESET_STATE then
		SafeRemoveEntity(self.GhostEntity)
		return
	end

	self:CreateOrUpdateGhost()
end

-- Effects for extra fancy

local ShootSound = Sound("Metal.SawbladeStick")
local function DoEffect(self, tr)
	sound.Play(ShootSound, tr.HitPos)
	local ed = EffectData()
	ed:SetOrigin(tr.HitPos)
	ed:SetNormal(tr.HitNormal)
	ed:SetScale(2)
	ed:SetMagnitude(3)
	util.Effect("ElectricSpark", ed, true, true)
end

-- Initial SWEP functions

function SWEP:FinishZone()
	local owner = self:GetOwner()
	local edit = self:GetEditEntity()

	local succ, msg
	if !IsValid(edit) then
		succ, msg = MG_CTF.AddZone(self)

		if succ then
			local flag_ent = msg.FlagEntity
			if IsValid(flag_ent) then
				ServerLog("[MG CTF] "..owner:Name().." ("..owner:SteamID()..") created "..flag_ent:GetZoneName()..".\n")
			end
		end
	else
		succ, msg = MG_CTF.EditZone(self)

		if succ then
			local flag_ent = msg.FlagEntity
			if IsValid(flag_ent) then
				ServerLog("[MG CTF] "..owner:Name().." ("..owner:SteamID()..") edited "..flag_ent:GetZoneName()..".\n")
			end
		end
	end

	if succ then
		MG_CTF.Notify(owner, 0, 5, MG_CTF.Translate("admin_created"))
	elseif msg then
		MG_CTF.Notify(owner, 1, 4, msg)
	end

	self:ResetVariables()
end

function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire(CurTime() + 0.1)
	self:SetNextSecondaryFire(CurTime() + 0.1)

	local owner = self:GetOwner()

	if !owner:KeyPressed(IN_ATTACK) then return end

	if !MG_CTF.IsAdmin(owner) then MG_CTF.Notify(owner, 1, 4, MG_CTF.Translate("admin_notallowed")) return end

	local tr = self:EyeTrace(self.AimLength)

	local stage = self:GetStage()

	if stage == MG_CTF.DEFAULT_STATE then

		if self:GetUseSphere() then
			self:SetStage(MG_CTF.SPHERESET_STATE)
		else
			self:SetStage(MG_CTF.AREASET_STATE1)
		end

		sound.Play("ui/buttonclick.wav", self:GetPos())

	elseif stage == MG_CTF.AREASET_STATE1 then

		tr = self:EyeTrace()

		if !tr.HitPos or tr.Entity:IsPlayer() then return end

		self:SetMinPos(tr.HitPos)

		self:SetStage(MG_CTF.AREASET_STATE2)

		DoEffect(self, tr)

	elseif stage == MG_CTF.AREASET_STATE2 then

		if !tr.HitPos or tr.Entity:IsPlayer() then return end

		self:SetMaxPos(tr.HitPos)

		if IsValid(self:GetEditEntity()) then
			self:FinishZone()
		else
			self:SetStage(MG_CTF.FLAGPOLESET_STATE)
		end

		DoEffect(self, tr)

	elseif stage == MG_CTF.SPHERESET_STATE then

		tr = self:EyeTrace()

		if !tr.HitPos or tr.Entity:IsPlayer() then return end

		self:SetSpherePos(tr.HitPos)

		if IsValid(self:GetEditEntity()) then
			self:FinishZone()
		else
			self:SetStage(MG_CTF.FLAGPOLESET_STATE)
		end

		DoEffect(self, tr)

	elseif stage == MG_CTF.FLAGPOLESET_STATE then

		tr = self:EyeTrace()

		if !tr.HitPos or tr.Entity:IsPlayer() then return end

		local prop = self:CreateOrUpdateGhost()

		self.Data.pos = prop:GetPos()
		self.Data.ang = prop:GetAngles()

		self:SetStage(MG_CTF.FINALIZE_STATE)

		DoEffect(self, tr)

	elseif stage == MG_CTF.FINALIZE_STATE then

		self:FinishZone()
	end
end

function SWEP:SecondaryAttack()
	self:SetNextPrimaryFire(CurTime() + 0.1)
	self:SetNextSecondaryFire(CurTime() + 0.1)

	local owner = self:GetOwner()

	if !owner:KeyPressed(IN_ATTACK2) then return end

	if !MG_CTF.IsAdmin(owner) then MG_CTF.Notify(owner, 1, 4, MG_CTF.Translate("admin_notallowed")) return end

	if self:GetStage() == MG_CTF.DEFAULT_STATE then
		
		local tr = self:EyeTrace()

		local ent = tr.Entity

		if IsValid(ent) and ent:GetClass() == "ctf_flag" then
			SafeRemoveEntity(ent.Area)

			DoEffect(self, tr)
		else
			MG_CTF.Notify(owner, 1, 4, MG_CTF.Translate("admin_lookatflag"))
		end

	else
		self:ResetVariables()

		sound.Play("ui/buttonclick.wav", self:GetPos())
	end
end

function SWEP:Reload()
	local owner = self:GetOwner()

	if !owner:KeyPressed(IN_RELOAD) then return end

	if !MG_CTF.IsAdmin(owner) then MG_CTF.Notify(owner, 1, 4, MG_CTF.Translate("admin_notallowed")) return end

	for _, v in pairs(MG_CTF.FlagEntities) do
		if !IsValid(v) then continue end

		v.PrevNotSolid = !v:IsSolid()
		v:SetNotSolid(false)
	end

	local tr = owner:GetEyeTrace()
	local ent = tr.Entity
	ent = IsValid(ent) and ent:GetClass() == "ctf_flag" and ent or self

	for _, v in pairs(MG_CTF.FlagEntities) do
		if !IsValid(v) then continue end

		v:SetNotSolid(v.PrevNotSolid)
	end

	MG_CTF.NetworkTool(owner, ent)
end