ENT = ENT or {}
ENT.MaxAmmoCaches = 10
ENT.DeployCooldown = 2
ENT.DeployDistance = 200
ENT.CollectDistance = 200
ENT.SpawnOffset = {
    base = 250,
    random = {
        x = {min = -50, max = 50},
        y = {min = -25, max = 25}
    },
    height = 50
}

local COLLISION_GROUP_AMMOCACHE = 21
local COLLISION_GROUP_DEBRIS_TRIGGER = COLLISION_GROUP_DEBRIS_TRIGGER or 2
local RENDERMODE_NORMAL = RENDERMODE_NORMAL or 0
local MOVETYPE_NONE = MOVETYPE_NONE or 0
local MASK_SOLID = MASK_SOLID or 1
local CHAN_AUTO = CHAN_AUTO or 0
local TRAILER_OFFSET = Vector(-248.591308, 0.796151, 2.495337)
local math_random = math.random
local math_max = math.max
local IsValid = IsValid
local CurTime = CurTime
local pairs = pairs
local table_insert = table.insert
local string_format = string.format

if SERVER then
    local deployedCaches = {}
    local timerIDs = {}

    function ENT:InitializeAmmoCaches()
        if not self.Initialized then
            self.Initialized = true
            self:SetNWInt("AmmoCacheCount", self.MaxAmmoCaches)
            self:SetNWBool("CanUse", true)
            self.LastDeployTime = 0
            local entIndex = self:EntIndex()
            deployedCaches[entIndex] = {}
            timerIDs[entIndex] = {}
        end
    end

    function ENT:OnRemove()
        local entIndex = self:EntIndex()
        if deployedCaches[entIndex] then
            for _, cache in pairs(deployedCaches[entIndex]) do
                if IsValid(cache) then
                    cache:Remove()
                end
            end
            deployedCaches[entIndex] = nil
            
            if timerIDs[entIndex] then
                for _, id in pairs(timerIDs[entIndex]) do
                    if timer.Exists(id) then
                        timer.Remove(id)
                    end
                end
                timerIDs[entIndex] = nil
            end
        end
    end

    function ENT:CanDeployAmmoCache(ply)
        if not IsValid(ply) then return false end
        
        local cacheCount = self:GetNWInt("AmmoCacheCount", 0)
        if cacheCount <= 0 then return false end
        
        local timeSinceLastDeploy = CurTime() - (self.LastDeployTime or 0)
        if timeSinceLastDeploy < self.DeployCooldown then
            return false
        end
        
        return true
    end

    function ENT:CalculateSpawnPosition(ply)
        local vehiclePos = self:GetPos()
        local vehicleForward = self:GetForward()
        local vehicleRight = self:GetRight()
        local vehicleUp = self:GetUp()
        
        local trailerRearPos = vehiclePos + 
                              vehicleForward * (TRAILER_OFFSET.x - 20) + 
                              vehicleRight * TRAILER_OFFSET.y + 
                              vehicleUp * TRAILER_OFFSET.z
                              
        local randomOffset = Vector(math_random(-50, 50), math_random(-25, 25), 0)
        local finalOffset = vehicleRight * randomOffset.x + vehicleForward * randomOffset.y
        local spawnPos = trailerRearPos + finalOffset
        
        local filterTable = {self}
        if IsValid(ply) then 
            table_insert(filterTable, ply) 
        end
        
        local trace = util.TraceLine({
            start = spawnPos + Vector(0, 0, 50),
            endpos = spawnPos - Vector(0, 0, 100),
            filter = filterTable,
            mask = MASK_SOLID
        })
        
        if not trace.Hit or not trace.HitWorld then
            local fallbackPos = trailerRearPos + vehicleForward * -50
            local fallbackTrace = util.TraceLine({
                start = fallbackPos + Vector(0, 0, 50),
                endpos = fallbackPos - Vector(0, 0, 100),
                filter = filterTable,
                mask = MASK_SOLID
            })
            
            if fallbackTrace.Hit and fallbackTrace.HitWorld then
                return fallbackTrace.HitPos
            else
                return trailerRearPos + Vector(0, 0, 10)
            end
        end
        
        return trace.HitPos
    end

    function ENT:DeployAmmoCache(ply)
        if not self:CanDeployAmmoCache(ply) then return false end
        
        local entIndex = self:EntIndex()
        if not deployedCaches[entIndex] then
            self:InitializeAmmoCaches()
            if not deployedCaches[entIndex] then return false end
        end
        
        local ammoCache = ents.Create("anomalie_ammo_cache")
        if not IsValid(ammoCache) then return false end
        
        local spawnPos = self:CalculateSpawnPosition(ply)
        local cacheIndex = ammoCache:EntIndex()
        
        ammoCache:SetPos(spawnPos)
        ammoCache:SetAngles(Angle(0, self:GetAngles().y, 0))
        ammoCache:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
        ammoCache:SetMoveType(MOVETYPE_NONE)
        ammoCache:SetNotSolid(true)
        ammoCache:SetNoDraw(false)
        ammoCache:SetRenderMode(RENDERMODE_NORMAL)
        ammoCache:SetHealth(1)
        ammoCache:SetMaxHealth(1)
        
        local phys = ammoCache:GetPhysicsObject()
        if IsValid(phys) then
            phys:EnableMotion(false)
            phys:SetMass(1)
            phys:SetMaterial("rubber")
            phys:SetDamping(0.5, 0.5)
            phys:SetVelocity(Vector(0, 0, 0))
            phys:SetAngularVelocity(Vector(0, 0, 0))
        end
        
        ammoCache:Spawn()
        ammoCache:SetKevlarAmount(100)
        ammoCache:SetMagazineAmount(2)
        ammoCache:SetRocketAmount(2)
        
        table_insert(deployedCaches[entIndex], ammoCache)
        self:EmitSound("ammo_system/ammo_deployed.wav", 150, 100, 1, CHAN_AUTO)
        
        local timerPhysics = "AmmoCache_Physics_" .. cacheIndex
        local timerRemove = "AmmoCache_Remove_" .. cacheIndex
        
        if not timerIDs[entIndex] then timerIDs[entIndex] = {} end
        table_insert(timerIDs[entIndex], timerPhysics)
        table_insert(timerIDs[entIndex], timerRemove)
        
        timer.Create(timerPhysics, 1, 1, function()
            if IsValid(ammoCache) then
                ammoCache:SetNotSolid(false)
                ammoCache:SetCollisionGroup(COLLISION_GROUP_AMMOCACHE)
                
                local phys = ammoCache:GetPhysicsObject()
                if IsValid(phys) then
                    phys:EnableMotion(true)
                    phys:SetVelocity(Vector(0, 0, 0))
                    if phys.SetAngularVelocity then
                        phys:SetAngularVelocity(Vector(0, 0, 0))
                    end
                    phys:SetMass(1)
                    phys:SetMaterial("rubber")
                    phys:SetDamping(0.5, 0.5)
                end
            end
        end)
        
        timer.Create(timerRemove, 660, 1, function()
            if IsValid(ammoCache) then
                ammoCache:Remove()
                
                for i, cache in pairs(deployedCaches[entIndex] or {}) do
                    if cache == ammoCache then
                        table.remove(deployedCaches[entIndex], i)
                        break
                    end
                end
            end
        end)
        
        local newCount = self:GetNWInt("AmmoCacheCount", 0) - 1
        self:SetNWInt("AmmoCacheCount", math_max(0, newCount))
        self.LastDeployTime = CurTime()
        return true
    end

    hook.Add("LVS.OnVehicleDestroyed", "AnomalieTransport_AmmoCache_Destroyed", function(vehicle)
        if not IsValid(vehicle) then return end
        
        local vehicleClass = vehicle:GetClass()
        if vehicleClass ~= "anomalie_russian_transport" and vehicleClass ~= "anomalie_french_transport" then
            return
        end
        
        vehicle:SetNWBool("CanUse", false)
        vehicle:SyncAmmoCacheState()

        local entIndex = vehicle:EntIndex()
        if not deployedCaches[entIndex] then return end
        
        timer.Simple(3, function()
            if deployedCaches[entIndex] then
                for _, cache in pairs(deployedCaches[entIndex]) do
                    if IsValid(cache) then
                        cache:Remove()
                    end
                end
                deployedCaches[entIndex] = nil
                if timerIDs[entIndex] then
                    for _, id in pairs(timerIDs[entIndex]) do
                        if timer.Exists(id) then
                            timer.Remove(id)
                        end
                    end
                    timerIDs[entIndex] = nil
                end
            end
        end)
    end)
end

if CLIENT then
    local ScrW, ScrH = ScrW, ScrH
    local draw_SimpleText = draw.SimpleText
    local Color = Color
    local TEXT_COLOR = Color(255, 255, 255, 255)
    
    function ENT:DrawAmmoCacheHUD()
        if not self:GetNWBool("CanUse", true) then return end
        
        local count = self:GetNWInt("AmmoCacheCount", 0)
        local text = string_format("Caisses de munitions: %d/%d", count, self.MaxAmmoCaches)
        
        draw_SimpleText(text, "DermaDefault", ScrW() - 200, ScrH() - 100, TEXT_COLOR)
    end

    net.Receive("SyncAmmoCacheState", function()
        local vehicle = net.ReadEntity()
        if not IsValid(vehicle) then return end
        
        local count = net.ReadInt(32)
        local canUse = net.ReadBool()
        
        vehicle:SetNWInt("AmmoCacheCount", count)
        vehicle:SetNWBool("CanUse", canUse)
    end)
end

function ENT:SyncAmmoCacheState()
    net.Start("SyncAmmoCacheState")
    net.WriteEntity(self)
    net.WriteInt(self:GetNWInt("AmmoCacheCount", 0), 32)
    net.WriteBool(self:GetNWBool("CanUse", true))
    net.Broadcast()
end