SWEP.PrintName = "CTF: Admin"
SWEP.Category = "MG CTF"
SWEP.Spawnable = true

SWEP.ViewModelFOV = 60
SWEP.ViewModelFlip = false
SWEP.UseHands = true
SWEP.ViewModel = Model("models/weapons/c_pistol.mdl")
SWEP.WorldModel = Model("models/weapons/w_pistol.mdl")

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = ""
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = ""

SWEP.AimLength = 500

SWEP.Data = {}

function SWEP:SetupDataTables()
	self:NetworkVar("Int", 0, "Stage")

	self:NetworkVar("Vector", 0, "MinPos")
	self:NetworkVar("Vector", 1, "MaxPos")

	self:NetworkVar("Bool", 0, "UseSphere")
	self:NetworkVar("Vector", 2, "SpherePos")
	self:NetworkVar("Float", 0, "SphereSize")

	self:NetworkVar("Entity", 0, "EditEntity")
	self:NetworkVar("Int", 1, "ZoneID")

	self:SetStage(MG_CTF.DEFAULT_STATE)
end

function SWEP:AskForData()
	if CLIENT then
		timer.Simple(0, function()
			if !IsValid(self) or self:GetOwner() != LocalPlayer() then return end
			self:CreateHooks()
		end)
	end
end

function SWEP:Initialize()
	self:AskForData()
end

function SWEP:EyeTrace(length)
	local ply = self:GetOwner()

	local trace = util.TraceLine({
		start = ply:EyePos(),
		endpos = ply:EyePos() + ply:EyeAngles():Forward() * (length or 10000),
		filter = {ply, self:GetEditEntity()},
	})

	return trace
end

function SWEP:ResetVariables()
	self:SetStage(MG_CTF.DEFAULT_STATE)

	self:SetMinPos(vector_origin)
	self:SetMaxPos(vector_origin)
	self:SetSpherePos(vector_origin)

	self:SetEditEntity(NULL)
	self:SetZoneID(0)
end

function SWEP:Deploy()
	self:ResetVariables()

	self:AskForData()

	return true
end