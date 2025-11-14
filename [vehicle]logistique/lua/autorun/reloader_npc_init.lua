RELOADER_NPC = RELOADER_NPC or {}

RELOADER_NPC.InteractionDistance = 100
RELOADER_NPC.RechargeAmount = 10
RELOADER_NPC.Cooldown = 600
RELOADER_NPC.Model = "models/Humans/Group03/male_09.mdl"
RELOADER_NPC.ValidVehicles = {
    ["anomalie_russian_transport"] = true,
    ["anomalie_french_transport"] = true
}

local allowed_jobs = {
    "Logistique - Russe",
    "Logistique - 1er RIMa",
    "Citizen"
}

function RELOADER_NPC.IsValidVehicle(vehicle)
    if not IsValid(vehicle) then return false end
    local class = vehicle:GetClass()
    return RELOADER_NPC.ValidVehicles[class] or class:find("anomalie_russian_transport") or class:find("anomalie_french_transport")
end

function RELOADER_NPC.HasValidJob(player)
    if not IsValid(player) then return false end
    local jobTable = player:getJobTable()
    return jobTable and table.HasValue(allowed_jobs, jobTable.name)
end

if SERVER then
    util.AddNetworkString("ReloaderNPC_Interaction")
    util.AddNetworkString("ReloaderNPC_Notify")
    util.AddNetworkString("SyncVehicleStatus")

    local playerCooldowns = {}
    local playerLastCooldownNotify = {}
    local COOLDOWN_NOTIFY_INTERVAL = 2

    function RELOADER_NPC.RechargeVehicle(vehicle, player)
        if not RELOADER_NPC.IsValidVehicle(vehicle) then return false end

        if not RELOADER_NPC.HasValidJob(player) then
            net.Start("ReloaderNPC_Notify")
            net.WriteFloat(-3)
            net.Send(player)
            return false
        end

        local steamID = player:SteamID()
        local currentTime = CurTime()

        if playerCooldowns[steamID] and currentTime < playerCooldowns[steamID] then
            if not playerLastCooldownNotify[steamID] or currentTime > playerLastCooldownNotify[steamID] then
                net.Start("ReloaderNPC_Notify")
                net.WriteFloat(playerCooldowns[steamID] - currentTime)
                net.Send(player)
                playerLastCooldownNotify[steamID] = currentTime + COOLDOWN_NOTIFY_INTERVAL
            end
            return false
        end

        if player:getDarkRPVar("money") < 2500 then
            net.Start("ReloaderNPC_Notify")
            net.WriteFloat(-4)
            net.Send(player)
            return false
        end

        local currentCount = vehicle:GetNWInt("AmmoCacheCount", 0)
        local maxCaches = vehicle.MaxAmmoCaches or 10

        if currentCount >= maxCaches then
            net.Start("ReloaderNPC_Notify")
            net.WriteFloat(-1)
            net.Send(player)
            return false
        end

        local newCount = math.min(currentCount + RELOADER_NPC.RechargeAmount, maxCaches)
        vehicle:SetNWInt("AmmoCacheCount", newCount)

        net.Start("SyncVehicleStatus")
        net.WriteEntity(vehicle)
        net.WriteInt(newCount, 32)
        net.WriteBool(vehicle:GetNWBool("CanUse", true))
        net.Send(player)

        player:addMoney(-2500)

        playerCooldowns[steamID] = currentTime + RELOADER_NPC.Cooldown
        playerLastCooldownNotify[steamID] = nil

        net.Start("ReloaderNPC_Notify")
        net.WriteFloat(0)
        net.Send(player)

        return true
    end

    net.Receive("ReloaderNPC_Interaction", function(len, player)
        local npc = net.ReadEntity()
        local vehicle = net.ReadEntity()

        if not IsValid(npc) or not IsValid(vehicle) or not IsValid(player) then return end
        if npc:GetClass() ~= "reloader_npc" then return end

        local distance = player:GetPos():Distance(npc:GetPos())
        if distance > RELOADER_NPC.InteractionDistance then return end

        local vehicleDistance = vehicle:GetPos():Distance(npc:GetPos())
        if vehicleDistance > RELOADER_NPC.InteractionDistance * 2 then
            net.Start("ReloaderNPC_Notify")
            net.WriteFloat(-2)
            net.Send(player)
            return
        end

        RELOADER_NPC.RechargeVehicle(vehicle, player)
    end)

    hook.Add("PlayerDisconnected", "ReloaderNPC_CleanupCooldowns", function(player)
        local steamID = player:SteamID()
        playerCooldowns[steamID] = nil
        playerLastCooldownNotify[steamID] = nil
    end)
else
    net.Receive("ReloaderNPC_Notify", function()
        local code = net.ReadFloat()

        if code > 0 then
            notification.AddLegacy("Veuillez attendre " .. math.ceil(code) .. " secondes avant de recharger à nouveau", NOTIFY_HINT, 3)
        elseif code == 0 then
            notification.AddLegacy("Véhicule rechargé avec succès!", NOTIFY_GENERIC, 3)
            surface.PlaySound("items/ammo_pickup.wav")
        elseif code == -1 then
            notification.AddLegacy("Le véhicule est déjà plein de caisses", NOTIFY_HINT, 3)
        elseif code == -2 then
            notification.AddLegacy("Le véhicule est trop loin du point de rechargement", NOTIFY_ERROR, 3)
        elseif code == -3 then
            notification.AddLegacy("Vous n'avez pas le bon job pour interagir avec ce NPC.", NOTIFY_ERROR, 3)
        elseif code == -4 then
            notification.AddLegacy("Vous n'avez pas assez d'argent pour recharger ce véhicule.", NOTIFY_ERROR, 3)
        end
    end)

    local function FindNearestVehicle(npc)
        local nearestVehicle = nil
        local nearestDistance = RELOADER_NPC.InteractionDistance * 2

        for _, ent in pairs(ents.FindInSphere(npc:GetPos(), nearestDistance)) do
            if RELOADER_NPC.IsValidVehicle(ent) then
                local distance = npc:GetPos():Distance(ent:GetPos())
                if distance < nearestDistance then
                    nearestDistance = distance
                    nearestVehicle = ent
                end
            end
        end

        return nearestVehicle
    end

    local lastReloaderNPCAttempt = 0

    hook.Add("PlayerButtonDown", "ReloaderNPC_KeyPress", function(ply, button)
        if button == KEY_E then
            if CurTime() < (lastReloaderNPCAttempt or 0) then return end
            lastReloaderNPCAttempt = CurTime() + 1

            local nearestNPC = nil
            local nearestDistance = RELOADER_NPC.InteractionDistance

            for _, ent in pairs(ents.FindInSphere(ply:GetPos(), nearestDistance)) do
                if IsValid(ent) and ent:GetClass() == "reloader_npc" then
                    local distance = ply:GetPos():Distance(ent:GetPos())
                    if distance < nearestDistance then
                        nearestDistance = distance
                        nearestNPC = ent
                    end
                end
            end

            if IsValid(nearestNPC) then
                local vehicle = FindNearestVehicle(nearestNPC)
                if not IsValid(vehicle) then
                    notification.AddLegacy("Aucun véhicule compatible à proximité", NOTIFY_ERROR, 3)
                    return
                end

                net.Start("ReloaderNPC_Interaction")
                net.WriteEntity(nearestNPC)
                net.WriteEntity(vehicle)
                net.SendToServer()
            end
        end
    end)
end
