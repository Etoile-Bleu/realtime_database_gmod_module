local L = MG_CTF.Language -- Don't touch this!

-- Capture zone
L["area_defaultname"] = "Capture zone"
L["area_capturesuccess"] = "%s was successfully captured."
L["area_unknown"] = "Unknown"
L["area_vacant"] = "Uncaptured"
L["area_captureimpossible"] = "Capturing disabled"
L["area_contested"] = "Contested"
L["area_reward"] = "Rewards: "

-- Flag pole
L["flag_notcaptured"] = "This zone needs to be captured first!"
L["flag_needtobe"] = "You have to be %s in order to collect rewards here!"
L["flag_contested"] = "This zone is contested!"
L["flag_notfullycaptured"] = "This zone is not fully captured!"
L["flag_retrieved"] = "You collected %s from %s."

-- Mini map
L["minimap_main"] = "Mini map"
L["minimap_drag"] = "Drag mouse: Adjust position"
L["minimap_scroll"] = "Scroll: Zoom"
L["minimap_lock"] = "Lock on player"

-- Admin
L["admin_edit"] = "Capture zone edited.\nSave it via \"mg_ctf_save\"!"
L["admin_save"] = "%s capture zone(s) saved."
L["admin_clear"] = "Capture zones cleared."
L["admin_notallowed"] = "You don't have any permissions to save capture zones."
L["admin_created"] = "Zone successfully created.\nSave it via \"mg_ctf_save\"!"
L["admin_lookatflag"] = "You have to aim at a flag entity."
L["admin_reset"] = "Rewards successfully reset."
L["admin_reset_error"] = "This zone is not captured!"
L["admin_tool_error"] = "You need to equip the admin tool in order to access this function!"
L["admin_invalid_entity"] = "Invalid entity!\nMaybe the entity limit has been hit."
L["admin_remove"] = "Zone #%s has been removed."
L["admin_file_not_found"] = "Zone couldn't be found. (%s)"
L["admin_settings_copied"] = "Settings copied."
L["admin_edit_faction"] = "Factions updated."

L["admin_new"] = "Leftclick: Create a new capture zone"
L["admin_delete"] = "Rightclick: Remove the zone in front of you"
L["admin_settings"] = "Reload: Open settings panel"
L["admin_settings_ent"] = "Reload: Open settings panel for flag entity"
L["admin_1stzone"] = "Leftclick: Set the first position of the capture zone"
L["admin_2ndzone"] = "Leftclick: Set the second position of the capture zone"
L["admin_zone"] = "Leftclick: Set the position of the capture zone"
L["admin_flagpos"] = "Leftclick: Set flag entity location"
L["admin_finish"] = "Leftclick: Finish setup"
L["admin_cancel"] = "Rightclick: Cancel"
L["admin_savecmd"] = "Save via mg_ctf_save-console command"

-- Editor main
L["editor_header"] = "Properties of %s"
L["editor_toolname"] = "Admin Tool"
L["editor_main"] = "Main settings"
L["editor_apply"] = "Apply"

L["editor_invalid_entity"] = "Invalid zone!\nMake sure the zone you are trying to edit is within your range."
L["editor_vector_error"] = "[MG CTF] %s:\nInvalid vector! Can't save... (%s)"
L["editor_color_error"] = "[MG CTF] %s:\nInvalid color! Can't save... (%s)"

L["editor_model"] = "Enter model path:"
L["editor_path"] = "models/path.mdl"
L["editor_name"] = "Enter name:"
L["editor_save"] = "Save settings"
L["editor_not_persistant"] = "Don't save capture status over map changes:"
L["editor_minplayers"] = "Minimum players on the server:"
L["editor_capturetime"] = "Needed time to capture:"
L["editor_uncapturetime"] = "Needed time to uncapture:"

-- Categories
L["editor_cat"] = "Category: "
L["editor_clickhere"] = "Click here to go back."
L["editor_current"] = "Current: "

L["editor_cat_factions"] = "Factions"
L["editor_cat_tool"] = "Admin Tool"
L["editor_cat_select"] = "Selection"
L["editor_cat_zone"] = "Zone"

-- Tool settings
L["editor_tool"] = "Sphere usage"
L["editor_tool_usesphere"] = "Use sphere instead of box (Less performance):"
L["editor_tool_spheresize"] = "Modify radius of sphere:"

-- Select zone
L["editor_select"] = "Select zone to edit..."
L["editor_select_zone"] = "Select: %s (%s)"

-- Zone Editor
L["editor_zone"] = "Zone editor"
L["editor_zone_num"] = "Zone #%s"
L["editor_zone_edit"] = "Make zone"
L["editor_zone_sphere"] = "Make sphere"
L["editor_zone_add"] = "Add new zone..."
L["editor_zone_remove"] = "Remove zone"

-- Rendering
L["editor_render"] = "Rendering"
L["editor_render_modelscale"] = "Model scale:"
L["editor_render_color"] = "Color of model:"
L["editor_render_material"] = "Material of model:"
L["editor_render_nodraw"] = "Invisible:"
L["editor_render_not_solid"] = "Not solid:"
L["editor_render_dont_color"] = "Don't color according to faction color:"
L["editor_render_drawpos"] = "Render position of HUD:"
L["editor_render_mode"] = "Select render mode:"
L["editor_render_fx"] = "Select render FX:"
L["editor_render_pos"] = "Position of flag entity [Advanced]:"

-- Sounds
L["editor_sounds"] = "Sound"
L["editor_sound_capture_play"] = "Play capture sound:"
L["editor_sound_capture"] = "Capture sound:"
L["editor_sound_capture_range"] = "Capture sound range:"
L["editor_sound_capture_pitch"] = "Capture sound pitch:"

-- Effects
L["editor_effects"] = "Effects"

L["editor_effects_cat_capture"] = "Effect: Capture"
L["editor_effects_cat_collect"] = "Effect: Collect"

L["editor_effects_capture_prevent"] = "Prevent capture effect:"
L["editor_effects_capture_material"] = "Enter material:"
L["editor_effects_capture_size"] = "Size of material [Mult]:"
L["editor_effects_capture_particles"] = "Amount of particles [Mult]:"
L["editor_effects_capture_lifetime"] = "Lifetime of particles [Mult]:"
L["editor_effects_capture_range"] = "Range of effect [Mult]:"

L["editor_effects_collect_prevent"] = "Prevent collect effect:"
L["editor_effects_collect_material"] = "Enter material:"
L["editor_effects_collect_size"] = "Size of material [Mult]:"
L["editor_effects_collect_particles"] = "Amount of particles [Mult]:"
L["editor_effects_collect_lifetime"] = "Lifetime of particles [Mult]:"
L["editor_effects_collect_range"] = "Range of effect [Mult]:"

-- Rewards
L["editor_rewards"] = "Rewards"

L["editor_rewards_cat"] = "Reward: %s"
L["editor_rewards_cat_money"] = "Money"
L["editor_rewards_cat_xp"] = "XP"

L["editor_rewards_shared"] = "Don't share rewards between players:"
L["editor_rewards_capture"] = "%s for successfully capturing:"

L["editor_rewards_enable"] = "Enable timed rewards for %s:"
L["editor_rewards_time"] = "Time needed to add %s:"
L["editor_rewards_amount"] = "Timer %s amount:"
L["editor_rewards_max"] = "Maximum stored %s:"
L["editor_rewards_split"] = "Split %s, if capturing is disabled [Mult]:"

L["editor_rewards_reset"] = "Reset rewards for this zone"

-- Copy mode
L["editor_copy"] = "Copy settings from capture zone"
L["editor_copy_zone"] = "Copy: %s (%s)"

-- Faction restrictions
L["editor_restrict"] = "Restrict factions"
L["editor_restrict_setallowance"] = "Disallow capturing"
L["editor_restrict_setdefault"] = "Set as default"
L["editor_restrict_unsetallowance"] = "Allow capturing"
L["editor_restrict_unsetdefault"] = "Unset as default"
L["editor_restrict_setcapturetime"] = "Set capture speed multiplier"
L["editor_restrict_setuncapturetime"] = "Set uncapture speed multiplier"

L["editor_restrict_faction"] = "Faction"
L["editor_restrict_allowed"] = "Capturing allowed"
L["editor_restrict_default"] = "Default faction"
L["editor_restrict_capturespeed"] = "Capture speed"
L["editor_restrict_uncapturespeed"] = "Uncapture speed"

-- Faction setup
L["editor_faction_manage"] = "Manage factions"
L["editor_faction_add"] = "Add new faction..."
L["editor_faction_edit"] = "Edit faction"
L["editor_faction_remove"] = "Remove faction"
L["editor_faction_save"] = "Save factions"

L["editor_faction_editor"] = "Faction editor (%s)"
L["editor_faction_editor_new"] = "New faction"
L["editor_faction_editor_name"] = "Enter unique name:"
L["editor_faction_editor_color"] = "Enter color:"
L["editor_faction_editor_capturespeed"] = "Capture speed [Mult]:"
L["editor_faction_editor_uncapturespeed"] = "Uncapture speed [Mult]:"
L["editor_faction_editor_maxzones"] = "Maximum captured zones:"

L["editor_faction_editor_allowed"] = "Members list:"
L["editor_faction_editor_team"] = "Job / Team"
L["editor_faction_editor_associated"] = "Associated"
L["editor_faction_editor_switch"] = "Switch"
L["editor_faction_editor_switch_all"] = "Switch all"

L["editor_faction_editor_enemies"] = "Enemy list:"
L["editor_faction_editor_faction"] = "Faction"
L["editor_faction_editor_enemy"] = "Is enemy"

L["editor_faction_editor_error"] = "[MG CTF] %s:\nInvalid name! Can't save..."
L["editor_faction_editor_save"] = "Apply changes"

-- Adverts
L["editor_adverts"] = "Adverts"

L["editor_adverts_cat"] = "Advert types"

L["editor_advert_global"] = "Global adverts, instead of only to affected factions:"
L["editor_advert_anon"] = "Hide faction names in adverts:"
L["editor_advert_transmit"] = "Advert to players in the zone:"
L["editor_advert_capturesuccess"] = "Advert on successful capture:"
L["editor_advert_capturebegin"] = "Advert on capture start:"
L["editor_advert_capturecancel"] = "Advert on capture cancel:"

L["advert_capturesuccess"] = "%s was taken%s%s."
L["advert_capturebegin"] = "%s%s is being captured%s."
L["advert_capturecancel"] = "%s%s is no longer being captured%s."
L["advert_of"] = " of %s"
L["advert_by"] = " by %s"
L["advert_from"] = " from %s"

-- bLogs support
L["blogs_capturesuccess"] = "%s was captured by %s. (Previous: %s)"
L["blogs_collect"] = "{1} collected %s from %s."
L["blogs_enterzone"] = "{1} entered %s."
L["blogs_exitzone"] = "{1} exited %s."
L["blogs_capturebegin"] = "%s began capturing %s."
L["blogs_capturebegin"] = "%s cancelled capturing %s."

-- Update 1.1

L["flag_begincapture"] = "You began the capturing of %s."
L["flag_captureforbidden"] = "You are not allowed to capture %s at this moment."

L["editor_minplayers_area"] = "Players required in area to capture:"
L["editor_usetostart"] = "Interact with flag entity to capture:"

-- Update 1.2.6

L["reason_minplayersarea"] = "Not enough players within bounds."
L["reason_maxzones"] = "Limit of captured zones reached."
L["reason_factionrestriction"] = "Faction can not capture this."