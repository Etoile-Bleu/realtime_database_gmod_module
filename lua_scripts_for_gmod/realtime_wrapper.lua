-- realtime.lua
-- Wrapper pour charger le module natif gmsv_realtime
-- Ce fichier doit être placé dans: garrysmod/lua/modules/

local arch = (jit.arch == "x64" and "64" or "32")
local dll_name = "gmsv_realtime_win" .. arch

-- Le module DLL se charge automatiquement comme une table globale
-- On cherche la table dans les globales
local realtime_module = _G[dll_name] or _G["realtime"]

if not realtime_module then
    error("Module not found: " .. dll_name .. ".dll")
end

return realtime_module
