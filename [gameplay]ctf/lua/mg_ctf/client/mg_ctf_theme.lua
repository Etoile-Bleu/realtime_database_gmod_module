-- This is a theme system, I have been using for a while.
-- I polished, optimised and reworked parts of it.

MG_CTF.Theme = {
	Frame = {},
	ListView = {},
	DMenu = {},
	Button = {},
	TextEntry = {},
	ComboBox = {},
	ScrollBar = {},
	Colors = {},
}

MG_CTF.Theme.FirstColor = {150, 20, 20}
MG_CTF.Theme.SecondColor = {255, 60, 60}

local Theme = MG_CTF.Theme

function Theme:GetColor(name, color, alpha)
	alpha = alpha or 255

	local full_name = name..alpha

	Theme.Colors[full_name] = Theme.Colors[full_name] or Color(color[1], color[2], color[3], alpha)

	return Theme.Colors[full_name]
end

function Theme:GetFirstColor(alpha)
	return Theme:GetColor("First", Theme.FirstColor, alpha)
end

function Theme:GetSecondColor(alpha)
	return Theme:GetColor("Second", Theme.SecondColor, alpha)
end

local colors = {
	Color(0, 0, 0, 150),
	Color(20, 20, 20, 255),
	Color(25, 25, 25, 255),
	Color(30, 30, 30, 255),
	Color(35, 35, 35, 255),
	Color(35, 35, 35, 230),
	Color(45, 45, 45, 255),
	Color(45, 45, 45, 230),
	Color(50, 50, 50, 255),
	Color(50, 50, 50, 240),
	Color(60, 60, 60, 255),
	Color(100, 100, 100, 200),
	Color(150, 150, 150, 255),
	Color(150, 150, 150, 5),
	Color(200, 200, 200, 255),
	Color(255, 255, 255, 1),
	Color(255, 255, 255, 200),
}

Theme.Frame.Paint = function(s, w, h)
	draw.RoundedBox(0, 0, 0, w, 24, colors[4])
	draw.RoundedBox(0, 0, 23, w, 1, Theme:GetFirstColor())
	draw.RoundedBox(0, 0, 24, w, h - 24, colors[10])

	draw.RoundedBox(0, w - 100, 0, 100, 23, colors[4])
end

Theme.Frame.Setup = function(frame) 
	frame.Paint = Theme.Frame.Paint

	frame:ShowCloseButton(false)

	local close = vgui.Create("DButton", frame)
	close:SetSize(40, 24)
	close:SetPos(frame:GetWide() - close:GetWide(), 0)
	close:SetTextColor(color_white)
	close:SetFont("Marlett")
	close:SetText("r")

	close.DoClick = function()
		frame:Close()

		surface.PlaySound("ui/buttonclick.wav")
	end

	close.Paint = function(slf, w, h)
		if slf:IsHovered() then
			draw.RoundedBox(0, 0, 0, w, h - 1, Theme:GetSecondColor())
		end
	end
end

Theme.ListView.Paint = function(s, w, h)
	draw.RoundedBox(0, 0, 0, w, h, colors[1])
end

Theme.ListView.Setup = function(list)
	list.Paint = Theme.ListView.Paint
	list:SetHeaderHeight(25)
	list:SetDataHeight(20)

	for _, v in pairs(list.Lines) do
		for i, c in pairs(v.Columns) do

			function c:UpdateColours()
				local parent = self:GetParent()

				if parent.ColumnColors and parent.ColumnColors[i] then
					return self:SetColor(parent.ColumnColors[i])
				end

				if parent:IsSelected() then
					self:SetColor(color_white)
				else
					self:SetColor(colors[15])
				end
			end

			c:SetContentAlignment(5)
		end

	    function v:Paint(w, h)
	    	if self:IsSelected() then
	    		return draw.RoundedBox(0, 0, 0, w, list:GetDataHeight(), Theme:GetFirstColor(100))
			end

	    	if self.BackgroundColor then
	    		return draw.RoundedBox(0, 0, 0, w, list:GetDataHeight(), self.BackgroundColor)
	    	end

	    	if self:IsHovered() then
	    		return draw.RoundedBox(0, 0, 0, w, list:GetDataHeight(), colors[12])
	    	end

		    draw.RoundedBox(0, 0, 0, w, list:GetDataHeight(), colors[7])
		    draw.RoundedBox(0, 0, 0, w, 1, colors[5])
	    end
	end

	for _, v in pairs(list.Columns) do
	    function v.Header:Paint(w, h)
	    	if self:IsHovered() then
	    		self:SetTextColor(Theme:GetFirstColor())
				draw.RoundedBox(0, 0, 0, w, h, Theme:GetFirstColor())
				draw.RoundedBox(0, 1, 1, w - 2, h - 2, colors[2])
	    	else
				self:SetTextColor(colors[13])
				draw.RoundedBox(0, 0, 0, w, h, Theme:GetFirstColor(100))
				draw.RoundedBox(0, 1, 1, w - 2, h - 2, colors[3])
			end
	    end
	end
	Theme.ScrollBar.Setup(list.VBar)
end

Theme.DMenu.Setup = function(menu)
	menu.Paint = Theme.DMenu.Paint
	menu.fAddOption = menu.AddOption
	menu.fAddSubMenu = menu.AddSubMenu

	function menu:AddOption(...)
		local opt = menu:fAddOption(...)
		opt.Paint = Theme.DMenu.OptionPaint
		return opt
	end

	function menu:AddSubMenu(...)
		local submenu, parent = menu:fAddSubMenu(...)
		parent.Paint = Theme.DMenu.OptionPaint
		return submenu, parent
	end
end

Theme.DMenu.Paint = function(s, w, h)
	draw.RoundedBox(0, 0, 0, w, h, colors[3])
	draw.RoundedBox(0, 2, 2, w - 4, h - 4, colors[4])
end

Theme.DMenu.AddOption = function(menu, ...)
	local option = menu:AddOption(...)
	option.Paint = Theme.DMenu.OptionPaint

	return option
end

Theme.DMenu.AddSubMenu = function(menu, ...)
	local submenu, parent = menu:AddSubMenu(...)

	parent.Paint = Theme.DMenu.OptionPaint

	return submenu, parent
end

Theme.DMenu.OptionPaint = function(s, w, h)
	if s:IsHovered() then
		draw.RoundedBox(0, 0, 0, w, h, colors[16])
		draw.RoundedBox(0, 2, 2, w - 4, h- 4, colors[16])
		s:SetTextColor(Theme:GetFirstColor())
	else
		s:SetTextColor(colors[13])
	end
end

Theme.Button.Paint = function(s, w, h)
	draw.RoundedBox(0, 0, 0, w, h, colors[11])
	draw.RoundedBox(0, 2, 2, w - 4, h - 4, colors[5])

	if !s:IsHovered() and !s.AddHovered and !s.Colored then
		s.OldColor = s:GetTextColor()
	end

	if s:IsHovered() then
		draw.RoundedBox(0, 0, 0, w, h, colors[14])

		if !s.AddHovered and !s.Colored then
			s:SetTextColor(color_white)
			s.AddHovered = true
		end
	else
		if s.OldColor and !s.Colored then
			s:SetTextColor(s.OldColor)
		end

		s.AddHovered = false
	end
end 

Theme.Button.Setup = function(button) 
	button.Paint = Theme.Button.Paint

	if !button.Colored then
		button:SetTextColor(colors[15])
	end
end

Theme.TextEntry.Setup = function(text)
	text.Paint = Theme.TextEntry.Paint
end

Theme.TextEntry.Paint = function(s, w, h)
	draw.RoundedBox(0, 0, 0, w, h, colors[8])
	draw.RoundedBox(0, 2, 2, w - 4, h - 4, colors[6])

	if s.GetPlaceholderText and s.GetPlaceholderColor and s:GetPlaceholderText() and s:GetPlaceholderText():Trim() != "" and s:GetPlaceholderColor() and (!s:GetText() or s:GetText() == "" ) then
		local oldText = s:GetText()
		local str = s:GetPlaceholderText()

		s:SetText(str)
		s:DrawTextEntryText(s:GetPlaceholderColor(), color_black, color_white)
		s:SetText(oldText)
		return
	end

	s:DrawTextEntryText(color_white, color_black, color_white)
end

Theme.ComboBox.Setup = function(combo)
	combo.Paint = Theme.ComboBox.Paint

	function combo:DoClick()
		if self:IsMenuOpen() then
			return self:CloseMenu()
		end
		self:OpenMenu()
		if IsValid(self.Menu) then
			self.Menu.Paint = Theme.DMenu.Paint
			local options = self.Menu:GetCanvas():GetChildren()
			for _, opt in ipairs(options) do
				opt.Paint = Theme.DMenu.OptionPaint
			end
		end
	end
end

Theme.ComboBox.Paint = function(s, w, h)
	draw.RoundedBox(0, 0, 0, w, h, colors[8])
	draw.RoundedBox(0, 2, 2, w - 4, h - 4, colors[6])
	s:DrawTextEntryText(colors[17], color_black, color_white)
end

Theme.ScrollBar.Setup = function(scroll)
	function scroll:Paint(w, h)
		draw.RoundedBox(0, 0, 0, w, h, colors[5])
	end

	function scroll.btnUp:Paint(w, h)
		draw.RoundedBox(0, 0, 0, w, h, colors[3])
		draw.RoundedBox(0, 0, h - 1, w, 1, colors[9])
	end

	function scroll.btnDown:Paint(w,h)
		draw.RoundedBox(0, 0, 0, w, h, colors[3])
		draw.RoundedBox(0, 0, 0, w, 1, colors[9])
	end

	function scroll.btnGrip:Paint(w, h)
		draw.RoundedBox(0, 0, 0, w, h, colors[3])
	end
end