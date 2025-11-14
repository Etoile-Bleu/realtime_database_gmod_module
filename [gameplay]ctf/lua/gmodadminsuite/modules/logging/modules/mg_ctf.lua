if !MG_CTF.Config.SupportbLogs then return end

local MODULE = GAS.Logging:MODULE()
MODULE.Category = MG_CTF.Config.bLogsCategory
MODULE.Name = MG_CTF.Config.bLogsName
MODULE.Colour = MG_CTF.Config.bLogsColor

MODULE:Setup(function()
	if MG_CTF.Config.bLogsMinimizedLogs["capturesuccess"] then
		MODULE:Hook("MG_CTF_CaptureSuccess", "blogs_mg_ctf", function(ent, old, new) -- Capture success
			MODULE:Log(MG_CTF.Translate("blogs_capturesuccess", ent.FlagEntity:GetZoneName(), new, old))
		end)
	end

	if MG_CTF.Config.bLogsMinimizedLogs["collect"] then
		MODULE:Hook("MG_CTF_Collect", "blogs_mg_ctf", function(ply, flag, typ, amt, ent) -- Collect rewards
			local reward = MG_CTF.Config.RewardTypes[typ]
			if reward then
				local format = isfunction(reward.format) and reward.format(amt) or isstring(reward.format) and string.format(reward.format, amt)
				if format then
					MODULE:Log(MG_CTF.Translate("blogs_collect", format, flag:GetZoneName()), GAS.Logging:FormatPlayer(ply))
				end
			end
		end)
	end

	if MG_CTF.Config.bLogsMinimizedLogs["enterzone"] then
		MODULE:Hook("MG_CTF_AddPlayer", "blogs_mg_ctf", function(ent, ply) -- Enter a zone
			local flag_ent = ent.FlagEntity

			MODULE:Log(MG_CTF.Translate("blogs_enterzone", flag_ent:GetZoneName()), GAS.Logging:FormatPlayer(ply))
		end)
	end

	if MG_CTF.Config.bLogsMinimizedLogs["exitzone"] then
		MODULE:Hook("MG_CTF_RemovePlayer", "blogs_mg_ctf", function(ent, ply) -- Leave a zone
			local flag_ent = ent.FlagEntity

			MODULE:Log(MG_CTF.Translate("blogs_exitzone", flag_ent:GetZoneName()), GAS.Logging:FormatPlayer(ply))
		end)
	end

	if MG_CTF.Config.bLogsMinimizedLogs["capturebegin"] then
		MODULE:Hook("MG_CTF_BeginCapture", "blogs_mg_ctf", function(ent, raider) -- Begin a capture
			local flag_ent = ent.FlagEntity

			MODULE:Log(MG_CTF.Translate("blogs_capturebegin", raider, flag_ent:GetZoneName()))
		end)
	end

	if MG_CTF.Config.bLogsMinimizedLogs["capturecancel"] then
		MODULE:Hook("MG_CTF_CancelCapture", "blogs_mg_ctf", function(ent, raider) -- Cancel a capture
			local flag_ent = ent.FlagEntity

			MODULE:Log(MG_CTF.Translate("blogs_capturecancel", raider, flag_ent:GetZoneName()))
		end)
	end
end)

GAS.Logging:AddModule(MODULE)