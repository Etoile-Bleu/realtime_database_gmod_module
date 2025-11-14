util.AddNetworkString("DeployAmmoCache")
util.AddNetworkString("RequestVehicleStatus")
util.AddNetworkString("SyncVehicleStatus")
util.AddNetworkString("SyncAmmoCacheState")

net.Receive("DeployAmmoCache", function(len, ply)
    local vehicle = net.ReadEntity()
    
    if not IsValid(vehicle) or not IsValid(ply) then return end
    if vehicle:GetClass() ~= "anomalie_russian_transport" and
    vehicle:GetClass() ~= "anomalie_french_transport" then return end
    
    if vehicle.CanDeployAmmoCache and vehicle:CanDeployAmmoCache(ply) then
        if vehicle.DeployAmmoCache then
            vehicle:DeployAmmoCache(ply)
        end
    end
end)

net.Receive("RequestVehicleStatus", function(len, ply)
    local vehicle = net.ReadEntity()
    
    if not IsValid(vehicle) or not IsValid(ply) then return end
    if vehicle:GetClass() ~= "anomalie_russian_transport" and vehicle:GetClass() ~= "anomalie_french_transport" then return end
    
    net.Start("SyncVehicleStatus")
    net.WriteEntity(vehicle)
    net.WriteInt(vehicle:GetNWInt("AmmoCacheCount", 0), 32)
    net.WriteBool(vehicle:GetNWBool("CanUse", true))
    net.Send(ply)
end)
