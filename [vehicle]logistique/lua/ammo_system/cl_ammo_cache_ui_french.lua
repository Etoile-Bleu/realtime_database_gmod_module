if CLIENT then
    local COLORS = {
        background = Color(15, 25, 35, 230),
        header = Color(25, 35, 45, 255),
        button = Color(35, 45, 55, 255),
        buttonHover = Color(45, 55, 65, 255),
        text = Color(220, 220, 220, 255),
        accent = Color(30, 90, 180, 255),
        success = Color(40, 90, 60, 255),
        warning = Color(60, 40, 160, 255),
        border = Color(10, 25, 15, 255),
        highlight = Color(180, 200, 140, 255),
        french = Color(0, 85, 164, 255),
        metal = Color(90, 90, 90, 255),
        rust = Color(130, 60, 40, 255),
        gold = Color(180, 160, 100, 255),
        disabled = Color(120, 120, 120, 255)
    }

    local ICONS = {
        ammo = Material("icon16/box.png"),
        cancel = Material("icon16/cancel.png"),
        info = Material("icon16/information.png"),
        military = Material("icon16/shield.png"),
        warning = Material("icon16/error.png"),
        check = Material("icon16/accept.png")
    }

    local function CreateFonts()
        surface.CreateFont("FrenchTitle", {
            font = "Arial",
            size = 28,
            weight = 800,
            antialias = true
        })

        surface.CreateFont("FrenchText", {
            font = "Arial",
            size = 18,
            weight = 500,
            antialias = true
        })

        surface.CreateFont("FrenchButton", {
            font = "Arial",
            size = 20,
            weight = 700,
            antialias = true
        })
    end
    CreateFonts()

    local EMBLEM = Material("vgui/armee_de_terre.png", "smooth")
    local function DrawFrenchBorder(x, y, w, h, color)
        local borderSize = 3
        draw.RoundedBox(0, x, y, w, h, color)
        draw.RoundedBox(0, x + borderSize, y + borderSize, w - borderSize * 2, h - borderSize * 2, COLORS.background)
    end

    local function CreateFrenchButton(parent, x, y, w, h, text, icon, onClick, enabled)
        local button = vgui.Create("DButton", parent)
        button:SetPos(x, y)
        button:SetSize(w, h)
        button:SetText("")
        button:SetTextColor(COLORS.text)
        button:SetEnabled(enabled ~= false)
        
        local hover = false
        local textX, textY = w/2, h/2
        
        button.Paint = function(self, w, h)
            local col = not self:IsEnabled() and COLORS.disabled or (hover and COLORS.buttonHover or COLORS.button)
            
            DrawFrenchBorder(0, 0, w, h, COLORS.border)
            draw.RoundedBox(0, 3, 3, w - 6, h - 6, col)
            
            if hover and self:IsEnabled() then
                draw.RoundedBox(0, 3, 3, w - 6, 3, COLORS.highlight)
            end
            
            draw.SimpleText(text, "FrenchButton", textX, textY, COLORS.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        
        button.OnCursorEntered = function() hover = true end
        button.OnCursorExited = function() hover = false end
        button.DoClick = function(btn)
            if btn:IsEnabled() and onClick then onClick() end
        end
        
        return button
    end

    local function UpdateMenuUI(frame, vehicle, infoPanel)
        if not IsValid(frame) or not IsValid(vehicle) then return end
        if not vehicle:GetNWBool("CanUse", true) then 
            frame:Close()
            return 
        end

        local count = vehicle:GetNWInt("AmmoCacheCount", 0)
        local maxCaches = vehicle.MaxAmmoCaches or 0
        local deployButton = frame:GetChildren()[3]
        
        local statusText = string.format([[
        • ÉTAT DES MUNITIONS: %d/%d
        • ÉTAT DU VÉHICULE: %s]], 
            count, 
            maxCaches,
            vehicle:GetNWBool("CanUse", true) and "OPÉRATIONNEL" or "HORS SERVICE"
        )
        
        infoPanel:SetText(statusText)
        deployButton:SetEnabled(count > 0)
    end

    local function CreateDeployMenuUI(vehicle, closeCallback, deployCallback)
        local frame = vgui.Create("DFrame")
        frame:SetSize(500, 400)
        frame:Center()
        frame:SetTitle("")
        frame:MakePopup()
        frame:SetDraggable(true)
        frame:ShowCloseButton(false)
        
        local frameW, frameH = 500, 400
        local headerH = 40
        
        frame.Paint = function(self, w, h)
            DrawFrenchBorder(0, 0, w, h, COLORS.border)
            draw.RoundedBox(0, 3, 3, w - 6, headerH, COLORS.header)
            draw.SimpleText("TRANSPORT FRANÇAIS", "FrenchTitle", w/2, 22, COLORS.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            draw.RoundedBox(0, 3, 43, w - 6, 2, COLORS.border)
        end
        
        local closeButton = vgui.Create("DButton", frame)
        closeButton:SetPos(frameW - 30, 5)
        closeButton:SetSize(25, 25)
        closeButton:SetText("X")
        closeButton:SetTextColor(COLORS.text)
        closeButton:SetFont("FrenchButton")
        
        closeButton.Paint = function(self, w, h)
            draw.RoundedBox(0, 0, 0, w, h, self:IsHovered() and COLORS.warning or COLORS.header)
        end
        
        closeButton.DoClick = function()
            frame:Close()
            if closeCallback then closeCallback() end
        end
        
        local infoPanel = vgui.Create("DPanel", frame)
        infoPanel:SetPos(10, 50)
        infoPanel:SetSize(480, 120)
        infoPanel.Paint = function(self, w, h)
            DrawFrenchBorder(0, 0, w, h, COLORS.border)
        end
        
        local infoLabel = vgui.Create("DLabel", infoPanel)
        infoLabel:SetPos(10, 10)
        infoLabel:SetSize(460, 100)
        infoLabel:SetTextColor(COLORS.text)
        infoLabel:SetFont("FrenchText")
        infoLabel:SetWrap(true)
        
        local count = vehicle:GetNWInt("AmmoCacheCount", 0)
        local maxCaches = vehicle.MaxAmmoCaches or 0
        local statusText = string.format([[
        • ÉTAT DES MUNITIONS: %d/%d
        • ÉTAT DU VÉHICULE: %s]], 
            count, 
            maxCaches,
            vehicle:GetNWBool("CanUse", true) and "OPÉRATIONNEL" or "HORS SERVICE"
        )
        infoLabel:SetText(statusText)

        local deployButton = CreateFrenchButton(frame, 10, 270, 480, 50, "DÉPLOYER UNE CAISSE", nil, deployCallback, count > 0)
        local cancelButton = CreateFrenchButton(frame, 10, 330, 480, 50, "ANNULER", ICONS.cancel, function()
            frame:Close()
            if closeCallback then closeCallback() end
        end)
    
        local emblemImage = vgui.Create("DImage", frame)
        local emblemW = 150
        local emblemH = emblemW / 1.2
        
        emblemImage:SetSize(emblemW, math.floor(emblemH))
        emblemImage:SetPos((frameW - emblemW) / 2, 140)
        emblemImage:SetMaterial(EMBLEM)
        emblemImage:SetKeepAspect(false)

        return frame, infoLabel
    end

    AmmoCacheUIFrench = {
        COLORS = COLORS,
        ICONS = ICONS,
        DrawFrenchBorder = DrawFrenchBorder,
        CreateFrenchButton = CreateFrenchButton,
        UpdateMenuUI = UpdateMenuUI,
        CreateDeployMenuUI = CreateDeployMenuUI
    }
end