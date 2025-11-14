if CLIENT then
    local MENU_COOLDOWN = 0.5
    local INTERACTION_DISTANCE = 70
    local INTERACTION_ANGLE = -2.0
    local MAX_LATERAL_OFFSET = 100
    local lastMenuOpen = 0
    local currentMenu = nil

    include("cl_ammo_cache_ui_russian.lua")
    include("cl_ammo_cache_ui_french.lua")

    local function LoadAppropriateUI(vehicle)
        if not IsValid(vehicle) then 
            return nil 
        end
        
        
        if vehicle:GetClass():find("anomalie_russian_transport") then
            return AmmoCacheUI
        elseif vehicle:GetClass():find("anomalie_french_transport") then
            return AmmoCacheUIFrench
        end
        return nil
    end

    AmmoCacheUI = AmmoCacheUI or {}
    AmmoCacheUIFrench = AmmoCacheUIFrench or {}

    local COLORS = {
        background = Color(20, 35, 15, 230),
        header = Color(30, 45, 20, 255),
        button = Color(40, 55, 25, 255),
        buttonHover = Color(50, 65, 35, 255),
        text = Color(220, 220, 200, 255),
        border = Color(15, 25, 10, 255),
        highlight = Color(200, 180, 140, 255)
    }

    surface.CreateFont("RussianTitle", {
        font = "Roboto",
        size = 28,
        weight = 800,
        antialias = true
    })

    surface.CreateFont("RussianText", {
        font = "Roboto",
        size = 18,
        weight = 500,
        antialias = true
    })

    surface.CreateFont("RussianButton", {
        font = "Roboto",
        size = 20,
        weight = 700,
        antialias = true
    })

    local function IsPlayerNearVehicle(ply, vehicle)
        if not IsValid(ply) or not IsValid(vehicle) or (vehicle:GetClass() ~= "anomalie_russian_transport"
        and vehicle:GetClass() ~= "anomalie_french_transport") then return false end
        if not vehicle:GetNWBool("CanUse", true) then return false end

        local vehiclePos = vehicle:GetPos()
        local vehicleForward = vehicle:GetForward()
        local vehicleRight = vehicle:GetRight()
        local trailerOffset = Vector(-248.591308, 0.796151, 2.495337)
        local trailerRearPos = vehiclePos + vehicleForward * trailerOffset.x + vehicleRight * trailerOffset.y + vehicle:GetUp() * trailerOffset.z

        local distanceToTrailer = ply:GetPos():Distance(trailerRearPos)
        local playerToTrailer = ply:GetPos() - trailerRearPos
        local lateralOffset = math.abs(playerToTrailer:Dot(vehicleRight))
        local playerToVehicle = playerToTrailer:GetNormalized()
        local dot = vehicleForward:Dot(playerToVehicle)

        return distanceToTrailer <= INTERACTION_DISTANCE and lateralOffset <= MAX_LATERAL_OFFSET and dot >= INTERACTION_ANGLE
    end

    local function DrawRussianBorder(x, y, w, h, color)
        local borderSize = 3
        draw.RoundedBox(0, x, y, w, h, color)
        draw.RoundedBox(0, x + borderSize, y + borderSize, w - borderSize * 2, h - borderSize * 2, COLORS.background)
    end

    local function CreateRussianButton(parent, x, y, w, h, text, icon, onClick, enabled)
        local button = vgui.Create("DButton", parent)
        button:SetPos(x, y)
        button:SetSize(w, h)
        button:SetText("")
        button:SetTextColor(COLORS.text)
        button:SetEnabled(enabled == nil and true or enabled)

        local hover = false
        button.Paint = function(self, w, h)
            local col = not self:IsEnabled() and Color(120, 120, 120, 255) or (hover and COLORS.buttonHover or COLORS.button)
            DrawRussianBorder(0, 0, w, h, COLORS.border)
            draw.RoundedBox(0, 3, 3, w - 6, h - 6, col)
            if hover and self:IsEnabled() then
                draw.RoundedBox(0, 3, 3, w - 6, 3, COLORS.highlight)
            end
            draw.SimpleText(text, "RussianButton", w/2, h/2, COLORS.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        button.OnCursorEntered = function(self) hover = true end
        button.OnCursorExited = function(self) hover = false end
        button.DoClick = function(btn) if btn:IsEnabled() and onClick then onClick() end end
        return button
    end

    local function CreateDeployMenu(vehicle)
        if not IsValid(vehicle) or not vehicle:GetNWBool("CanUse", true) then return end

        local appropriateUI = LoadAppropriateUI(vehicle)
        if not appropriateUI then return end
        if IsValid(currentMenu) then currentMenu:Close() end

        -- Utiliser l'UI appropriée au lieu de AmmoCacheUI
        local frame, infoLabel = appropriateUI.CreateDeployMenuUI(
            vehicle,
            function()
                currentMenu = nil
                timer.Remove("AmmoCacheMenuUpdate")
            end,
            function()
                net.Start("DeployAmmoCache")
                net.WriteEntity(vehicle)
                net.SendToServer()
            end
        )

        currentMenu = frame

        net.Start("RequestVehicleStatus")
        net.WriteEntity(vehicle)
        net.SendToServer()

        timer.Simple(0.1, function()
            if IsValid(frame) and IsValid(vehicle) then
                appropriateUI.UpdateMenuUI(frame, vehicle, infoLabel)
            end
        end)

        timer.Create("AmmoCacheMenuUpdate", 1, 0, function()
            if IsValid(frame) then
                local ply = LocalPlayer()
                if not IsPlayerNearVehicle(ply, vehicle) then
                    frame:Close()
                    timer.Remove("AmmoCacheMenuUpdate")
                    return
                end
                appropriateUI.UpdateMenuUI(frame, vehicle, infoLabel)
            else
                timer.Remove("AmmoCacheMenuUpdate")
            end
        end)
    end

    local function DrawProximityMessage()
        local x = ScrW() / 2 - 250
        local y = ScrH() - 120
        local w = 500
        local h = 40
        
        DrawRussianBorder(x, y, w, h, COLORS.border)
        
        surface.SetDrawColor(COLORS.text)
        
        draw.SimpleText(
            "APPUYEZ SUR [R] POUR ACCÉDER AU SYSTÈME DE DÉPLOIEMENT",
            "RussianText",
            ScrW() / 2,
            y + h / 2 - 7,
            COLORS.text,
            TEXT_ALIGN_CENTER
        )
    end

    hook.Add("HUDPaint", "DrawAmmoCacheProximityMessage", function()
        local ply = LocalPlayer()
        local tr = ply:GetEyeTrace()
        local vehicle = tr.Entity
    
        if IsValid(currentMenu) then return end
    
        if IsPlayerNearVehicle(ply, vehicle) then
            DrawProximityMessage()
        end
    end)

    local function HandleMenuKeyPress()
        local ply = LocalPlayer()
        local tr = ply:GetEyeTrace()
        local vehicle = tr.Entity

        if not IsPlayerNearVehicle(ply, vehicle) then return end

        DrawProximityMessage()

        if CurTime() - lastMenuOpen >= MENU_COOLDOWN then
            lastMenuOpen = CurTime()
            CreateDeployMenu(vehicle)
        end
    end

    net.Receive("SyncVehicleStatus", function()
        local vehicle = net.ReadEntity()
        local count = net.ReadInt(32)
        local canUse = net.ReadBool()

        if IsValid(vehicle) then
            vehicle:SetNWInt("AmmoCacheCount", count)
            vehicle:SetNWBool("CanUse", canUse)
        end
    end)

    hook.Add("PlayerButtonDown", "AmmoCacheKeyPress", function(ply, button)
        if button == KEY_R then
            HandleMenuKeyPress()
        end
    end)
end