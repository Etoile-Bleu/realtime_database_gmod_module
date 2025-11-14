include("shared.lua")

local playerCooldown = 0

net.Receive("ReloaderNPC_Notify", function()
    local code = net.ReadFloat()
    
    if code > 0 then
        playerCooldown = CurTime() + code
    elseif code == 0 then
        notification.AddLegacy("Véhicule rechargé avec succès!", NOTIFY_GENERIC, 3)
        surface.PlaySound("items/ammo_pickup.wav")
    elseif code == -1 then
        notification.AddLegacy("Le véhicule est déjà plein de caisses", NOTIFY_HINT, 3)
    elseif code == -2 then
        notification.AddLegacy("Le véhicule est trop loin du point de rechargement", NOTIFY_ERROR, 3)
    end
end)

function ENT:Draw()
    self:DrawModel()
    
    local pos = self:GetPos() + Vector(0, 0, 80)
    local ang = Angle(0, LocalPlayer():EyeAngles().y - 90, 90)
    
    cam.Start3D2D(pos, ang, 0.1)
        draw.SimpleText("POINT DE RECHARGEMENT", "DermaLarge", 0, -30, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)
        draw.SimpleText("Prix: 2500$", "DermaLarge", 0, 0, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)
        
        local currentTime = CurTime()
        if playerCooldown > currentTime then
            local remainingTime = math.ceil((playerCooldown - currentTime) / 60)
            draw.SimpleText("COOLDOWN: " .. remainingTime .. " MINUTES", "DermaLarge", 0, 30, Color(255, 100, 100, 255), TEXT_ALIGN_CENTER)
        else
            draw.SimpleText("Approchez un véhicule et appuyez sur E", "DermaDefault", 0, 30, Color(200, 200, 200, 255), TEXT_ALIGN_CENTER)
        end
    cam.End3D2D()
end
