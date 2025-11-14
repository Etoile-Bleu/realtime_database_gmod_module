ENT.Type = "ai"
ENT.Base = "base_ai"
ENT.PrintName = "NPC Rechargeur"
ENT.Author = "Weier"
ENT.Spawnable = true
ENT.Category = "Anomalies"

RELOADER_NPC = RELOADER_NPC or {}
RELOADER_NPC.InteractionDistance = 100
RELOADER_NPC.RechargeAmount = 5
RELOADER_NPC.Cooldown = 600
RELOADER_NPC.Model = "models/Humans/Group03/male_09.mdl"

RELOADER_NPC.ValidVehicles = {
    anomalie_russian_transport = true,
    anomalie_french_transport = true
}

function RELOADER_NPC.IsValidVehicle(vehicle)
    return IsValid(vehicle) and RELOADER_NPC.ValidVehicles[vehicle:GetClass()] or false
end