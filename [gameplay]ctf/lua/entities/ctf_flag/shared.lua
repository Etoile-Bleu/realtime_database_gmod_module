ENT.Type = "anim"
ENT.Base = "base_entity"
ENT.PrintName = "Flag Entity"
ENT.Category = "Modern Gaming"
ENT.Spawnable = false
ENT.PhysgunDisabled = true
ENT.RenderGroup = RENDERGROUP_BOTH

function ENT:SetupDataTables()
	self:NetworkVar("Bool", 0, "Disabled")
	self:NetworkVar("Bool", 1, "Contested")
	self:NetworkVar("Float", 0, "Progress")
	self:NetworkVar("String", 0, "ZoneName")
	self:NetworkVar("String", 1, "TeamName")
	self:NetworkVar("String", 2, "RaiderName")
	self:NetworkVar("String", 3, "EffectNames")
	self:NetworkVar("Vector", 0, "TeamColor")
	self:NetworkVar("Vector", 1, "RaiderColor")
	self:NetworkVar("Vector", 2, "DrawPos")
end

MG_CTF.FlagEntities = MG_CTF.FlagEntities or {}

function ENT:Initialize()
	if SERVER then
		self:SetUseType(SIMPLE_USE)

		self:InitServer()
	end

	MG_CTF.FlagEntities[self:EntIndex()] = self

	local custom_init = MG_CTF.InitializeFunc[self:GetModel()]
	if custom_init then
		custom_init(self)
	end
end

function ENT:OnRemove()
	if SERVER and IsValid(self.Area) then
		self.Area:Remove()
	end

	MG_CTF.FlagEntities[self:EntIndex()] = nil
end

function ENT:PhysgunPickup(ply)
	return MG_CTF.IsAdmin(ply)
end

function ENT:CanTool(ply)
	return MG_CTF.IsAdmin(ply)
end

function ENT:CanProperty()
	return false
end