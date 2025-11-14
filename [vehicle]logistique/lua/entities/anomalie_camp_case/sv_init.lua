ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.Name = "Anomalies"
ENT.Author = "Weier"
ENT.Spawnable = true
ENT.Category = "Anomalies"

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

hook.Add("AmmoLock_SettingsSaved", "CampCase_ReloadSettings", function()
    LoadWeaponSettings()
end)

local lastUseTime = {}
local holdingPlayers = {}

hook.Add("KeyRelease", "CampCase_ReleaseKey", function(ply, key)
    if key == IN_USE then
        holdingPlayers[ply:SteamID()] = nil
    end
end)

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

function ENT:Initialize()
    self:SetModel("models/kali/props/cases/hard case a.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)

    local phys = self:GetPhysicsObject()
    if IsValid(phys) then phys:Wake() end
end

function ENT:GiveAmmoToPlayer(ply)
    local w = ply:GetActiveWeapon()
    local clipSize = get_clip_size(w)
    local ammoType = w and w:GetPrimaryAmmoType() or -1

    if not IsValid(w) then return end
    if not ammoType or ammoType < 0 then return end

    local currentAmmo = ply:GetAmmoCount(ammoType)
    local maxAmmo = nil
    if weaponSettings and weaponSettings[w:GetClass()] and weaponSettings[w:GetClass()].maxAmmo then
        maxAmmo = weaponSettings[w:GetClass()].maxAmmo
    end

    local amountToGive = 0
    if maxAmmo then
        if currentAmmo >= maxAmmo then return end
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
    end
end

function ENT:Think()
    for sid, data in pairs(holdingPlayers) do
        local t = CurTime()
        if data.lastGiveTime and t - data.lastGiveTime < 0.7 then continue end
        
        local ply = data.player
        if not IsValid(ply) or ply:GetPos():DistToSqr(self:GetPos()) > 10000 then
            holdingPlayers[sid] = nil
            continue
        end
        
        if not ply:KeyDown(IN_USE) then
            holdingPlayers[sid] = nil
            continue
        end
        
        self:GiveAmmoToPlayer(ply)
        holdingPlayers[sid].lastGiveTime = t
    end
    
    self:NextThink(CurTime() + 0.1)
    return true
end

function ENT:Use(ply)
    if not IsValid(ply) or not ply:IsPlayer() then return end

    local sid, t = ply:SteamID(), CurTime()
    if lastUseTime[sid] and t - lastUseTime[sid] < 0.7 then return end
    lastUseTime[sid] = t
    
    self:GiveAmmoToPlayer(ply)
    
    holdingPlayers[sid] = {
        player = ply,
        lastGiveTime = t
    }
end

function ENT:OnRemove() 
    for sid, data in pairs(holdingPlayers) do
        holdingPlayers[sid] = nil
    end
end

hook.Add("PlayerDisconnected", "CampCaseCleanup", function(ply)
    lastUseTime[ply:SteamID()] = nil
    holdingPlayers[ply:SteamID()] = nil
end)