ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Caisse de munitions"
ENT.Author = "Weier"
ENT.Category = "Anomalies"
ENT.Spawnable = true
ENT.AdminSpawnable = true

ENT.AmmoTypes = {
    kevlar = { name = "Kevlar", amount = 100, pickupAmount = 50 },
    magazines = { name = "Chargeurs", amount = 2, pickupAmount = 1, bulletsPerMag = 30 },
    rockets = { name = "Roquettes", amount = 2, pickupAmount = 1 }
}

if SERVER then
    util.AddNetworkString("AmmoCacheSync")
    util.AddNetworkString("RequestAmmoCacheSync")

    function ENT:UpdateAmmoDisplay(target)
        net.Start("AmmoCacheSync")
        net.WriteEntity(self)
        net.WriteInt(self:GetKevlarAmount(), 32)
        net.WriteInt(self:GetMagazineAmount(), 32)
        net.WriteInt(self:GetRocketAmount(), 32)
        net.WriteString(self:GetNWString("UniqueID", "ID_" .. self:EntIndex()))
        if IsValid(target) then
            net.Send(target)
        else
            net.Broadcast()
        end
    end

    local function makeSetter(name, max)
        return function(self, amount)
            self:SetNWInt(name, math.Clamp(amount, 0, max))
            self:UpdateAmmoDisplay()
        end
    end

    ENT.SetKevlarAmount = makeSetter("KevlarAmount", ENT.AmmoTypes.kevlar.amount)
    ENT.SetMagazineAmount = makeSetter("MagazineAmount", ENT.AmmoTypes.magazines.amount)
    ENT.SetRocketAmount = makeSetter("RocketAmount", ENT.AmmoTypes.rockets.amount)

    function ENT:AddKevlar(amount) self:SetKevlarAmount(self:GetKevlarAmount() + amount) end
    function ENT:AddMagazine(amount) self:SetMagazineAmount(self:GetMagazineAmount() + amount) end
    function ENT:AddRocket(amount) self:SetRocketAmount(self:GetRocketAmount() + amount) end
    function ENT:RemoveKevlar(amount) self:SetKevlarAmount(self:GetKevlarAmount() - amount) end
    function ENT:RemoveMagazine(amount) self:SetMagazineAmount(self:GetMagazineAmount() - amount) end
    function ENT:RemoveRocket(amount) self:SetRocketAmount(self:GetRocketAmount() - amount) end

    hook.Add("OnEntityRemoved", "AmmoCacheVehicleRemoval", function(ent)
        local c = ent:GetClass()
        if c == "anomalie_russian_transport" or c == "anomalie_french_transport" then
            for _, ammoCache in ipairs(ents.FindByClass("anomalie_ammo_cache")) do
                if IsValid(ammoCache) then ammoCache:UpdateAmmoDisplay() end
            end
        end
    end)

    net.Receive("RequestAmmoCacheSync", function(len, ply)
        local ent = net.ReadEntity()
        if IsValid(ent) and ent:GetClass() == "anomalie_ammo_cache" then
            ent:UpdateAmmoDisplay(ply)
        end
    end)
end

function ENT:SetupDataTables()
    self:NetworkVar("Int", 0, "KevlarAmount")
    self:NetworkVar("Int", 1, "MagazineAmount")
    self:NetworkVar("Int", 2, "RocketAmount")
    self:NetworkVar("String", 0, "UniqueID")
end

if CLIENT then
    ENT.DisplayValues = {}

    function ENT:ForceUpdateDisplayValues(kevlar, magazines, rockets, uniqueID)
        self.DisplayValues = {
            kevlar = kevlar or 0,
            magazines = magazines or 0,
            rockets = rockets or 0,
            uniqueID = uniqueID or "ID_" .. self:EntIndex()
        }
    end

    net.Receive("AmmoCacheSync", function()
        local ent = net.ReadEntity()
        if not IsValid(ent) then return end
        local kevlar = net.ReadInt(32)
        local magazines = net.ReadInt(32)
        local rockets = net.ReadInt(32)
        local uniqueID = net.ReadString()
        ent:ForceUpdateDisplayValues(kevlar, magazines, rockets, uniqueID)
    end)

    function ENT:GetOverlayText()
        return ""
    end

    function ENT:Draw()
        self:DrawModel()

        local data = self.DisplayValues
        if not data or not data.kevlar then
            net.Start("RequestAmmoCacheSync")
            net.WriteEntity(self)
            net.SendToServer()
            return
        end

        local ply = LocalPlayer()
        local pos = self:GetPos()
        local distance = ply:GetPos():Distance(pos)
        if distance > 500 then return end

        local alpha = 1
        if distance > 300 then
            alpha = math.Clamp(1 - ((distance - 300) / 200), 0.1, 1)
        end

        if not self.AnimStartTime then self.AnimStartTime = CurTime() end
        local elapsed = CurTime() - self.AnimStartTime
        if elapsed < 1 then alpha = alpha * elapsed end

        local ang = (ply:EyePos() - pos):Angle()
        ang:RotateAroundAxis(ang:Up(), 90)
        ang:RotateAroundAxis(ang:Forward(), 90)

        cam.Start3D2D(pos + Vector(0, 0, 45), ang, 0.1)
            draw.RoundedBox(8, -125, -60, 250, 120, Color(20, 20, 20, 200 * alpha))
            draw.RoundedBox(0, -125, -60, 250, 25, Color(40, 40, 40, 200 * alpha))
            draw.SimpleText("CAISSE DE MUNITIONS", "Trebuchet24", 0, -48, Color(255, 255, 255, 255 * alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

            local color = (data.kevlar <= 0 and data.magazines <= 0 and data.rockets <= 0) and Color(255, 100, 100, 255 * alpha) or Color(255, 255, 255, 255 * alpha)
            draw.SimpleText("Kevlar: " .. data.kevlar .. "/100", "Trebuchet18", -110, -20, color, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            draw.SimpleText("Chargeurs: " .. data.magazines .. "/2", "Trebuchet18", -110, 0, color, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            draw.SimpleText("Roquettes: " .. data.rockets .. "/2", "Trebuchet18", -110, 20, color, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            draw.SimpleText("[E] pour munitions | [R] pour kevlar", "Trebuchet18", 0, 50, Color(200, 200, 200, 220 * alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        cam.End3D2D()

    end

    hook.Add("OnEntityCreated", "AmmoCache_ClientInit", function(ent)
        if IsValid(ent) and ent:GetClass() == "anomalie_ammo_cache" then
            timer.Simple(0.1, function()
                if IsValid(ent) then
                    net.Start("RequestAmmoCacheSync")
                    net.WriteEntity(ent)
                    net.SendToServer()
                end
            end)
        end
    end)
end