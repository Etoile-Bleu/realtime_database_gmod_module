include("shared.lua")
include("cl_hud.lua")
include("cl_theme.lua")
include("cl_menu.lua")

SWEP.Slot = 5
SWEP.SlotPos = 10
SWEP.DrawWeaponInfoBox = true

SWEP.Author = "mcNuggets"
SWEP.Instructions = MG_CTF.Translate("admin_new").."\n"..MG_CTF.Translate("admin_delete").."\n"..MG_CTF.Translate("admin_settings")

function SWEP:PrimaryAttack()
end

function SWEP:SecondaryAttack()
end

function SWEP:Reload()
end