include("shared.lua")

MG_CTF.Editor = MG_CTF.Editor or {}

-- Fonts

MG_CTF.MenuFont = "MG_CTF_Menu"

surface.CreateFont("MG_CTF_Menu", {font = "Roboto", size = 16, weight = 400, shadow = false})
surface.CreateFont("MG_CTF_Menu2", {font = "Roboto", size = 18, weight = 800, shadow = false})
surface.CreateFont("MG_CTF_Menu3", {font = "Roboto", size = 14, weight = 800, shadow = false})
surface.CreateFont("MG_CTF_Menu4", {font = "Roboto", size = 22, weight = 800, shadow = true})

local FontOffset = 9 -- Used for labels

-- Theme for the editor

function MG_CTF.AdjustSize(parent, frame, deduct) -- Adjusts size, in case there is a scroll bar
	local oldThink = frame.Think

	frame.Think = function(self)
		if oldThink then
			oldThink(self)
		end

		local scroll = parent.VBar
		if IsValid(scroll) and scroll:IsVisible() then -- If a scroll bar exists, we have to reduce the size of the panel
			if !self.ScrollbarFix then
				self.ScrollbarFix = true
				self:SetWide(self:GetWide() - 10)
			end
		else
			if self.ScrollbarFix then
				self.ScrollbarFix = false
				self:SetWide(self:GetWide() + 10)
			end
		end
	end
end

local colors = {
	Color(0, 0, 0, 150),
	Color(75, 75, 75, 150)
}
function MG_CTF.AddPanel(parent, text, y, texty) -- Adds a simple panel
	local frame = vgui.Create("DFrame")
	frame:SetSize(parent:GetWide(), y or 30)
	frame:SetDraggable(false)
	frame:ShowCloseButton(false)
	frame:SetTitle("")

	frame.Paint = function(self, w, h)
		draw.RoundedBox(0, 0, 0, w, h, colors[1])
		draw.RoundedBox(0, 1, 1, w - 2, h - 2, colors[2])
	end

	local label = vgui.Create("DLabel", frame)
	label:SetPos(10, texty or frame:GetTall() / 2 - FontOffset)
	label:SetFont(MG_CTF.MenuFont)
	label:SetText(text)
	label:SetTextColor(Color(200, 200, 200))
	label:SizeToContents()

	return frame, label
end

function MG_CTF.AddTextEntry(parent, text, tab, typ, def, placeholder, tbl) -- Adds a text entry
	tbl = tbl or MG_CTF.Editor

	local old_val
	if istable(tbl) then -- Setup preferred data type onto table
		if typ == "integer" then
			tbl[tab] = isnumber(def) and def or nil
		elseif typ != "vector" and typ != "color" then
			tbl[tab] = isstring(def) and def or nil
		end

		old_val = tbl[tab]
	end

	local frame, label = MG_CTF.AddPanel(parent, text)

	local w = MG_CTF.GetTextSize(text, MG_CTF.MenuFont)

	local frame_wid = frame:GetWide() * 0.25
	w = w > frame_wid and w or frame_wid

	local entry = vgui.Create("DTextEntry", frame)
	entry:SetSize(frame:GetWide() - w - 40, 20)
	entry:SetPos(20 + w, 5)
	entry:SetFont(MG_CTF.MenuFont)
	entry:SetValue(def or "")

	if placeholder then
		entry:SetPlaceholderText(placeholder)
	end

	if typ == "integer" then
		entry:SetNumeric(true)
	end

	entry.OnChange = function(self) -- Rather complex logic for the many different data types, this addon supports
		local val = entry:GetValue()

		if istable(tbl) then
			if typ == "integer" then
				val = tonumber(val)

				tbl[tab] = val
			else
				val = tostring(val)

				if typ == "vector" or typ == "color" then
					local newpos = string.Explode(",", val)

					if tonumber(newpos[1]) and tonumber(newpos[2]) and tonumber(newpos[3]) then
						if typ == "vector" then
							tbl[tab] = Vector(tonumber(string.Trim(newpos[1])), tonumber(string.Trim(newpos[2])), tonumber(string.Trim(newpos[3])))
						else
							tbl[tab] = {math.floor(tonumber(string.Trim(newpos[1]))), math.floor(tonumber(string.Trim(newpos[2]))), math.floor(tonumber(string.Trim(newpos[3]))), math.floor(tonumber(string.Trim(newpos[4] or 255)) or 255)}
						end

						self.Warned = nil
					else
						tbl[tab] = old_val

						if !self.Warned then
							self.Warned = true
							chat.AddText(Color(255, 0, 0), MG_CTF.Translate("editor_"..(typ == "color" and "color" or "vector").."_error", os.date("%H:%M:%S", os.time()), tab))
						end
					end
				else
					tbl[tab] = val and string.Trim(val) != "" and string.Trim(val)
				end
			end
		elseif isfunction(tbl) then
			tbl(string.Trim(entry:GetValue()))
		end
	end

	MG_CTF.AdjustSize(parent, entry, 10)

	MG_CTF.Theme.TextEntry.Setup(entry)

	parent:AddItem(frame)
	return entry
end

function MG_CTF.AddCheckBox(parent, text, tab, def, tbl) -- Adds a checkbox
	tbl = tbl or MG_CTF.Editor

	tbl[tab] = def

	local frame, label = MG_CTF.AddPanel(parent, text)

	local w = MG_CTF.GetTextSize(text, MG_CTF.MenuFont)

	local frame_wid = frame:GetWide() * 0.25
	w = w > frame_wid and w or frame_wid

	local checkbox = vgui.Create("DButton", frame)
	checkbox:SetSize(frame:GetWide() - w - 40, 20)
	checkbox:SetPos(20 + w, 5)

	checkbox.Setup = function(self)
		self:SetTextColor(self.Value and Color(0, 200, 0) or Color(200, 0, 0))

		self:SetFont(MG_CTF.MenuFont)
		self:SetText(self.Value and "✔" or "✖")
	end

	checkbox.Value = def and true or false
	checkbox:Setup()

	checkbox.DoClick = function(self)
		surface.PlaySound("ui/buttonclick.wav")

		self.Value = !self.Value

		tbl[tab] = self.Value

		checkbox:Setup()
	end

	checkbox.Colored = true

	MG_CTF.AdjustSize(parent, checkbox, 10)

	MG_CTF.Theme.Button.Setup(checkbox)

	parent:AddItem(frame)
	return checkbox
end

function MG_CTF.AddComboBox(parent, text, tab, def, full_tab, tbl) -- Adds a combo box
	tbl = tbl or MG_CTF.Editor

	tbl[tab] = def

	local old_val = tbl[tab]

	local frame, label = MG_CTF.AddPanel(parent, text)

	local w = MG_CTF.GetTextSize(text, MG_CTF.MenuFont)

	local frame_wid = frame:GetWide() * 0.25
	w = w > frame_wid and w or frame_wid

	local combobox = vgui.Create("DComboBox", frame)
	combobox:SetSize(frame:GetWide() - w - 40, 20)

	combobox:SetPos(20 + w, 5)
	combobox:SetTextColor(Color(180, 180, 180))
	combobox:SetFont(MG_CTF.MenuFont)

	function combobox:OnSelect(index, text, data)
		tbl[tab] = data
	end

	for k, v in pairs(full_tab) do
		local select = false
		if tonumber(def) == k then
			select = true
		end
		combobox:AddChoice(v, k, select)
	end

	MG_CTF.AdjustSize(parent, combobox, 10)

	MG_CTF.Theme.ComboBox.Setup(combobox)

	parent:AddItem(frame)
	return combobox
end

function MG_CTF.AddListView(parent, text, tall) -- Adds a list view, which then can be customized
	local frame, label = MG_CTF.AddPanel(parent, text or "", tall or parent:GetTall() - 95, 5)

	local w, h = 0, 0
	if text and text != "" then
		w, h = MG_CTF.GetTextSize(text, MG_CTF.MenuFont)
	end

	local listview = vgui.Create("DListView", frame)
	listview:SetSize(frame:GetWide() - 30, tall and tall - 20 - h or parent:GetTall() - 115 - h)
	listview:SetPos(10, 10 + h)
	listview:SetMultiSelect(false)

	local oldThink = listview.Think
	listview.Think = function(self) -- This is a hack for scroll bars. Unfortunately, it's extremely hard to edit the scroll bar of a listview element, so we gotta work around it.
		local column = self.Columns[1]
		if column then
			local scroll = self.VBar
			local scroll2 = parent.VBar

			scroll = IsValid(scroll) and scroll:IsVisible()
			scroll2 = IsValid(scroll2) and scroll2:IsVisible()

			if scroll and !column.ScrollbarFix then
				column.ScrollbarFix = true

				local width = column:GetMinWidth()
				column:SetFixedWidth(width - 16)
			end

			if scroll2 and !column.ScrollbarFix2 then
				column.ScrollbarFix2 = true

				local width = column:GetMinWidth()
				column:SetFixedWidth(width - 16)
			end

			if !scroll and column.ScrollbarFix then
				column.ScrollbarFix = false
	
				local width = column:GetMinWidth()
				column:SetFixedWidth(width + 16)
			end

			if !scroll2 and column.ScrollbarFix2 then
				column.ScrollbarFix = false
	
				local width = column:GetMinWidth()
				column:SetFixedWidth(width + 16)
			end
		end

		if oldThink then
			oldThink(self)
		end
	end

	MG_CTF.AdjustSize(parent, listview, 10)

	parent:AddItem(frame)
	return listview
end

function MG_CTF.AddButton(parent, text, callback, tall, paint) -- Adds a generic button
	local button = vgui.Create("DButton", parent)
	button:SetTall(tall or 25)
	button:SetFont(MG_CTF.MenuFont)
	button:SetText(text)
	button.DoClick = function()
		surface.PlaySound("ui/buttonclick.wav")

		callback()
	end

	parent:AddItem(button)
	MG_CTF.Theme.Button.Setup(button)

	if paint then
		button.Paint = function(self, w, h)
			paint(self, w, h)
		end
	end

	return button
end

function MG_CTF.AddCloseButton(parent, ent, callback, name) -- Adds a close button to the frame
	local button = MG_CTF.AddButton(parent, name or MG_CTF.Translate("editor_save"), function()
		if !callback then
			if IsValid(ent) then
				local data, size = MG_CTF.Compress(MG_CTF.Editor)

				net.Start("MG_CTF_Edit")
					net.WriteEntity(ent)
					net.WriteUInt(size, 16)
					net.WriteData(data, size)
				net.SendToServer()
			end

			if IsValid(MG_CTF.Settings) then
				MG_CTF.Settings:Remove()
			end
		else
			callback()
		end
	end, 30)

	button:SetFont("MG_CTF_Menu2")
	button:SetTextColor(Color(0, 200, 0))

	return button, frame
end

local colors = {
	Color(40, 40, 40, 255),
	Color(25, 25, 25, 255),
	Color(200, 200, 200, 255),
}
function MG_CTF.AddCategoryHeader(parent, text, y) -- Adds a category header
	local frame = vgui.Create("DFrame")
	frame:SetSize(parent:GetWide(), y or 30)
	frame:SetDraggable(false)
	frame:ShowCloseButton(false)
	frame:SetTitle("")

	frame.Paint = function(self, w, h)
		draw.RoundedBox(0, 0, 0, w, h, colors[1])
		draw.RoundedBox(0, 2, 2, w - 4, h - 4, colors[2])
		draw.SimpleText(text, "MG_CTF_Menu4", w / 2, h / 2, colors[3], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	parent:AddItem(frame)

	return frame, label
end

local mainframe
function MG_CTF.AddTextEntryBox(parent, text, tab, typ, callback, def, placeholder) -- Creates a frame with a text entry inside, with a callback
	if IsValid(mainframe) then return end

	mainframe = vgui.Create("DFrame")
	mainframe:SetSize(parent:GetWide() * 0.75, 100)
	mainframe:SetTitle("")
	mainframe:SetDraggable(true)
	mainframe:Center()
	mainframe:MakePopup()

	local oldThink = mainframe.Think
	mainframe.Think = function(self)
		oldThink(self)

		if !IsValid(parent) then
			self:Remove()
		end
	end

	MG_CTF.Theme.Frame.Setup(mainframe)

	local settings = vgui.Create("DPanelList", mainframe)
	settings:StretchToParent(0, 25, 0, 0)
	settings:EnableVerticalScrollbar(true)
	settings:SetPadding(5)
	settings:SetSpacing(5)

	local final_val = def
	MG_CTF.AddTextEntry(settings, text..":", tab, typ, def, placeholder, function(text)
		final_val = text
	end)

	MG_CTF.AddCloseButton(settings, nil, function()
		callback(final_val)

		mainframe:Remove()
	end, MG_CTF.Translate("editor_apply"))

	return button
end