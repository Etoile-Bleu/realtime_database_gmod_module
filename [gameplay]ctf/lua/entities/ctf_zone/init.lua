ENT.Type = "brush"
ENT.Base = "ctf_area"
ENT.PrintName = "Capture zone"
ENT.Category = "Modern Gaming"
ENT.Spawnable = false
ENT.PhysgunDisabled = true
ENT.MainZone = false

function ENT:Initialize()
	local tb = self:GetTable()

	local custom_data = tb.custom_data

	self:InitCollisions(custom_data)

	if !IsValid(self) or self:IsMarkedForDeletion() then return end

	self:InitBasic()
end