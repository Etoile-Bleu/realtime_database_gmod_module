ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.Name = "Anomalies"
ENT.Author = "Weier"
ENT.Spawnable = true
ENT.Category = "Anomalies"

local lastUseTime = {}

local function get_clip_size(wep)
    if not IsValid(wep) then return 0 end
    if wep.GetMaxClip1 and wep:GetMaxClip1() and wep:GetMaxClip1() > 0 then return wep:GetMaxClip1() end
    if wep.Primary and wep.Primary.ClipSize and wep.Primary.ClipSize > 0 then return wep.Primary.ClipSize end
    if wep.ClipSize and wep.ClipSize > 0 then return wep.ClipSize end
    if wep.Clip1 and type(wep.Clip1) == "function" then
        local c = wep:Clip1()
        if c and c > 0 then return c end
    end
    return 0
end

local weaponSettings = {}
local settingsFile = "ammolock_settings.txt"

local function LoadWeaponSettings()
    local fileContent = file.Read(settingsFile, "DATA")
    if fileContent then
        weaponSettings = util.JSONToTable(fileContent) or {}
        if not weaponSettings then
            weaponSettings = {}
        end
    else
        weaponSettings = {}
    end
end

LoadWeaponSettings()

hook.Add("AmmoLock_SettingsSaved", "AmmoCache_ReloadSettings", function()
    LoadWeaponSettings()
end)

function ENT:Initialize()
    self:SetModel("models/kali/props/cases/hard case a.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)

    local phys = self:GetPhysicsObject()
    if IsValid(phys) then phys:Wake() end

    self:SetKevlarAmount(self.AmmoTypes.kevlar.amount)
    self:SetMagazineAmount(self.AmmoTypes.magazines.amount)
    self:SetRocketAmount(self.AmmoTypes.rockets.amount)

    if not self:GetNWString("UniqueID", "") or self:GetNWString("UniqueID") == "" then
        self:SetNWString("UniqueID", string.format("C%d_%d", self:EntIndex(), math.random(100000, 999999)))
    end
end

function ENT:Use(ply)
    if not IsValid(ply) or not ply:IsPlayer() then return end
    print("[DEBUG] ENT:Use appelé par " .. tostring(ply))

    local sid, t = ply:SteamID(), CurTime()
    if lastUseTime[sid] and t - lastUseTime[sid] < 1 then print("[DEBUG] Cooldown caisse"); return end
    lastUseTime[sid] = t

    local w = ply:GetActiveWeapon()
    print("[DEBUG] Arme active:", w, w and w:GetClass() or "nil")
    if not IsValid(w) then print("[DEBUG] Arme non valide"); return end
    local clipSize = get_clip_size(w)
    local ammoType = w and w:GetPrimaryAmmoType() or -1
    if not ammoType or ammoType < 0 then print("[DEBUG] ammoType non valide"); return end

    local currentAmmo = ply:GetAmmoCount(ammoType)
    local maxAmmo = nil
    if weaponSettings and weaponSettings[w:GetClass()] and weaponSettings[w:GetClass()].maxAmmo then
        maxAmmo = weaponSettings[w:GetClass()].maxAmmo
    end    -- Vérifier d'abord si la caisse a des ressources disponibles
    local hasResources = false
    if clipSize < 2 then
        -- Pour les roquettes (armes avec clipSize < 2)
        hasResources = self:GetRocketAmount() > 0
        print("[DEBUG] Vérification roquettes:", self:GetRocketAmount())
    else
        -- Pour les chargeurs (armes normales)
        hasResources = self:GetMagazineAmount() > 0
        print("[DEBUG] Vérification chargeurs:", self:GetMagazineAmount())
    end

    if not hasResources then
        print("[DEBUG] Pas de ressources disponibles dans la caisse")
        return
    end

    local amountToGive = 0
    if maxAmmo then
        if currentAmmo >= maxAmmo then print("[DEBUG] Limite maxAmmo atteinte"); return end
        if clipSize > 0 then
            amountToGive = math.min(clipSize, maxAmmo - currentAmmo)
        else
            amountToGive = math.min(1, maxAmmo - currentAmmo)
        end
    else
        if clipSize > 0 then
            amountToGive = clipSize
        else
            amountToGive = 1
        end
    end

    if amountToGive > 0 then
        ply:GiveAmmo(amountToGive, ammoType)
        print("[DEBUG] Munitions données:", amountToGive)
        
        -- Décrémenter les ressources de la caisse
        if clipSize < 2 then
            self:SetRocketAmount(self:GetRocketAmount() - 1)
            print("[DEBUG] Roquette consommée, reste:", self:GetRocketAmount())
        else
            self:SetMagazineAmount(self:GetMagazineAmount() - 1)
            print("[DEBUG] Chargeur consommé, reste:", self:GetMagazineAmount())
        end
    else
        print("[DEBUG] Rien à donner (amountToGive <= 0)")
        return
    end
    self:UpdateAmmoDisplay()
    local vid = self:GetNWInt("VehicleID", 0)
    if vid > 0 then
        local cidx = self:GetNWInt("CacheIndex", 0)
        for _, v in ipairs(ents.FindByClass("anomalie_russian_transport")) do
            if IsValid(v) and v:EntIndex() == vid then
                v:SyncAmmoCacheContent(cidx)
                break
            end
        end
        for _, v in ipairs(ents.FindByClass("anomalie_french_transport")) do
            if IsValid(v) and v:EntIndex() == vid then
                v:SyncAmmoCacheContent(cidx)
                break
            end
        end
    end
    if self:GetKevlarAmount() <= 0 and self:GetMagazineAmount() <= 0 and self:GetRocketAmount() <= 0 then
        self:Remove()
    end
end

hook.Add("KeyPress", "AmmoCacheKevlarKeyPress", function(ply, key)
    if key ~= IN_RELOAD then return end
    for _, ent in ipairs(ents.FindInSphere(ply:GetPos(), 100)) do
        if ent:GetClass() == "anomalie_ammo_cache" and IsValid(ent) then
            if ent:GetKevlarAmount() > 0 and ply:Armor() < 100 then
                local k = math.min(ent.AmmoTypes.kevlar.pickupAmount, 100 - ply:Armor())
                ply:SetArmor(ply:Armor() + k)
                ent:SetKevlarAmount(ent:GetKevlarAmount() - k)
                ent:UpdateAmmoDisplay()
                if ent:GetKevlarAmount() <= 0 and ent:GetMagazineAmount() <= 0 and ent:GetRocketAmount() <= 0 then
                    ent:Remove()
                end
                break
            end
        end
    end
end)

function ENT:OnRemove()
    local vid = self:GetNWInt("VehicleID", 0)
    local cidx = self:GetNWInt("CacheIndex", 0)
    if vid <= 0 then return end

    for _, v in ipairs(ents.FindByClass("anomalie_russian_transport")) do
        if IsValid(v) and v:EntIndex() == vid then
            v:SetNWInt("AmmoCacheCount", v:GetNWInt("AmmoCacheCount", 0) + 1)
            break
        end
    end

    for _, v in ipairs(ents.FindByClass("anomalie_french_transport")) do
        if IsValid(v) and v:EntIndex() == vid then
            v:SetNWInt("AmmoCacheCount", v:GetNWInt("AmmoCacheCount", 0) + 1)
            break
        end
    end
end

hook.Add("PlayerDisconnected", "AmmoCacheCleanup", function(ply)
    lastUseTime[ply:SteamID()] = nil
end)

net.Receive("RequestAmmoCacheSync", function(_, ply)
    local cache = net.ReadEntity()
    if IsValid(cache) and cache:GetClass() == "anomalie_ammo_cache" then
        net.Start("AmmoCacheSync")
        net.WriteEntity(cache)
        net.WriteInt(cache:GetKevlarAmount(), 32)
        net.WriteInt(cache:GetMagazineAmount(), 32)
        net.WriteInt(cache:GetRocketAmount(), 32)
        net.WriteString(cache:GetNWString("UniqueID", "ID_" .. cache:EntIndex()))
        net.Send(ply)

    end
end)