ENT.Type = "brush"
ENT.Base = "base_brush"
ENT.PrintName = "Capture area"
ENT.Category = "Modern Gaming"
ENT.Spawnable = false
ENT.PhysgunDisabled = true

ENT.MainZone = true
ENT.ID = 0

MG_CTF.CaptureArea = MG_CTF.CaptureArea or {}

util.AddNetworkString("MG_CTF_Cache")

local reg = debug.getregistry() -- Minor optimisations

local IsValid = IsValid
local GetPos = reg.Entity.GetPos

-- Cache hook.Run for performance
local hookRun = hook.Run

-- Cache commonly used hook names
local HOOKS = {
    CAN_GENERATE_INTEREST = "MG_CTF_CanGenerateInterest",
    GENERATE_INTEREST = "MG_CTF_GenerateInterest",
    CAN_CAPTURE_SUCCESS = "MG_CTF_CanCaptureSuccess",
    CAPTURE_SUCCESS = "MG_CTF_CaptureSuccess",
    CANCEL_CAPTURE = "MG_CTF_CancelCapture",
    ENABLE_ZONE = "MG_CTF_EnableZone",
    DISABLE_ZONE = "MG_CTF_DisableZone",
    ADD_PLAYER = "MG_CTF_AddPlayer",
    REMOVE_PLAYER = "MG_CTF_RemovePlayer",
    START_CONTESTED = "MG_CTF_StartContested",
    END_CONTESTED = "MG_CTF_EndContested",
    CAN_BEGIN_CAPTURE = "MG_CTF_CanBeginCapture",
    BEGIN_CAPTURE = "MG_CTF_BeginCapture"
}

function ENT:InitCollisions(custom_data)
	custom_data = custom_data or self.custom_data

	local tb = self:GetTable()

	if !custom_data.zone_sphere then
		if !isvector(custom_data.min) or !isvector(custom_data.max) then
			self:Remove()
			print("[MG CTF] Couldn't create capture zone (box). Custom data is missing! min: "..(tostring(custom_data and custom_data.min) or "NULL")..", max: "..(tostring(custom_data and custom_data.max) or "NULL"))
			return
		end

		self:SetCollisionBoundsWS(custom_data.min, custom_data.max)

		self:SetSolid(SOLID_BBOX)

		tb.SphereSize = nil

		self:SetTrigger(true)
	else
		if !isvector(custom_data.zone_pos) then
			self:Remove()
			print("[MG CTF] Couldn't create capture zone (sphere). Custom data is missing! zone_pos: "..(tostring(custom_data and custom_data.zone_pos) or "NULL"))
			return
		end

		self:SetPos(custom_data.zone_pos)
		self:PhysicsInit(SOLID_NONE)

		tb.SphereSize = MG_CTF.GetZoneSphereSize(custom_data.zone_size)

		tb.SphereSizeCalc = tb.SphereSize * tb.SphereSize

		self:SetTrigger(false)
	end

	self:SetMoveType(MOVETYPE_NONE)

	self:AddSolidFlags(FSOLID_NOT_SOLID)
end

function ENT:InitServer(new)
	-- Entity

	local tb = self:GetTable()
	local custom_data = tb.custom_data

	self:InitCollisions(custom_data)

	if !IsValid(self) or self:IsMarkedForDeletion() then return end

	-- End

	local default = (!new or custom_data.not_persistant) and custom_data.default_faction or (new and tb.capture_team)
	if default then
		tb.CaptureID = self:SelectFaction(default)
	else
		tb.CaptureID = nil
	end

	if tb.CaptureID then
		tb.State = MG_CTF.STATE_CAPTURED
	else
		tb.State = MG_CTF.STATE_UNCAPTURED
	end

	-- Main

	tb.MinPlayers = isnumber(custom_data.minplayers) and custom_data.minplayers

	tb.MinPlayersArea = isnumber(custom_data.minplayers_area) and custom_data.minplayers_area

	tb.UseToStart = tobool(custom_data.usetostart)

	tb.CaptureTime = isnumber(custom_data.capturetime) and custom_data.capturetime or MG_CTF.Config.DefaultCaptureTime

	tb.UncaptureTime = isnumber(custom_data.uncapturetime) and custom_data.uncapturetime or MG_CTF.Config.DefaultUncaptureTime

	-- Restrictions

	tb.IgnoreFactions = istable(custom_data.ignore_factions) and custom_data.ignore_factions or {}

	tb.CaptureSpeedModify = istable(custom_data.capture_modify) and custom_data.capture_modify or {}

	tb.UncaptureSpeedModify = istable(custom_data.uncapture_modify) and custom_data.uncapture_modify or {}

	-- Rewards

	tb.Rewards = tb.Rewards or {}

	tb.NoSharing = tobool(custom_data.shared_rewards)

	tb.TimedRewards = {}

	for k, v in ipairs(MG_CTF.Config.RewardTypes) do -- Cycle through all possible reward types
		local id = tostring(v.id)
		if !id then continue end

		local tab = custom_data.rewards and custom_data.rewards[id] or {} -- Cache table from config

		tb.Rewards[id] = {}

		tb.Rewards[id]["Capture"] = isnumber(tab.capture) and tab.capture or 0

		if !tobool(tab.enable) then continue end

		tb.Rewards[id]["Time"] = isnumber(tab.time) and tab.time or 60

		tb.Rewards[id]["Amount"] = isnumber(tab.amount) and tab.amount or 10

		tb.Rewards[id]["Max"] = isnumber(tab.max) and tab.max or 100

		tb.Rewards[id]["Split"] = isnumber(tab.split) and tab.split or 1

		table.insert(tb.TimedRewards, id)
	end

	-- End

	tb.InterestTime = {}

	if tb.CaptureID then
		if new then
			tb.StashedRewards = tb.rewards or {}
			tb.TakenRewards = tb.taken or {}
		else
			tb.StashedRewards = {}
			tb.TakenRewards = {}
		end

		self:ExtendInterest(tb)
	else
		tb.StashedRewards = {}
		tb.TakenRewards = {}
	end

	tb.Progress = tb.CaptureID and 100 or 0

	local allowed = self:CreateFlagEntity(custom_data)
	if !allowed then
		self:Remove()
		return
	end

	self:UpdateFlag(tb.FlagEntity, self)

	self:SendDataToAll(tb, true)
end

function ENT:SendDataToAll(tb, bigupdate)
	tb = tb or self:GetTable()

	for k, v in pairs(tb.Players or {}) do
		if !IsValid(k) or !k:Alive() or k:GetNoDraw() then
			continue
		end

		self:SendData(k, true, tb)
	end

	if bigupdate then
		MG_CTF.UpdateAll()
	end
end

function ENT:SelectFaction(faction)
	local tab, allowed = MG_CTF.GetFaction(faction)
	if allowed then
		return faction
	end
end

local function StringRandom(int, map) -- Get a unique name
	local found = false

	while !found do
		local s = ""

		for i = 1, int do
			s = s..string.char(math.random(65, 90))
		end

		if !file.Exists(MG_CTF.SaveLocation.."/"..map.."/"..s..".txt", "DATA") then
			return s
		end
	end
end

function ENT:Initialize()
	self:InitServer(true)

	if !IsValid(self) or self:IsMarkedForDeletion() then return end

	self:InitBasic()

	self:InitArea()

	local tb = self:GetTable()

	if tb.MainZone then -- Only for main zone
		self:InitZones()

		if !tb.SaveID or tb.SaveID == -1 then
			tb.SaveID = StringRandom(MG_CTF.MaxSaveSize, string.lower(game.GetMap()))
		end
	end
end

function ENT:InitBasic() -- Setup basic functions
	MG_CTF.CaptureArea[self] = self

	self.Players = {}

	self:NextThink(CurTime())
end

function ENT:InitArea()
	local tb = self:GetTable()

	tb.Disabled = true
end

function ENT:InitZones()
	local tb = self:GetTable()
	local custom_data = tb.custom_data

	custom_data.zones = istable(custom_data.zones) and custom_data.zones or {}
	tb.Zones = tb.Zones or {}

	for k, v in pairs(tb.Zones) do
		SafeRemoveEntity(v)
	end
	tb.Zones = {}

	for k, v in pairs(custom_data.zones) do
		local main_tbl = table.Copy(custom_data)
		local merge_tbl = table.Merge(main_tbl, v)

		local zone = ents.Create("ctf_zone")
		if !IsValid(zone) then continue end

		zone.ParentArea = self
		zone.ID = k
		zone.custom_data = merge_tbl

		zone:Spawn()

		tb.Zones = tb.Zones or {}
		tb.Zones[k] = zone
	end
end

function ENT:CreateFlagEntity(custom_data) -- Creates a flag entity
	if !isvector(custom_data.pos) then
		print("[MG CTF] Couldn't create flag entity for capture zone. Custom data is missing! pos: "..(tostring(custom_data.pos) or "NULL"))
		return false
	end

	local ent = self.FlagEntity or ents.Create("ctf_flag")

	if !IsValid(ent) then
		print("[MG CTF] Couldn't create flag entity for capture zone. Deleting capture zone...")
		return false
	end

    ent:SetPos(custom_data.pos)

	if isangle(custom_data.ang) then
		ent:SetAngles(custom_data.ang)
	end

    ent.Area = self
	ent.Data = custom_data

    ent:Spawn()

    self.FlagEntity = ent

    return true, ent
end

function ENT:OnRemove()
	local tb = self:GetTable()

	if tb.MainZone then
		SafeRemoveEntity(tb.FlagEntity)

		tb.Zones = tb.Zones or {}
		for k, v in pairs(tb.Zones) do -- Remove old zones
			SafeRemoveEntity(v)
		end
	else
		for k, v in pairs(tb.Players) do
			if !IsValid(k) then continue end
			self:RemovePlayer(k, tb, tb.ID, tb.ParentArea)
		end
	end

	MG_CTF.CaptureArea[self] = nil

	MG_CTF.UpdateAll()
end

function ENT:SendData(ply, allowed, tb) -- Whenever someone enters the zone, all required data is transmitted to them, once.
	tb = tb or self:GetTable()

	net.Start("MG_CTF_Cache")
		net.WriteEntity(tb.FlagEntity)
		net.WriteBool(allowed and true or false)

		local belongs = MG_CTF.BelongsToFaction(ply, tb.CaptureID) -- Send all reward specifics to the player, if they belong to the same faction
		local available = #tb.TimedRewards

		net.WriteUInt(belongs and allowed and available or 0, 8)

		if belongs and allowed and available > 0 then
			local sid = ply:SteamID()

			for _, v in ipairs(tb.TimedRewards) do
				local tab = tb.Rewards[v]

				if tab.Time then
					net.WriteString(v)
					net.WriteUInt(tb.StashedRewards[v] or 0, 32)
					net.WriteUInt(tab.Max, 32)
					net.WriteUInt(tb.TakenRewards[v] and tb.TakenRewards[v][sid] or 0, 32)
				end
			end
		end
	net.Send(ply)
end

function ENT:AddPlayer(ply, tb, id, parent)
	tb = tb or self:GetTable()
	id = id or 0
	parent = parent or self

	local parent_tb = parent:GetTable()

	if !parent_tb.Players[ply] or !parent_tb.Players[ply][tb.ID] then
		parent_tb.Players[ply] = parent_tb.Players[ply] or {}

		if table.IsEmpty(parent_tb.Players[ply]) then
			parent:SendData(ply, true, parent_tb)

			if parent:CanCapture(ply, tb) then
				parent_tb.NextVerify = nil
			end
		end

		parent_tb.Players[ply][tb.ID] = true

		hookRun(HOOKS.ADD_PLAYER, self, ply)
	end
end

function ENT:RemovePlayer(ply, tb, id, parent)
	tb = tb or self:GetTable()
	id = id or 0
	parent = parent or self

	local parent_tb = parent:GetTable()
	if parent_tb.Players[ply] and parent_tb.Players[ply][tb.ID] then
		parent_tb.Players[ply][tb.ID] = nil
		if table.IsEmpty(parent_tb.Players[ply]) then
			parent_tb.Players[ply] = nil

			parent:SendData(ply, false, parent_tb)

			if parent:CanCapture(ply, tb) then
				parent_tb.NextVerify = nil
			end
		end

		hookRun(HOOKS.REMOVE_PLAYER, self, ply)
	end
end

function ENT:StartTouch(ent, tb, valid)
	tb = tb or self:GetTable()

	local parent = tb.ParentArea or self

	if valid or (ent:IsPlayer()) and !ent:GetNoDraw() then
		self:AddPlayer(ent, tb, tb.ID, parent)
	end
end

function ENT:EndTouch(ent, tb, valid)
	tb = tb or self:GetTable()

	if valid or ent:IsPlayer() then
		self:RemovePlayer(ent, tb, tb.ID, tb.ParentArea)
	end
end

function ENT:SphereCheck(tb)
	tb = tb or self:GetTable()

	local still_exists = {}
	local self_pos = GetPos(self)
	local size = tb.SphereSizeCalc

	for ply in pairs(MG_CTF.PlayerEntities) do -- Going through all players to check their distances. (Faster than ents.FindInSphere)
		if IsValid(ply) then
			if GetPos(ply):DistToSqr(self_pos) <= size then
				self:StartTouch(ply, tb, true)

				still_exists[ply] = true
			end
		else
			MG_CTF.PlayerEntities[ply] = nil
		end
	end

	local parent = tb.ParentArea or tb

	for k, v in pairs(parent.Players) do
		if !IsValid(k) then continue end
		if !k:Alive() or k:GetNoDraw() or !still_exists[k] then
			self:EndTouch(k, tb, true)
		end
	end
end

function ENT:CanCapture(ply, tb) -- Determines if capturing is possible
	tb = tb or self:GetTable()

	local parent = tb.ParentArea or self

	return MG_CTF.CanCapture(ply, parent, tb.CaptureID)
end

function ENT:UpdateFlag(flag_ent, tb) -- Update the flag entity
	flag_ent = flag_ent or self.FlagEntity
	tb = tb or self:GetTable()

	local dt = flag_ent:GetTable().dt -- Directly access the data table to improve performance

	if dt.Disabled != tb.Disabled then
		dt.Disabled = tb.Disabled
	end

	if dt.State != tb.State then
		dt.State = tb.State
	end

	local contested = tb.Contested and true or false
	if dt.Contested != contested then
		dt.Contested = contested
	end

	if dt.Progress != (tb.Progress or 0) then
		dt.Progress = (tb.Progress or 0)
	end

	if !tb.RaiderTeam then
		if dt.RaiderName != "" then
			dt.RaiderName = ""
			dt.RaiderColor = vector_origin
		end
	else
		if dt.RaiderName != tb.RaiderTeam then
			dt.RaiderName = tb.RaiderTeam
			dt.RaiderColor = MG_CTF.RetrieveColor(tb.RaiderTeam):ToVector()
		end
	end

	if dt.TeamName != (tb.CaptureID or "") then
		dt.TeamName = (tb.CaptureID or "")

		flag_ent:ColorAccordingToFaction()
	end
end

function ENT:CheckTime()
	if !MG_CTF.Config.HourRestrictionEnabled then
		return true
	end

	local times = MG_CTF.Config.ActiveHours or {}

	local time = os.time()
	local curday = os.date("%a", time)
	local cached_day = times[curday] or times["default"]
	if cached_day then
		local curhour = tonumber(os.date("%H", time))
		if curhour >= cached_day.min and curhour <= cached_day.max then
			return true
		end
	end

	return false
end

function ENT:EnoughPlayers(tb)
	tb = tb or self:GetTable()

	if !tb.MinPlayers or tb.MinPlayers <= 0 then
		return true
	end

	return MG_CTF.PlayerCount >= tb.MinPlayers
end

function ENT:SetInterest(tb, typ, amt)
	tb = tb or self:GetTable()

	tb.StashedRewards[typ] = tb.StashedRewards[typ] or 0
	tb.StashedRewards[typ] = amt
end

function ENT:SetNextInterest(tb, cur_time, typ, time)
	tb = tb or self:GetTable()
	cur_time = cur_time or CurTime()

	tb.InterestTime[typ] = tb.InterestTime[typ] or 0

	tb.InterestTime[typ] = cur_time + time
end

function ENT:ExtendInterest(tb, cur_time, typ)
	tb = tb or self:GetTable()
	cur_time = cur_time or CurTime()

	if !typ then
		for _, v in ipairs(tb.TimedRewards) do
			local tab = tb.Rewards[v]
			if tab then
				self:SetNextInterest(tb, cur_time, v, tab.Time)
			end
		end
	else
		local info = tb.Rewards[typ]
		if info then
			self:SetNextInterest(tb, cur_time, typ, info.Time)
		end
	end
end

function ENT:CheckInterests(tb, cur_time)
	tb = tb or self:GetTable()
	cur_time = cur_time or CurTime()

	for _, v in ipairs(tb.TimedRewards) do
		local tab = tb.Rewards[v]
		if tab then
			if tb.InterestTime[v] and tb.InterestTime[v] <= cur_time then
				if hookRun(HOOKS.CAN_GENERATE_INTEREST, self, v) == false then continue end

				local amt = tab.Amount * (tb.Disabled and (tab.Split or 1) or 1)
				self:SetInterest(tb, v, math.floor((tb.StashedRewards[v] or 0) + amt))

				self:SetNextInterest(tb, cur_time, v, tab.Time)

				self:SendDataToAll(tb, false)

				MG_CTF.SaveZone(tb)

				hookRun(HOOKS.GENERATE_INTEREST, self, v, amt)
			end
		end
	end
end

function ENT:CheckForContest(tb)
	tb = tb or self:GetTable()

	local contest = false
	local raid = false
	local attacker

	for k, v in pairs(tb.Players) do -- Check, if raiding or contesting is possible

		local isvalid = IsValid(k)
		if !isvalid or !k:Alive() or k:GetNoDraw() then
			if !isvalid then
				tb.Players[k] = nil
			else
				self:RemovePlayer(k, tb, tb.ID, tb.ParentArea)
			end
			continue
		end

		local belongs = MG_CTF.BelongsToFaction(k, tb.CaptureID)
		local intruder, faction = MG_CTF.CanCapture(k, self, tb.CaptureID)

		if belongs or intruder then

			if belongs then
				contest = true
			end

			if intruder then
				if attacker and attacker != faction then
					contest = true
				else
					attacker = faction
					raid = true
				end
			end
		end

		if contest and raid then
			break
		end
	end

	return contest, raid, attacker
end

function ENT:CaptureEffect(tb)
	tb = tb or self:GetTable()

	local custom_data = tb.custom_data

	if !custom_data then return end
	
	if custom_data.snd_capture_play then
		if isstring(custom_data.snd_capture) and string.Trim(custom_data.snd_capture) != "" then
			sound.Play(custom_data.snd_capture, tb.FlagEntity:GetPos() + Vector(0, 0, 1), isnumber(custom_data.snd_capture_range) and custom_data.snd_capture_range or 75, isnumber(custom_data.snd_capture_pitch) and custom_data.snd_capture_pitch or 100)
		end
	end

	if !custom_data.eff_capture_prevent then
		local edata = EffectData()
		edata:SetEntity(tb.FlagEntity)
		edata:SetOrigin(tb.FlagEntity:GetPos())
		edata:SetScale(isnumber(custom_data.eff_capture_size) and custom_data.eff_capture_size or 1)
		edata:SetRadius(isnumber(custom_data.eff_capture_particles) and custom_data.eff_capture_particles or 200)
		edata:SetMagnitude(isnumber(custom_data.eff_capture_lifetime) and custom_data.eff_capture_lifetime or 8)
		edata:SetHitBox(isnumber(custom_data.eff_capture_range) and custom_data.eff_capture_range or 150)
		util.Effect("mg_ctf_capture", edata, true, true)
	end
end

function ENT:CaptureSuccess(tb, cur_time) -- Called on successful capture
	local mess = MG_CTF.Translate("area_capturesuccess", tb.FlagEntity:GetZoneName())

	for k, v in ipairs(MG_CTF.Config.RewardTypes) do -- Cycle through all possible reward types
		local id = tostring(v.id)
		if !id then continue end

		local reward = tb.Rewards[id] -- Check for reward with ID

		if reward.Capture > 0 then
			for ply in pairs(tb.Players) do
				if self:CanCapture(ply, tb) then
					MG_CTF.Notify(ply, 0, 4, mess)

					local config = MG_CTF.Config.RewardTypes[k] -- Get reward type
					if config and isfunction(config.give) then
						config.give(ply, reward.Capture)
					end
				end
			end
		end
	end

	local old_capture = tb.CaptureID

	if tb.CaptureID then
		tb.CaptureID = nil
	else
		tb.CaptureID = tb.RaiderTeam
	end

	tb.RemoveProgress = nil
	tb.Occupied = nil
	tb.Capturing = nil

	tb.RaiderTeam = nil

	tb.Uncapturing = nil

	tb.Contested = nil

	tb.InterestTime = {}

	tb.TakenRewards = {}
	tb.StashedRewards = {}

	if tb.CaptureID then
		self:ExtendInterest(tb)
	end

	MG_CTF.SaveZone(tb)

	MG_CTF.UpdateMiniMapPositions()

	local data = tb.custom_data
	if data.advert_capturesuccess then
		MG_CTF.Advert(
			{old_capture, tb.CaptureID},
			MG_CTF.Translate("advert_capturesuccess",
				tb.FlagEntity:GetZoneName(),
				!data.advert_anon and old_capture and MG_CTF.Translate("advert_from", old_capture) or "",
				!data.advert_anon and tb.RaiderTeam and MG_CTF.Translate("advert_by", tb.RaiderTeam) or ""
			),
			self
		)
	end

	hookRun(HOOKS.CAPTURE_SUCCESS, self, old_capture, tb.CaptureID)

	tb:CaptureEffect(tb)

	tb.NextVerify = nil
end

function ENT:PredictTimes(tb, faction)
	tb = tb or self:GetTable()

	tb.TimeManip = (tb.Capturing and tb.CaptureTime / (MG_CTF.GetFaction(faction).capturespeed or 1) / (tb.CaptureSpeedModify[faction] or 1) or tb.UncaptureTime / (MG_CTF.GetFaction(faction).uncapturespeed or 1) / (tb.CaptureSpeedModify[faction] or 1)) / 60
end

function ENT:ResetData(tb)
	tb = tb or self:GetTable()

	tb.StartTime = nil
	tb.EndTime = nil

	tb.RemoveProgress = nil
	tb.Occupied = nil
	tb.Capturing = nil

	tb.RaiderTeam = nil

	tb.Uncapturing = nil

	-- Update 1.1

	tb.BeginCapture = nil

	if !table.IsEmpty(tb.Players) then
		tb.NextVerify = nil
	end
end

function ENT:ProcessProgress(tb, cur_time)
	tb = tb or self:GetTable()
	cur_time = cur_time or CurTime()

	tb.Progress = math.min(tb.Progress + (FrameTime() / 0.6) / tb.TimeManip, 100)

	if tb.Progress >= 100 then
		if tb.Capturing == true and hookRun(HOOKS.CAN_CAPTURE_SUCCESS, self, tb.CaptureID, tb.RaiderTeam) != false then
			self:CaptureSuccess(tb, cur_time)
			return
		end

		local data = tb.custom_data
		if data.advert_capturecancel then
			MG_CTF.Advert(
				{tb.RaiderTeam, tb.CaptureID},
				MG_CTF.Translate("advert_capturecancel",
					tb.FlagEntity:GetZoneName(),
					!data.advert_anon and tb.CaptureID and MG_CTF.Translate("advert_of", tb.CaptureID) or "",
					!data.advert_anon and tb.RaiderTeam and MG_CTF.Translate("advert_by", tb.RaiderTeam) or ""
				),
				self
			)
		end

		hookRun(HOOKS.CANCEL_CAPTURE, self, tb.RaiderTeam)
		self:ResetData(tb)
	end
end

function ENT:Regress(tb, cur_time)
	tb = tb or self:GetTable()
	cur_time = cur_time or CurTime()

	tb.Progress = math.min(tb.Progress - (FrameTime() / 0.6) / tb.TimeManip, 100)

	if tb.Progress <= 0 then
		if tb.Capturing == false then
			self:CaptureSuccess(tb, cur_time)
			return
		end

		local data = tb.custom_data
		if data.advert_capturecancel then
			MG_CTF.Advert(
				{tb.RaiderTeam, tb.CaptureID},
				MG_CTF.Translate("advert_capturecancel",
					tb.FlagEntity:GetZoneName(),
					!data.advert_anon and tb.CaptureID and MG_CTF.Translate("advert_of", tb.CaptureID) or "",
					!data.advert_anon and tb.RaiderTeam and MG_CTF.Translate("advert_by", tb.RaiderTeam) or ""
				),
				self
			)
		end

		hookRun(HOOKS.CANCEL_CAPTURE, self, tb.RaiderTeam)

		self:ResetData(tb)
	end
end

function ENT:QuickThink(tb, cur_time)
	tb = tb or self:GetTable()
	cur_time = cur_time or CurTime()

	if tb.Capturing == nil and !tb.Uncapturing then return false end
	if tb.Contested then return false end

	if !tb.RemoveProgress then
		self:ProcessProgress(tb, cur_time)
	else
		self:Regress(tb, cur_time)
	end

	return true
end

function ENT:Think()
	-- Early returns for invalid states
	if !self or self == NULL then return end

	local tb = self:GetTable()
	if !tb then return end

	if !tb.MainZone and !tb.SphereSize then return end

	local cur_time = CurTime()
	local flag_ent = tb.FlagEntity

	-- Handle sphere check logic
	if tb.SphereSize then
		local next_check = tb.NextSphereCheck or 0
		if next_check <= cur_time then
			tb.NextSphereCheck = cur_time + (MG_CTF.Config.SphereCheckDelay or 0.1)
			self:SphereCheck(tb)
		end
	end

	-- Only process main zone logic
	if !tb.MainZone then 
		self:NextThink(cur_time)
		return true 
	end

	-- Cache commonly accessed values
	local disabled = tb.Disabled
	local capture_id = tb.CaptureID
	local state = tb.State
	local next_verify = tb.NextVerify or 0
	local allowed = self:QuickThink(tb, cur_time)

	-- Verify state every second
	if next_verify <= cur_time then
		tb.NextVerify = cur_time + 1
		allowed = true

		-- Check if zone should be active
		local time_valid = tb:CheckTime()
		local players_valid = tb:EnoughPlayers(tb)
		local zone_active = time_valid and players_valid

		-- Update zone enabled state
		if zone_active then
			if disabled then
				tb.Disabled = false
				hookRun(HOOKS.ENABLE_ZONE, self)
			end

			-- Determine zone state
			local new_state = capture_id and MG_CTF.STATE_CAPTURED or MG_CTF.STATE_UNCAPTURED
			local contest, raid, faction

			-- Check for capture attempts
			if !tb.UseToStart or tb.AllowCapture or tb.Occupied then
				contest, raid, faction = self:CheckForContest(tb)

				if raid then
					if contest then
						new_state = MG_CTF.STATE_CONTESTED
					else
						new_state = capture_id and MG_CTF.STATE_UNCAPTURING or MG_CTF.STATE_CAPTURING
					end
				end

				-- Reset AllowCapture if no active capture
				if new_state == MG_CTF.STATE_CAPTURED or new_state == MG_CTF.STATE_UNCAPTURED then
					tb.AllowCapture = nil
				end
			end

			-- Update state and handle state transitions
			tb.State = new_state

			-- Handle capture/uncapture states
			if new_state == MG_CTF.STATE_UNCAPTURING or new_state == MG_CTF.STATE_CAPTURING then
				-- Clear contested state if needed
				if tb.Contested then
					tb.Contested = nil
					hookRun(HOOKS.END_CONTESTED, self)
				end

				-- Handle new capture attempt
				if tb.Occupied == nil and (!tb.RaiderTeam or tb.RaiderTeam == faction) then
					if hookRun(HOOKS.CAN_BEGIN_CAPTURE, self, faction) != false then
						-- Initialize capture state
						tb.Occupied = true
						tb.Capturing = new_state == MG_CTF.STATE_CAPTURING
						self:PredictTimes(tb, faction)
						tb.RemoveProgress = new_state == MG_CTF.STATE_UNCAPTURING
						tb.RaiderTeam = faction
						tb.Uncapturing = nil

						-- Handle capture begin notification
						local data = tb.custom_data
						if data and data.advert_capturebegin then
							MG_CTF.Advert(
								{faction, capture_id},
								MG_CTF.Translate("advert_capturebegin",
									flag_ent:GetZoneName(),
									!data.advert_anon and capture_id and MG_CTF.Translate("advert_of", capture_id) or "",
									!data.advert_anon and faction and MG_CTF.Translate("advert_by", faction) or ""
								),
								self
							)
						end

						hookRun(HOOKS.BEGIN_CAPTURE, self, faction)
					end
				elseif !tb.RaiderTeam or tb.RaiderTeam != faction then
					tb.RemoveProgress = !capture_id or false
				else
					tb.RemoveProgress = new_state == MG_CTF.STATE_UNCAPTURING
				end
			-- Handle contested state
			elseif new_state == MG_CTF.STATE_CONTESTED then
				if !tb.Contested then
					tb.Contested = true
					hookRun(HOOKS.START_CONTESTED, self)
				end
			-- Handle neutral state
			else
				if tb.Contested then
					tb.Contested = nil
					hookRun(HOOKS.END_CONTESTED, self)
				end
				tb.RemoveProgress = !capture_id or false
			end
		else
			-- Disable zone if conditions not met
			if !disabled then
				tb.Disabled = true
				hookRun(HOOKS.DISABLE_ZONE, self)
			end

			-- Reset zone state
			self:ResetData(tb)
			tb.Progress = capture_id and 100 or 0
			tb.Contested = nil
			tb.State = capture_id and MG_CTF.STATE_CAPTURED or MG_CTF.STATE_UNCAPTURED
		end

		-- Process rewards
		tb:CheckInterests(tb, cur_time)
	end

	-- Update flag entity if needed
	if allowed then
		self:UpdateFlag(flag_ent, tb)
	end

	self:NextThink(cur_time)
	return true
end

-- 76561198152707596
