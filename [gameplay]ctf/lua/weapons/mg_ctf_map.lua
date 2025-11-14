if SERVER then
	AddCSLuaFile()
end

SWEP.PrintName = MG_CTF.Translate("minimap_main")
SWEP.Category = "MG CTF"
SWEP.Author = "mcNuggets"
SWEP.Spawnable = false
SWEP.DrawAmmo = false
SWEP.ViewModel = Model("models/weapons/c_arms.mdl")
SWEP.WorldModel = ""
SWEP.Slot = 5
SWEP.SlotPos = 10
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize	= -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

function SWEP:Initialize()
	self:SetHoldType("normal")
end

function SWEP:PreDrawViewModel()
	return true
end

function SWEP:Deploy()
	return true
end

function SWEP:Holster()
	return true
end

function SWEP:PrimaryAttack()
	if SERVER then return end

	if MG_CTF.OpenMiniMap then
		MG_CTF.OpenMiniMap()
	end
end

function SWEP:SecondaryAttack()
	if SERVER then return end

	if MG_CTF.OpenMiniMap then
		MG_CTF.OpenMiniMap()
	end
end

function SWEP:Reload()
	if SERVER then return end

	if MG_CTF.OpenMiniMap then
		MG_CTF.OpenMiniMap()
	end
end