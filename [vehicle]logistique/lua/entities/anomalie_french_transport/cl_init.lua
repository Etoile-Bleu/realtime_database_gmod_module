include("shared.lua")
include("ammo_system/cl_ammo_cache_menu.lua")

function ENT:Initialize()
    self.BaseClass.Initialize(self)
    
    self:SetSkin(self.DefaultSkin)
    
    local bodygroups = self:GetBodyGroups()
    for _, group in pairs(bodygroups) do
        if group.name == "Add roof" then
            self:SetBodygroup(group.id, 1)
        elseif group.name == "Extra Bort" then
            self:SetBodygroup(group.id, 1)
        end
    end
end
