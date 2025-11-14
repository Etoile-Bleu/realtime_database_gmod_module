include("shared.lua")

-- Editor

local edit_tbl = {}

local settings_pnl
local main_ent

function MG_CTF.OpenMainConfig(parent, ent, name) -- Main
	MG_CTF.OpenCategory(parent, ent, name, function()
		MG_CTF.AddTextEntry(parent, MG_CTF.Translate("editor_name"), "name", "string", MG_CTF.GetFlagEntityName(edit_tbl.name))

		MG_CTF.AddTextEntry(parent, MG_CTF.Translate("editor_minplayers"), "minplayers", "integer", edit_tbl.minplayers, "0")

		MG_CTF.AddTextEntry(parent, MG_CTF.Translate("editor_minplayers_area"), "minplayers_area", "integer", edit_tbl.minplayers_area, "0")

		MG_CTF.AddCheckBox(parent, MG_CTF.Translate("editor_usetostart"), "usetostart", edit_tbl.usetostart and true or false)

		MG_CTF.AddTextEntry(parent, MG_CTF.Translate("editor_capturetime"), "capturetime", "integer", edit_tbl.capturetime, tostring(MG_CTF.Config.DefaultCaptureTime))

		MG_CTF.AddTextEntry(parent, MG_CTF.Translate("editor_uncapturetime"), "uncapturetime", "integer", edit_tbl.uncapturetime, tostring(MG_CTF.Config.DefaultUncaptureTime))

		MG_CTF.AddCheckBox(parent, MG_CTF.Translate("editor_not_persistant"), "not_persistant", edit_tbl.not_persistant and true or false)
	end)
end

local AddButtons
local EditPanel
local function OpenFactionEditor(parent, name, tbl, main_tbl)
	if IsValid(EditPanel) then
		EditPanel:Remove()
	end

	if !IsValid(parent) then return end

	tbl = tbl or {}

	tbl.members = tbl.members or {}
	tbl.enemies = tbl.enemies or {}

	EditPanel = vgui.Create("DFrame")
	EditPanel:SetSize(parent:GetWide() * 0.9, ScrH() * 0.8)
	EditPanel:SetTitle(MG_CTF.Translate("editor_faction_editor", name != "" and name or MG_CTF.Translate("editor_faction_editor_new")))
	EditPanel:SetDraggable(true)
	EditPanel:Center()
	EditPanel:MakePopup()

	MG_CTF.Theme.Frame.Setup(EditPanel)

	local oldThink = EditPanel.Think
	EditPanel.Think = function(self) -- Remove on deletion of parent
		oldThink(self)

		if !IsValid(parent) or tostring(parent.Category) != tostring(MG_CTF.Translate("editor_faction_manage")) then
			self:Remove()
		end
	end
	
	local settings = vgui.Create("DPanelList", EditPanel)
	settings:StretchToParent(0, 25, 0, 5)
	settings:EnableVerticalScrollbar(true)
	settings:SetPadding(5)
	settings:SetSpacing(5)

	if settings.VBar then
		MG_CTF.Theme.ScrollBar.Setup(settings.VBar)
	end

	local new_name = MG_CTF.AddTextEntry(settings, MG_CTF.Translate("editor_faction_editor_name"), "name", "string", name or tbl.name)

	-- Friends list

	local listview = MG_CTF.AddListView(settings, MG_CTF.Translate("editor_faction_editor_allowed"), 250) -- Complicated creation of a wild DListView with a fixed size of 250 width

	local mainline = listview:AddColumn(MG_CTF.Translate("editor_faction_editor_team"))

	local min = 50
	local max = listview:GetWide() / 2

	local w = math.Clamp(MG_CTF.GetTextSize(MG_CTF.Translate("editor_faction_editor_associated"), "DermaDefault") + 10, min, max)
	listview:AddColumn(MG_CTF.Translate("editor_faction_editor_associated")):SetFixedWidth(w)

	mainline:SetFixedWidth(listview:GetWide() - w)

	listview.UpdateList = function()
		listview:Clear()

		for id, tab in pairs(MG_CTF.GetTeams()) do
			local use_id = tab.command or id

			local line = listview:AddLine(tab.name or tab.Name or id, !tbl.members[use_id] and "✖" or "✔")

			line.ColumnColors = line.ColumnColors or {}
			line.ColumnColors[2] = !tbl.members[use_id] and Color(200, 0, 0) or Color(0, 200, 0)

			line.ID = id
			line.Team = tab
		end

		MG_CTF.Theme.ListView.Setup(listview)
	end

	listview.OnRowSelected = function(lst, index, pnl)
		local id = pnl.ID
		local tab = pnl.Team

		local menu = DermaMenu(listview)

		MG_CTF.Theme.DMenu.Setup(menu)

		local use_id = tab.command or id

		menu:AddOption(MG_CTF.Translate("editor_faction_editor_switch"), function()
			tbl.members[use_id] = !tbl.members[use_id] and true or nil

			listview.UpdateList()
		end)

		menu:AddOption(MG_CTF.Translate("editor_faction_editor_switch_all"), function()
			for id, tab in pairs(MG_CTF.GetTeams()) do
				local use_id = tab.command or id

				tbl.members[use_id] = !tbl.members[use_id] and true or nil
			end

			listview.UpdateList()
		end)

		menu:Open()
	end

	listview.UpdateList()

	-- Enemy list

	local listview = MG_CTF.AddListView(settings, MG_CTF.Translate("editor_faction_editor_enemies"), 250) -- Enemy list

	local mainline = listview:AddColumn(MG_CTF.Translate("editor_faction_editor_faction"))

	local min = 50
	local max = listview:GetWide() / 2

	local w = math.Clamp(MG_CTF.GetTextSize(MG_CTF.Translate("editor_faction_editor_enemy"), "DermaDefault") + 10, min, max)
	listview:AddColumn(MG_CTF.Translate("editor_faction_editor_enemy")):SetFixedWidth(w)

	mainline:SetFixedWidth(listview:GetWide() - w)

	listview.UpdateList = function()
		listview:Clear()

		for id, tab in pairs(main_tbl) do
			if name != id then
				local line = listview:AddLine(id, !tbl.enemies[id] and "✖" or "✔")

				line.ColumnColors = line.ColumnColors or {}
				line.ColumnColors[2] = !tbl.enemies[id] and Color(200, 0, 0) or Color(0, 200, 0)

				line.ID = id
				line.Team = tab
			end
		end

		MG_CTF.Theme.ListView.Setup(listview)
	end

	listview.OnRowSelected = function(lst, index, pnl)
		local id = pnl.ID
		local tab = pnl.Team

		local menu = DermaMenu(listview)

		MG_CTF.Theme.DMenu.Setup(menu)

		menu:AddOption(MG_CTF.Translate("editor_faction_editor_switch"), function()
			tbl.enemies[id] = !tbl.enemies[id] and true or nil

			listview.UpdateList()
		end)

		menu:AddOption(MG_CTF.Translate("editor_faction_editor_switch_all"), function()
			for id, tab in pairs(main_tbl) do
				tbl.enemies[id] = !tbl.enemies[id] and true or nil
			end

			listview.UpdateList()
		end)

		menu:Open()
	end

	listview.UpdateList()

	MG_CTF.AddTextEntry(settings, MG_CTF.Translate("editor_faction_editor_color"), "color", "color", istable(tbl.color) and table.concat(tbl.color, ", ") or "", "255, 255, 255", tbl)

	MG_CTF.AddTextEntry(settings, MG_CTF.Translate("editor_faction_editor_capturespeed"), "capturespeed", "integer", tbl.capturespeed, "1", tbl)

	MG_CTF.AddTextEntry(settings, MG_CTF.Translate("editor_faction_editor_uncapturespeed"), "uncapturespeed", "integer", tbl.uncapturespeed, "1", tbl)

	MG_CTF.AddTextEntry(settings, MG_CTF.Translate("editor_faction_editor_maxzones"), "maxzones", "integer", tbl.maxzones, "0", tbl)

	MG_CTF.AddCloseButton(settings, ent, function()
		local val = string.Trim(new_name:GetValue())
		if val == "" then
			chat.AddText(Color(255, 0, 0), MG_CTF.Translate("editor_faction_editor_error", os.date("%H:%M:%S", os.time())))
			return
		end

		main_tbl[val] = table.Copy(tbl) -- Copy values to new table

		if name and name != val then -- Delete old table, if existant
			main_tbl[name] = nil
		end

		AddButtons()

		EditPanel:Remove()
	end, MG_CTF.Translate("editor_faction_editor_save"))
end

function MG_CTF.OpenFactionSetup(parent, ent, name) -- Faction setup
	MG_CTF.OpenCategory(parent, ent, name, function()
		local factions = table.Copy(MG_CTF.GetFactions()) -- Cache factions


		for k, v in pairs(factions) do
			if istable(v.members) then
				local newmembers = {} -- Create new members table and delete old one

				for id, allowed in pairs(v.members) do
					if allowed then
						newmembers[MG_CTF.ResolveID(id)] = true -- Conversion to actual team IDs
					end
				end

				v.members = {}

				for id, allowed in pairs(newmembers) do
					v.members[id] = allowed
				end
			end
		end

		local todelete = {}

		function AddButtons()
			if !IsValid(parent) or tostring(parent.Category) != tostring(MG_CTF.Translate("editor_faction_manage")) then return end

			for _, v in ipairs(todelete) do
				if IsValid(v) then
					v:Remove()
				end
			end
			table.Empty(todelete)

			for id, data in pairs(factions) do
				local button = MG_CTF.AddButton(parent, id, function()
					local menu = DermaMenu()

					MG_CTF.Theme.DMenu.Setup(menu)

					menu:AddOption(MG_CTF.Translate("editor_faction_edit"), function()
						OpenFactionEditor(parent, id, data, factions)
					end)

					menu:AddOption(MG_CTF.Translate("editor_faction_remove"), function()
						factions[id] = nil

						AddButtons()
					end)

					menu:Open()
				end)
				table.insert(todelete, button)
			end

			local button = MG_CTF.AddButton(parent, MG_CTF.Translate("editor_faction_add"), function()
				OpenFactionEditor(parent, nil, nil, factions)
			end)
			table.insert(todelete, button)

			local button, frame = MG_CTF.AddCloseButton(parent, ent, function()
				local data, size = MG_CTF.Compress(factions)

				net.Start("MG_CTF_EditFactions")
					net.WriteUInt(size, 16)
					net.WriteData(data, size)
				net.SendToServer()
			end, MG_CTF.Translate("editor_faction_save"))

			table.insert(todelete, button)
			table.insert(todelete, frame)
		end

		AddButtons()
	end, true)
end

function MG_CTF.OpenFactionRestrictions(parent, ent, name) -- Restrict factions
	MG_CTF.OpenCategory(parent, ent, name, function()
		edit_tbl.ignore_factions = edit_tbl.ignore_factions or {} -- Create tables, if they do not exist
		edit_tbl.default_faction = edit_tbl.default_faction or nil

		edit_tbl.capture_modify = edit_tbl.capture_modify or {}
		edit_tbl.uncapture_modify = edit_tbl.uncapture_modify or {}

		local ignore = edit_tbl.ignore_factions
		local def = edit_tbl.default_faction

		local cap_modify = edit_tbl.capture_modify
		local uncap_modify = edit_tbl.uncapture_modify

		local listview = MG_CTF.AddListView(parent)

		local mainline = listview:AddColumn(MG_CTF.Translate("editor_restrict_faction"))

		local min = 50 -- Here begins language stretching
		local max = listview:GetWide() / 5

		local w1 = math.Clamp(MG_CTF.GetTextSize(MG_CTF.Translate("editor_restrict_allowed"), "DermaDefault") + 10, min, max)
		listview:AddColumn(MG_CTF.Translate("editor_restrict_allowed")):SetFixedWidth(w1)

		local w2 = math.Clamp(MG_CTF.GetTextSize(MG_CTF.Translate("editor_restrict_default"), "DermaDefault") + 10, min, max)
		listview:AddColumn(MG_CTF.Translate("editor_restrict_default")):SetFixedWidth(w2)

		local w3 = math.Clamp(MG_CTF.GetTextSize(MG_CTF.Translate("editor_restrict_capturespeed"), "DermaDefault") + 10, min, max)
		listview:AddColumn(MG_CTF.Translate("editor_restrict_capturespeed")):SetFixedWidth(w3)

		local w4 = math.Clamp(MG_CTF.GetTextSize(MG_CTF.Translate("editor_restrict_uncapturespeed"), "DermaDefault") + 10, min, max)
		listview:AddColumn(MG_CTF.Translate("editor_restrict_uncapturespeed")):SetFixedWidth(w4)

		mainline:SetFixedWidth(listview:GetWide() - w1 - w2 - w3 - w4)

		listview.UpdateList = function()
			listview:Clear()

			for faction, tab in pairs(MG_CTF.GetFactions()) do
				local line = listview:AddLine(faction,
					ignore[faction] and "✖" or "✔",
					(!def or def != faction) and "✖" or "✔",
					cap_modify[faction] and "x"..cap_modify[faction]or "x1",
					uncap_modify[faction] and "x"..uncap_modify[faction] or "x1"
				)

				line.ColumnColors = line.ColumnColors or {}
				line.ColumnColors[2] = (ignore[faction] and Color(200, 0, 0) or Color(0, 200, 0))
				line.ColumnColors[3] = ((!def or def != faction) and Color(200, 0, 0) or Color(0, 200, 0))
				line.ColumnColors[4] = (!cap_modify[faction] and Color(200, 0, 0) or Color(0, 200, 0))
				line.ColumnColors[5] = (!uncap_modify[faction] and Color(200, 0, 0) or Color(0, 200, 0))
			end

			MG_CTF.Theme.ListView.Setup(listview)
		end

		listview.OnRowSelected = function(lst, index, pnl)
			local faction = IsValid(pnl) and pnl:GetValue(1)
			if !faction then return end

			local menu = DermaMenu(listview)

			MG_CTF.Theme.DMenu.Setup(menu)

			menu:AddOption(!ignore[faction] and MG_CTF.Translate("editor_restrict_setallowance") or MG_CTF.Translate("editor_restrict_unsetallowance"), function()
				ignore[faction] = !ignore[faction]

				listview.UpdateList()
			end)

			menu:AddOption((!def or def != faction) and MG_CTF.Translate("editor_restrict_setdefault") or MG_CTF.Translate("editor_restrict_unsetdefault"), function()
				edit_tbl.default_faction = (!edit_tbl.default_faction or edit_tbl.default_faction != faction) and faction or nil -- Set new value
				def = edit_tbl.default_faction

				listview.UpdateList()
			end)

			menu:AddOption(MG_CTF.Translate("editor_restrict_setcapturetime"), function()
				MG_CTF.AddTextEntryBox(parent, MG_CTF.Translate("editor_restrict_setcapturetime"), "cap_modify", "integer", function(value)
					value = tonumber(value) or 1
					cap_modify[faction] = value != 1 and value or nil

					listview.UpdateList()
				end, cap_modify[faction], "1")

				listview.UpdateList()
			end)

			menu:AddOption(MG_CTF.Translate("editor_restrict_setuncapturetime"), function()
				MG_CTF.AddTextEntryBox(parent, MG_CTF.Translate("editor_restrict_setcapturetime"), "uncap_modify", "integer", function(value)
					value = tonumber(value) or 1
					uncap_modify[faction] = value != 1 and value or nil

					listview.UpdateList()
				end, uncap_modify[faction], "1")
			end)

			menu:Open()
		end

		listview.UpdateList()
	end)
end

function MG_CTF.OpenRewardConfig(parent, ent, name) -- Rewards
	MG_CTF.OpenCategory(parent, ent, name, function()
		MG_CTF.AddCheckBox(parent, MG_CTF.Translate("editor_rewards_shared"), "shared_rewards", edit_tbl.shared_rewards and true or false)

		edit_tbl.rewards = edit_tbl.rewards or {} -- Create rewards table

		for _, v in ipairs(MG_CTF.Config.RewardTypes) do
			local id, name = v.id, v.name
			if !id or !name then continue end

			id = tostring(id)
			name = isfunction(name) and name() or tostring(name)

			if !id or !name then continue end

			edit_tbl.rewards[id] = edit_tbl.rewards[id] or {}
			local tbl = edit_tbl.rewards[id]

			MG_CTF.AddCategoryHeader(parent, MG_CTF.Translate("editor_rewards_cat", name), 25)

			MG_CTF.AddTextEntry(parent, MG_CTF.Translate("editor_rewards_capture", name), "capture", "integer", tbl.capture, "0", tbl)

			MG_CTF.AddCheckBox(parent, MG_CTF.Translate("editor_rewards_enable", name), "enable", tbl.enable and true or false, tbl)

			MG_CTF.AddTextEntry(parent, MG_CTF.Translate("editor_rewards_time", name), "time", "integer", tbl.time, "60", tbl)

			MG_CTF.AddTextEntry(parent, MG_CTF.Translate("editor_rewards_amount", name), "amount", "integer", tbl.amount, "10", tbl)

			MG_CTF.AddTextEntry(parent, MG_CTF.Translate("editor_rewards_max", name), "max", "integer", tbl.max, "100", tbl)

			MG_CTF.AddTextEntry(parent, MG_CTF.Translate("editor_rewards_split", name), "split", "integer", tbl.split, "1", tbl)
		end

		if IsValid(ent) and ent:GetClass() == "ctf_flag" then
			local button = MG_CTF.AddButton(parent, MG_CTF.Translate("editor_rewards_reset"), function()
				if IsValid(ent) then
					net.Start("MG_CTF_Reset")
						net.WriteEntity(ent)
					net.SendToServer()
				end
			end)
		end
	end)
end

function MG_CTF.OpenRenderConfig(parent, ent, name) -- Rendering
	MG_CTF.OpenCategory(parent, ent, name, function()
		local flag_ent = IsValid(ent) and ent:GetClass() == "ctf_flag" and ent

		MG_CTF.AddTextEntry(parent, MG_CTF.Translate("editor_model"), "model", "string", MG_CTF.GetFlagEntityModel(edit_tbl.model), tostring(MG_CTF.Config.DefaultModel))

		MG_CTF.AddCheckBox(parent, MG_CTF.Translate("editor_render_dont_color"), "dont_color", edit_tbl.dont_color and true or false)

		local color_tbl = flag_ent and flag_ent:GetColor()
		local color = flag_ent and table.concat(Color(color_tbl.r, color_tbl.g, color_tbl.b, color_tbl.a):ToTable(), ", ") or !flag_ent and istable(edit_tbl.color) and table.concat(edit_tbl.color, ", ") or ""

		MG_CTF.AddTextEntry(parent, MG_CTF.Translate("editor_render_color"), "color", "color", color, "255, 255, 255")

		MG_CTF.AddTextEntry(parent, MG_CTF.Translate("editor_render_material"), "material", "string", flag_ent and flag_ent:GetMaterial() or !flag_ent and edit_tbl.material or "", "models/wireframe")

		MG_CTF.AddCheckBox(parent, MG_CTF.Translate("editor_render_nodraw"), "nodraw", flag_ent and flag_ent:GetNoDraw() or !flag_ent and edit_tbl.nodraw)

		MG_CTF.AddCheckBox(parent, MG_CTF.Translate("editor_render_not_solid"), "not_solid", flag_ent and !flag_ent:IsSolid() or !flag_ent and edit_tbl.not_solid)

		MG_CTF.AddComboBox(parent, MG_CTF.Translate("editor_render_mode"), "render_mode", flag_ent and flag_ent:GetRenderMode() or !flag_ent and (edit_tbl.render_mode or RENDERMODE_NORMAL), MG_CTF.RenderModes)

		MG_CTF.AddComboBox(parent, MG_CTF.Translate("editor_render_fx"), "render_fx", flag_ent and flag_ent:GetRenderFX() or !flag_ent and (edit_tbl.render_fx or kRenderFxNone), MG_CTF.RenderFX)

		MG_CTF.AddTextEntry(parent, MG_CTF.Translate("editor_render_modelscale"), "modelscale", "integer", flag_ent and flag_ent:GetModelScale() or !flag_ent and edit_tbl.modelscale, "1")

		MG_CTF.AddTextEntry(parent, MG_CTF.Translate("editor_render_drawpos"), "drawpos", "vector", isvector(edit_tbl.drawpos) and (edit_tbl.drawpos[1]..", "..edit_tbl.drawpos[2]..", "..edit_tbl.drawpos[3]) or "0, 0, 25", "0, 0, 25")

		local vector = flag_ent and table.concat(flag_ent:GetPos():ToTable(), ", ") or edit_tbl.pos
		MG_CTF.AddTextEntry(parent, MG_CTF.Translate("editor_render_pos"), "pos", "vector", vector, "0, 0, 0")
	end)
end

function MG_CTF.OpenSoundConfig(parent, ent, name) -- Sound
	MG_CTF.OpenCategory(parent, ent, name, function()
		MG_CTF.AddCheckBox(parent, MG_CTF.Translate("editor_sound_capture_play"), "snd_capture_play", edit_tbl.snd_capture_play and true or false)

		MG_CTF.AddTextEntry(parent, MG_CTF.Translate("editor_sound_capture"), "snd_capture", "string", edit_tbl.snd_capture or "", "ui/buttonclick.wav")

		MG_CTF.AddTextEntry(parent, MG_CTF.Translate("editor_sound_capture_range"), "snd_capture_range", "integer", edit_tbl.snd_capture_range, "75")

		MG_CTF.AddTextEntry(parent, MG_CTF.Translate("editor_sound_capture_pitch"), "snd_capture_pitch", "integer", edit_tbl.snd_capture_pitch, "100")
	end)
end

function MG_CTF.OpenParticleEditor(parent, ent, name) -- Particle Editor
	MG_CTF.OpenCategory(parent, ent, name, function()
		MG_CTF.AddCategoryHeader(parent, MG_CTF.Translate("editor_effects_cat_capture"), 25)

		MG_CTF.AddCheckBox(parent, MG_CTF.Translate("editor_effects_capture_prevent"), "eff_capture_prevent", edit_tbl.eff_capture_prevent and true or false)

		MG_CTF.AddTextEntry(parent, MG_CTF.Translate("editor_effects_capture_material"), "eff_capture_material", "string", edit_tbl.eff_capture_material or "", "mg_ctf/star.png")

		MG_CTF.AddTextEntry(parent, MG_CTF.Translate("editor_effects_capture_size"), "eff_capture_size", "integer", edit_tbl.eff_capture_size, "1")

		MG_CTF.AddTextEntry(parent, MG_CTF.Translate("editor_effects_capture_particles"), "eff_capture_particles", "integer", edit_tbl.eff_capture_particles, "200")

		MG_CTF.AddTextEntry(parent, MG_CTF.Translate("editor_effects_capture_lifetime"), "eff_capture_lifetime", "integer", edit_tbl.eff_capture_lifetime, "8")

		MG_CTF.AddTextEntry(parent, MG_CTF.Translate("editor_effects_capture_range"), "eff_capture_range", "integer", edit_tbl.eff_capture_range, "1.75")

		MG_CTF.AddCategoryHeader(parent, MG_CTF.Translate("editor_effects_cat_collect"), 25)

		MG_CTF.AddCheckBox(parent, MG_CTF.Translate("editor_effects_collect_prevent"), "eff_collect_prevent", edit_tbl.eff_collect_prevent and true or false)

		MG_CTF.AddTextEntry(parent, MG_CTF.Translate("editor_effects_collect_material"), "eff_collect_material", "string", edit_tbl.eff_collect_material or "", "mg_ctf/reward.png")

		MG_CTF.AddTextEntry(parent, MG_CTF.Translate("editor_effects_collect_size"), "eff_collect_size", "integer", edit_tbl.eff_collect_size, "1")

		MG_CTF.AddTextEntry(parent, MG_CTF.Translate("editor_effects_collect_particles"), "eff_collect_particles", "integer", edit_tbl.eff_collect_particles, "50")

		MG_CTF.AddTextEntry(parent, MG_CTF.Translate("editor_effects_collect_lifetime"), "eff_collect_lifetime", "integer", edit_tbl.eff_collect_lifetime, "4")

		MG_CTF.AddTextEntry(parent, MG_CTF.Translate("editor_effects_collect_range"), "eff_collect_range", "integer", edit_tbl.eff_collect_range, "1")
	end)
end

function MG_CTF.OpenToolConfig(parent, ent, name) -- Tool settings
	MG_CTF.OpenCategory(parent, ent, name, function()
		MG_CTF.AddCheckBox(parent, MG_CTF.Translate("editor_tool_usesphere"), "zone_sphere", edit_tbl.zone_sphere and true or false)

		MG_CTF.AddTextEntry(parent, MG_CTF.Translate("editor_tool_spheresize"), "zone_size", "integer", edit_tbl.zone_size, tostring(MG_CTF.Config.DefaultSphereSize))
	end)
end

local function ZoneEditor(ent, id, sphere, remove)
	if IsValid(ent) then
		net.Start("MG_CTF_Zone")
			net.WriteEntity(ent)
			net.WriteUInt(id, 16)
			net.WriteBool(sphere and true or false)
			net.WriteBool(remove and true or false)
		net.SendToServer()
	end
end

local function ZoneSettings(ent, id, remove)
	local menu = DermaMenu()

	MG_CTF.Theme.DMenu.Setup(menu)

	menu:AddOption(MG_CTF.Translate("editor_zone_edit"), function()
		if IsValid(ent) then
			ZoneEditor(ent, id, add)
		end

		if !IsValid(settings_pnl) then return end
		settings_pnl:Remove()
	end)

	menu:AddOption(MG_CTF.Translate("editor_zone_sphere"), function()
		if IsValid(ent) then
			ZoneEditor(ent, id, add)
		end

		if !IsValid(settings_pnl) then return end
		settings_pnl:Remove()
	end)

	if remove then
		menu:AddOption(MG_CTF.Translate("editor_zone_remove"), function()
			if IsValid(ent) then
				ZoneEditor(ent, id, true, true)
			end

			if !IsValid(settings_pnl) then return end
			settings_pnl:Remove()
		end)
	end

	menu:Open()
end

function MG_CTF.OpenZoneEditor(parent, ent, name) -- Zone Editor
	MG_CTF.OpenCategory(parent, ent, name, function()
		local button = MG_CTF.AddButton(parent, MG_CTF.Translate("editor_zone_num", "0"), function()
			ZoneSettings(ent, 0, false)
		end)

		local zones = edit_tbl.zones or {} -- Existing zones add.
		for k, v in pairs(zones) do
			local button = MG_CTF.AddButton(parent, MG_CTF.Translate("editor_zone_num", k), function()
				ZoneSettings(ent, k, true)
			end)
		end

		local button = MG_CTF.AddButton(parent, MG_CTF.Translate("editor_zone_add"), function()
			ZoneSettings(ent, table.Count(zones) + 1, false)
		end)
	end)
end

function MG_CTF.CopyFromMap(parent, ent, name) -- Copy mode
	MG_CTF.OpenCategory(parent, ent, name, function()
		net.Start("MG_CTF_Copy")
			net.WriteBool(true)
		net.SendToServer()

		local todelete = {}
		net.Receive("MG_CTF_Copy", function()
			if !IsValid(parent) or tostring(parent.Category) != tostring(MG_CTF.Translate("editor_copy")) then return end

			local send = net.ReadBool() -- Did the server send some data?

			if send then
				for _, v in ipairs(todelete) do
					if IsValid(v) then
						v:Remove()
					end
				end
				table.Empty(todelete)

				local zones = MG_CTF.Decompress(net.ReadData(net.ReadUInt(16))) or {} -- Retrieve table from server

				for map, data in pairs(zones) do
					local button = MG_CTF.AddButton(parent, map, function()
						local menu = DermaMenu()

						MG_CTF.Theme.DMenu.Setup(menu)

						for _, v in ipairs(data) do -- Cycle through the data
							menu:AddOption(MG_CTF.Translate("editor_copy_zone", MG_CTF.GetFlagEntityName(v.name), v.id), function()
								if !IsValid(ent) then return end

								net.Start("MG_CTF_Copy")
									net.WriteBool(false)
									net.WriteString(map)
									net.WriteString(v.id)
									net.WriteEntity(ent)
								net.SendToServer()
							end)
						end

						menu:Open()
					end)
					table.insert(todelete, button)
				end

				local button, frame = MG_CTF.AddCloseButton(parent, ent)
				table.insert(todelete, button)
				table.insert(todelete, frame)
			else
				local new_tbl = MG_CTF.Decompress(net.ReadData(net.ReadUInt(16))) or {}

				table.Merge(edit_tbl, new_tbl) -- Merge these two
			end
		end)
	end, true)
end

function MG_CTF.OpenAdvertConfig(parent, ent, name) -- Adverts
	MG_CTF.OpenCategory(parent, ent, name, function()
		MG_CTF.AddCheckBox(parent, MG_CTF.Translate("editor_advert_global"), "advert_global", edit_tbl.advert_global and true or false)

		MG_CTF.AddCheckBox(parent, MG_CTF.Translate("editor_advert_anon"), "advert_anon", edit_tbl.advert_anon and true or false)

		MG_CTF.AddCategoryHeader(parent, MG_CTF.Translate("editor_adverts_cat"), 25)

		MG_CTF.AddCheckBox(parent, MG_CTF.Translate("editor_advert_transmit"), "advert_transmit", edit_tbl.advert_transmit and true or false)

		MG_CTF.AddCheckBox(parent, MG_CTF.Translate("editor_advert_capturesuccess"), "advert_capturesuccess", edit_tbl.advert_capturesuccess and true or false)

		MG_CTF.AddCheckBox(parent, MG_CTF.Translate("editor_advert_capturebegin"), "advert_capturebegin", edit_tbl.advert_capturebegin and true or false)

		MG_CTF.AddCheckBox(parent, MG_CTF.Translate("editor_advert_capturecancel"), "advert_capturecancel", edit_tbl.advert_capturecancel and true or false)
	end)
end

function MG_CTF.OpenCategory(parent, ent, name, callback, no_close)
	parent:Clear()

	parent.Category = name

	local scroll = parent.VBar
	if IsValid(scroll) then
		scroll:AnimateTo(0, 0) -- Reset scroll position
	end

	local button = MG_CTF.AddButton(parent, "", function()
		MG_CTF.AddBase(parent, ent)
	end, 40, function(self, w, h)
		draw.RoundedBox(0, 0, 0, w, h, Color(60, 60, 60))
		draw.RoundedBox(0, 2, 2, w - 4, h - 4, Color(35, 35, 35))

		local clr = Color(200, 200, 200)
		if self:IsHovered() then
			draw.RoundedBox(0, 0, 0, w, h, Color(150, 150, 150, 5))
			clr = color_white
		end

		draw.SimpleText(MG_CTF.Translate("editor_current")..name, "MG_CTF_Menu2", w / 2, 14, clr, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText(MG_CTF.Translate("editor_clickhere"), "MG_CTF_Menu3", w / 2, h - 11, clr, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end)

	callback()

	if !no_close then
		MG_CTF.AddCloseButton(parent, ent)
	end
end

function MG_CTF.AddBase(parent, ent)
	parent:Clear()

	parent.Category = nil

	MG_CTF.AddCategoryHeader(parent, MG_CTF.Translate("editor_cat")..MG_CTF.Translate("editor_cat_factions"))

	local name = MG_CTF.Translate("editor_faction_manage")

	MG_CTF.AddButton(parent, name, function()
		if !IsValid(ent) then return end
		MG_CTF.OpenFactionSetup(parent, ent, name)
	end)

	if IsValid(ent) and ent:GetClass() == "mg_ctf_setup" then
		MG_CTF.AddCategoryHeader(parent, MG_CTF.Translate("editor_cat")..MG_CTF.Translate("editor_cat_tool"))

		local name = MG_CTF.Translate("editor_tool")

		MG_CTF.AddButton(parent, name, function()
			if !IsValid(ent) then return end
			MG_CTF.OpenToolConfig(parent, ent, name)
		end)
	end

	MG_CTF.AddCategoryHeader(parent, MG_CTF.Translate("editor_cat")..MG_CTF.Translate("editor_cat_select"))

	local name = MG_CTF.Translate("editor_select")

	MG_CTF.AddButton(parent, name, function() -- Select a zone!
		net.Start("MG_CTF_AskZones")
			net.WriteBool(true)
		net.SendToServer()

		net.Receive("MG_CTF_AskZones", function()
			if !IsValid(settings_pnl) then return end

			local zones = MG_CTF.Decompress(net.ReadData(net.ReadUInt(16))) or {}

			local menu = DermaMenu()

			MG_CTF.Theme.DMenu.Setup(menu)

			for _, v in ipairs(zones) do
				menu:AddOption(MG_CTF.Translate("editor_select_zone", MG_CTF.GetFlagEntityName(v.name), v.id), function()
					net.Start("MG_CTF_AskZones")
						net.WriteBool(false)
						net.WriteString(v.id)
					net.SendToServer()
				end)
			end

			menu:Open()
		end)
	end)

	local name = MG_CTF.Translate("editor_copy")

	MG_CTF.AddButton(parent, name, function()
		if !IsValid(ent) then return end
		MG_CTF.CopyFromMap(parent, ent, name)
	end)

	MG_CTF.AddCategoryHeader(parent, MG_CTF.Translate("editor_cat")..MG_CTF.Translate("editor_cat_zone"))

	local name = MG_CTF.Translate("editor_main")

	MG_CTF.AddButton(parent, name, function()
		if !IsValid(ent) then return end
		MG_CTF.OpenMainConfig(parent, ent, name)
	end)

	local is_flag = IsValid(ent) and ent:GetClass() == "ctf_flag"

	if is_flag then
		local name = MG_CTF.Translate("editor_zone")

		MG_CTF.AddButton(parent, name, function()
			if !IsValid(ent) then return end
			MG_CTF.OpenZoneEditor(parent, ent, name)
		end)
	end

	local name = MG_CTF.Translate("editor_restrict")

	MG_CTF.AddButton(parent, name, function()
		if !IsValid(ent) then return end
		MG_CTF.OpenFactionRestrictions(parent, ent, name)
	end)

	local name = MG_CTF.Translate("editor_rewards")

	MG_CTF.AddButton(parent, name, function()
		if !IsValid(ent) then return end
		MG_CTF.OpenRewardConfig(parent, ent, name)
	end)

	local name = MG_CTF.Translate("editor_render")

	MG_CTF.AddButton(parent, name, function()
		if !IsValid(ent) then return end
		MG_CTF.OpenRenderConfig(parent, ent, name)
	end)

	local name = MG_CTF.Translate("editor_effects")

	MG_CTF.AddButton(parent, name, function()
		if !IsValid(ent) then return end
		MG_CTF.OpenParticleEditor(parent, ent, name)
	end)

	local name = MG_CTF.Translate("editor_sounds")

	MG_CTF.AddButton(parent, name, function()
		if !IsValid(ent) then return end
		MG_CTF.OpenSoundConfig(parent, ent, name)
	end)

	local name = MG_CTF.Translate("editor_adverts")

	MG_CTF.AddButton(parent, name, function()
		if !IsValid(ent) then return end
		MG_CTF.OpenAdvertConfig(parent, ent, name)
	end)

	MG_CTF.AddCloseButton(parent, ent)
end

function MG_CTF.OpenSettingsPanel(ent, table_override)
	if !IsValid(ent) then
		chat.AddText(Color(255, 0, 0), MG_CTF.Translate("editor_invalid_entity"))
		return
	end

	if IsValid(settings_pnl) and main_ent == ent then return end

	if IsValid(settings_pnl) then
		settings_pnl:Remove()
	end

	main_ent = ent

	MG_CTF.Editor = table.Copy(table_override)
	edit_tbl = MG_CTF.Editor -- Easier access

	MG_CTF.Settings = vgui.Create("DFrame")
	settings_pnl = MG_CTF.Settings -- Easier access

	settings_pnl:SetSize(math.max(ScrW() * (MG_CTF.Config.EditorSize and MG_CTF.Config.EditorSize[1] or 0.35), 600), math.max(ScrH() * (MG_CTF.Config.EditorSize and MG_CTF.Config.EditorSize[2] or 0.6), 400))
	settings_pnl:SetTitle(MG_CTF.Translate("editor_header", ent.GetZoneName and ent:GetZoneName() or MG_CTF.Translate("editor_toolname")))
	settings_pnl:SetDraggable(true)
	settings_pnl:Center()
	settings_pnl:MakePopup()

	MG_CTF.Theme.Frame.Setup(settings_pnl)

	settings = vgui.Create("DPanelList", settings_pnl)
	settings:StretchToParent(0, 25, 0, 5)
	settings:EnableVerticalScrollbar(true)
	settings:SetPadding(5)
	settings:SetSpacing(5)

	if settings.VBar then
		MG_CTF.Theme.ScrollBar.Setup(settings.VBar)
	end

	MG_CTF.AddBase(settings, ent)
end

net.Receive("MG_CTF_Edit", function()
	local ent = net.ReadEntity()

	if !IsValid(ent) then return end

	local tab = MG_CTF.Decompress(net.ReadData(net.ReadUInt(16))) or {}

	MG_CTF.OpenSettingsPanel(ent, tab)
end)

-- 76561198152707596