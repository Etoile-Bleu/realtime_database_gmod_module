-- This script belongs solely to https://steamcommunity.com/id/mcnuggets1908/.
-- Sharing or selling it is prohibited!

print("[MG CTF] Preparing setup of Modern Factions (from gmodstore: https://www.gmodstore.com/market/view/modern-factions, bought by 76561198152707596) ...")

if SERVER then
	include("mg_ctf/mg_ctf_main.lua")

	print("[MG CTF] Loading config...")
	include("mg_ctf/mg_ctf_config.lua")
	print("[MG CTF] Config successfully loaded.")

	include("mg_ctf/server/mg_ctf_main.lua")
	include("mg_ctf/server/mg_ctf_factions.lua")
	include("mg_ctf/server/mg_ctf_zones.lua")
	include("mg_ctf/server/mg_ctf_tool.lua")
	include("mg_ctf/server/mg_ctf_map.lua")

	AddCSLuaFile("mg_ctf/mg_ctf_main.lua")
	AddCSLuaFile("mg_ctf/mg_ctf_config.lua")

	AddCSLuaFile("mg_ctf/client/mg_ctf_theme.lua")
	AddCSLuaFile("mg_ctf/client/mg_ctf_main.lua")
	AddCSLuaFile("mg_ctf/client/mg_ctf_hud.lua")
	AddCSLuaFile("mg_ctf/client/mg_ctf_advert.lua")
	AddCSLuaFile("mg_ctf/client/mg_ctf_map.lua")

	print("[MG CTF] Booting up default language...")

	include("mg_ctf/languages/en.lua")
	AddCSLuaFile("mg_ctf/languages/en.lua")

	print("[MG CTF] Default language loaded.")

	local lang = MG_CTF.Config.Language or "en"
	if lang != "en" then
		print("[MG CTF] Booting up custom language...")

		if file.Exists("mg_ctf/languages/"..lang..".lua", "LUA") then
			print("[MG CTF] Language "..lang.." found.")

			include("mg_ctf/languages/"..lang..".lua")
			AddCSLuaFile("mg_ctf/languages/"..lang..".lua")
		else
			print("[MG CTF] Couldn't find language "..lang..". Defaulting back to english...")
		end

		print("[MG CTF] Language "..lang.." loaded.")
	end
end

if CLIENT then
	include("mg_ctf/mg_ctf_main.lua")

	print("[MG CTF] Loading config...")
	include("mg_ctf/mg_ctf_config.lua")
	print("[MG CTF] Config successfully loaded.")

	include("mg_ctf/client/mg_ctf_theme.lua")
	include("mg_ctf/client/mg_ctf_main.lua")
	include("mg_ctf/client/mg_ctf_hud.lua")
	include("mg_ctf/client/mg_ctf_advert.lua")
	include("mg_ctf/client/mg_ctf_map.lua")

	print("[MG CTF] Booting up default language...")

	include("mg_ctf/languages/en.lua")

	print("[MG CTF] Default language loaded.")

	local lang = MG_CTF.Config.Language or "en"
	if lang != "en" then
		print("[MG CTF] Booting up custom language...")

		if file.Exists("mg_ctf/languages/"..lang..".lua", "LUA") then
			print("[MG CTF] Language "..lang.." found.")
			include("mg_ctf/languages/"..lang..".lua")
			print("[MG CTF] Language "..lang.." loaded.")
		else
			print("[MG CTF] Couldn't find language "..lang..". Defaulting back to english...")
		end
	end
end

print("[MG CTF] All files loaded.")