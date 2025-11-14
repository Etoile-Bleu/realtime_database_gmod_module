
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")
include("sv_init.lua")

function ENT:IsEmpty()
    return self:GetKevlarAmount() <= 0 and self:GetMagazineAmount() <= 0 and self:GetRocketAmount() <= 0
end

function ENT:TakeMunitions(type, amount)
    if self:IsEmpty() then self:Remove() end
    return true
end