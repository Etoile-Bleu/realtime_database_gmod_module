cd C:\dev\serveur_gmod\steamapps\common\GarrysModDS
.\srcds.exe -console -game garrysmod +map gm_construct +maplayers 16 +gamemode sandbox +r hunkalloclightmaps 0 2>&1 | Select-Object -First 300
cd C:\dev\gmod_realtime_module