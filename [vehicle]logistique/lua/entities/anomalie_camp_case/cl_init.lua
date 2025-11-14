include("shared.lua")

local INTERACTION_DISTANCE = 200
local DISPLAY_DISTANCE = 500
local FADE_START_DISTANCE = 300

function ENT:Draw()
    self:DrawModel()

    local ply = LocalPlayer()
    local pos = self:GetPos()
    local distance = ply:GetPos():Distance(pos)
    if distance > DISPLAY_DISTANCE then return end

    local alpha = 1
    if distance > FADE_START_DISTANCE then
        alpha = math.Clamp(1 - ((distance - FADE_START_DISTANCE) / (DISPLAY_DISTANCE - FADE_START_DISTANCE)), 0.1, 1)
    end

    if self.AnimStartTime then
        local t = CurTime() - self.AnimStartTime
        if t < 1 then alpha = alpha * t end
    end

    local ang = Angle(0, (ply:EyePos() - pos):Angle().y, 0)
    ang:RotateAroundAxis(ang:Up(), 90)
    ang:RotateAroundAxis(ang:Forward(), 90)    cam.Start3D2D(pos + Vector(0, 0, 45), ang, 0.1)
        draw.RoundedBox(8, -125, -60, 250, 120, Color(20, 20, 20, 200 * alpha))
        draw.RoundedBox(0, -125, -60, 250, 25, Color(40, 40, 40, 200 * alpha))
        draw.SimpleText("CAISSE DE MUNITIONS", "Trebuchet24", 0, -10, Color(255, 255, 255, 255 * alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText("Maintenir [E] pour recharger", "Trebuchet18", 0, 30, Color(200, 200, 50, 255 * alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    cam.End3D2D()
end

function ENT:Initialize()
    if not self.AnimStartTime then self.AnimStartTime = CurTime() end
end
