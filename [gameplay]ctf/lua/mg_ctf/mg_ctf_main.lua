MG_CTF = MG_CTF or {}

MG_CTF.Config = MG_CTF.Config or {}
MG_CTF.Language = MG_CTF.Language or {}

MG_CTF.STATE_UNCAPTURED = 0
MG_CTF.STATE_CONTESTED = 1
MG_CTF.STATE_CAPTURED = 2
MG_CTF.STATE_CAPTURING = 3
MG_CTF.STATE_UNCAPTURING = 4

MG_CTF.DEFAULT_STATE = 0
MG_CTF.AREASET_STATE1 = 1
MG_CTF.AREASET_STATE2 = 2
MG_CTF.SPHERESET_STATE = 3
MG_CTF.FLAGPOLESET_STATE = 4
MG_CTF.FINALIZE_STATE = 5

MG_CTF.InitializeFunc = { -- Get's called on initialize
}
	
MG_CTF.PreDrawFunc = { -- Draw stuff before the model has been drawn in opaque
	["models/toju/mg_ctf/flag.mdl"] = function(self)
		local bone = self:LookupBone("flag_root")

		if bone then
			local raider = self:GetRaiderName()
			raider = raider != "" and raider

			local progress = (1 - self:GetProgress() / 100) * -90
			local scale = Vector(0, progress, 0)

			self:ManipulateBonePosition(bone, scale) -- Rise and shine, gordon flagman.
		end
	end,
}

MG_CTF.PreDrawFuncTrans = { -- Draw stuff before the model has been drawn in translucent
}

MG_CTF.PostDrawFunc = { -- Draw stuff after the model has been drawn in opaque
}

MG_CTF.PostDrawFuncTrans = { -- Draw stuff after the model has been drawn in translucent
}

MG_CTF.RenderModes = { -- https://wiki.facepunch.com/gmod/Enums/RENDERMODE
	[RENDERMODE_NORMAL] = "NORMAL",
	[RENDERMODE_TRANSCOLOR] = "TRANSCOLOR",
	[RENDERMODE_TRANSTEXTURE] = "TRANSTEXTURE",
	[RENDERMODE_GLOW] = "GLOW",
	[RENDERMODE_TRANSALPHA] = "TRANSALPHA",
	[RENDERMODE_TRANSADD] = "TRANSADD",
	[RENDERMODE_ENVIROMENTAL] = "ENVIROMENTAL",
	[RENDERMODE_TRANSADDFRAMEBLEND] = "TRANSADDFRAMEBLEND",
	[RENDERMODE_TRANSALPHADD] = "TRANSALPHADD",
	[RENDERMODE_WORLDGLOW] = "WORLDGLOW",
	[RENDERMODE_NONE] = "NONE",
}

MG_CTF.RenderFX = { -- https://wiki.facepunch.com/gmod/Enums/kRenderFx
	[kRenderFxNone] = "NONE",
	[kRenderFxPulseSlow] = "PULSESLOW",
	[kRenderFxPulseFast] = "PULSEFAST",
	[kRenderFxPulseSlowWide] = "PULSESLOWWIDE",
	[kRenderFxPulseFastWide] = "PULSEFASTWIDE",
	[kRenderFxFadeSlow] = "FADESLOW",
	[kRenderFxFadeFast] = "FADEFAST",
	[kRenderFxSolidSlow] = "SOLIDSLOW",
	[kRenderFxSolidFast] = "SOLIDFAST",
	[kRenderFxStrobeSlow] = "STROBESLOW",
	[kRenderFxStrobeFast] = "STROBEFAST",
	[kRenderFxStrobeFaster] = "STROBEFASTER",
	[kRenderFxFlickerSlow] = "FLICKERSLOW",
	[kRenderFxNoDissipation] = "NODISSIPATION",
	[kRenderFxDistort] = "DISTORT",
	[kRenderFxHologram] = "HOLOGRAM",
	[kRenderFxExplode] = "EXPLODE",
	[kRenderFxGlowShell] = "GLOWSHELL",
	[kRenderFxClampMinScale] = "CLAMPMINSCALE",
	[kRenderFxEnvRain] = "ENVRAIN",
	[kRenderFxEnvSnow] = "ENVSNOW",
	[kRenderFxSpotlight] = "SPOTLIGHT",
	[kRenderFxRagdoll] = "RAGDOLL",
	[kRenderFxPulseFastWider] = "PULSEFASTWIDER",
}

MG_CTF.Factions = MG_CTF.Factions or {}

function MG_CTF.GuessPositions(owner, prop, tr) -- Guess correct position.
	local mins = prop:OBBMins()
	local pos = tr.HitPos - (tr.HitNormal * mins.z)
	local ang = Angle(0, owner:EyeAngles().yaw, 0) or false

	return pos, ang
end

function MG_CTF.GetFlagEntityName(name) -- Fallback to a "valid" name.
	return isstring(name) and name or MG_CTF.Translate("area_defaultname")
end

function MG_CTF.GetFlagEntityModel(model) -- Fallback to a "valid" model.
	return isstring(model) and model or MG_CTF.Config.DefaultModel
end

function MG_CTF.GetZoneSphereSize(size) -- Fallback to a valid zone size.
	return isnumber(size) and size > 0 and size or MG_CTF.Config.DefaultSphereSize
end

function MG_CTF.Compress(tbl) -- Compress and return both the compressed json and the size.
	local compressed = util.Compress(util.TableToJSON(tbl))
	local leng = compressed:len()

	return compressed, leng
end

function MG_CTF.Decompress(data, size) -- Decompress a compressed json table.
	return util.JSONToTable(util.Decompress(data, 5242880)) -- This number is a safeguard to prevent DOS (Even though only your admins could, I still don't trust them!) >:(
end

function MG_CTF.Translate(str, ...) -- Translate strings into actual language.
	if MG_CTF.Language[str] then
		return string.format(MG_CTF.Language[str], ...)
	else
		print("[MG CTF] Language string "..tostring(str).." does not exist for language "..tostring(MG_CTF.Config.Language).."!")
		return str
	end
end