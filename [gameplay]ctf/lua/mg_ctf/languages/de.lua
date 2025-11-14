local L = MG_CTF.Language -- Don't touch this!

-- Capture zone
L["area_defaultname"] = "Eroberungszone"
L["area_capturesuccess"] = "%s wurde erfolgreich eingenommen."
L["area_unknown"] = "Unbenannt"
L["area_vacant"] = "Unbesetzt"
L["area_captureimpossible"] = "Einnahme nicht möglich"
L["area_contested"] = "Umkämpft"
L["area_reward"] = "Belohnungen: "

-- Flag pole
L["flag_notcaptured"] = "Diese Zone ist nicht eingenommen!"
L["flag_needtobe"] = "Du musst %s angehören, um hier Belohnungen abzuholen!"
L["flag_contested"] = "Diese Zone ist umkämpft!"
L["flag_notfullycaptured"] = "Diese Zone ist nicht vollständig eingenommen!"
L["flag_retrieved"] = "Du hast %s von %s abgeholt."

-- Mini map
L["minimap_main"] = "Karte"
L["minimap_drag"] = "Mit Maus ziehen: Position anpassen"
L["minimap_scroll"] = "Scrollrad: Zoom"
L["minimap_lock"] = "Auf Spieler zentrieren"

-- Admin
L["admin_edit"] = "Eroberungszonenname editiert.\nSpeichere sie mit \"mg_ctf_save\"!"
L["admin_save"] = "%s Eroberungszone(n) gespeichert."
L["admin_clear"] = "Eroberungszonen geklärt."
L["admin_notallowed"] = "Du verfügst nicht über die nötigen Privilegien zum Speichern von Eroberungszonen."
L["admin_created"] = "Zone erfolgreich erstellt.\nSpeichere sie mit \"mg_ctf_save\""
L["admin_lookatflag"] = "Du musst auf eine Flaggengegenstand schauen."
L["admin_reset"] = "Du hast die Belohnungen erfolgreich zurückgesetzt."
L["admin_reset_error"] = "Diese Zone gehört niemandem!"
L["admin_tool_error"] = "Du musst das Admin-Werkzeug ausrüsten, damit diese Funktion geht!"
L["admin_invalid_entity"] = "Üngültiges Objekt!\nVielleicht wurde das Limit erreicht."
L["admin_remove"] = "Zone #%s entfernt."
L["admin_file_not_found"] = "Zone konnte nicht gefunden werden. (%s)"
L["admin_settings_copied"] = "Einstellungen kopiert."
L["admin_edit_faction"] = "Fraktionen aktualisiert."

L["admin_new"] = "Linksklick: Erstelle eine neue Eroberungszone"
L["admin_delete"] = "Rechtsklick: Entferne die Zone in Front von dir"
L["admin_settings"] = "Nachladen: Einstellungen aufrufen"
L["admin_settings_ent"] = "Nachladen: Einstellungen des Flaggengegenstands aufrufen"
L["admin_1stzone"] = "Linksklick: Setze die erste Position der Eroberungszone"
L["admin_2ndzone"] = "Linksklick: Setze die zweite Position der Eroberungszone"
L["admin_zone"] = "Linksklick: Setze die Position der Eroberungszone"
L["admin_flagpos"] = "Linksklick: Setze die Position für den Flaggengegenstand"
L["admin_finish"] = "Linksklick: Fertigstellen"
L["admin_cancel"] = "Rechtsklick: Abbrechen"
L["admin_savecmd"] = "Speichern über mg_ctf_save-Konsolenbefehl"

-- Editor main
L["editor_header"] = "Eigenschaften von %s"
L["editor_toolname"] = "Admin-Werkzeug"
L["editor_main"] = "Haupt-Einstellungen"
L["editor_apply"] = "Übernehmen"

L["editor_invalid_entity"] = "Ungültige Zone!\nStelle sicher, dass die Zone, die du versuchst zu editieren, in deiner Nähe ist."
L["editor_vector_error"] = "[MG CTF] %s:\nUngültiger Vektor! Kann nicht speichern... (%s)"
L["editor_color_error"] = "[MG CTF] %s:\nUngültige Farbe! Kann nicht speichern... (%s)"

L["editor_model"] = "Modellpfad angeben:"
L["editor_path"] = "models/path.mdl"
L["editor_name"] = "Name angeben:"
L["editor_save"] = "Einstellungen übernehmen"
L["editor_not_persistant"] = "Eroberungsstatus nicht über Mapwechsel hinweg speichern:"
L["editor_minplayers"] = "Minimale Spieleranzahl:"
L["editor_capturetime"] = "Benötigte Zeit zum Erobern:"
L["editor_uncapturetime"] = "Benötigte Zeit zum Zurück-Erobern:"

-- Categories
L["editor_cat"] = "Kategorie: "
L["editor_clickhere"] = "Hier klicken, um zurück zu gehen."
L["editor_current"] = "Derzeitig: "

L["editor_cat_factions"] = "Fraktionen"
L["editor_cat_tool"] = "Admin-Werkzeug"
L["editor_cat_select"] = "Auswahl"
L["editor_cat_zone"] = "Zone"

-- Tool settings
L["editor_tool"] = "Sphäre benutzen"
L["editor_tool_usesphere"] = "Kugel statt Box benutzen (Leistungshemmend):"
L["editor_tool_spheresize"] = "Radius der Kugel modifizieren:"

-- Select zone
L["editor_select"] = "Zone zum Editieren auswählen..."
L["editor_select_zone"] = "Auswählen: %s (%s)"

-- Zone Editor
L["editor_zone"] = "Zonen-Editor"
L["editor_zone_num"] = "Zone #%s"
L["editor_zone_edit"] = "Zone neusetzen"
L["editor_zone_sphere"] = "Als Sphäre neusetzen"
L["editor_zone_add"] = "Neue Zone hinzufügen..."
L["editor_zone_remove"] = "Zone entfernen"

-- Rendering
L["editor_render"] = "Rendering-Einstellungen"
L["editor_render_modelscale"] = "Modell-Größe:"
L["editor_render_color"] = "Farbe des Modells:"
L["editor_render_material"] = "Material des Modells:"
L["editor_render_nodraw"] = "Unsichtbar:"
L["editor_render_not_solid"] = "Durchgehbar:"
L["editor_render_dont_color"] = "Nicht anhand eroberter Fraktion färben:"
L["editor_render_drawpos"] = "Zeichnungsposition des HUDs:"
L["editor_render_mode"] = "Render-Modus auswählen:"
L["editor_render_fx"] = "Render-FX auswählen:"
L["editor_render_pos"] = "Position des Flaggengegenstands [Erweitert]:"

-- Sounds
L["editor_sounds"] = "Ton-Einstellungen"
L["editor_sound_capture_play"] = "Eroberungston abspielen:"
L["editor_sound_capture"] = "Eroberungston angeben:"
L["editor_sound_capture_range"] = "Eroberungston Reichweite:"
L["editor_sound_capture_pitch"] = "Eroberungston Tonhöhe:"

-- Effects
L["editor_effects"] = "Effekt-Einstellungen"

L["editor_effects_cat_capture"] = "Effekt: Erobern"
L["editor_effects_cat_collect"] = "Effekt: Einsammeln"

L["editor_effects_capture_prevent"] = "Effekt präventieren:"
L["editor_effects_capture_material"] = "Material angeben:"
L["editor_effects_capture_size"] = "Größe des Materials [Multi]:"
L["editor_effects_capture_particles"] = "Anzahl der Partikel [Multi]:"
L["editor_effects_capture_lifetime"] = "Lebensdauer des Effekts [Multi]:"
L["editor_effects_capture_range"] = "Reichweite des Effekts [Multi]:"

L["editor_effects_collect_prevent"] = "Effekt präventieren:"
L["editor_effects_collect_material"] = "Material angeben:"
L["editor_effects_collect_size"] = "Größe des Materials [Multi]:"
L["editor_effects_collect_particles"] = "Anzahl der Partikel [Multi]:"
L["editor_effects_collect_lifetime"] = "Lebensdauer des Effekts [Multi]:"
L["editor_effects_collect_range"] = "Reichweite des Effekts [Multi]:"

-- Rewards
L["editor_rewards"] = "Belohnungs-Einstellungen"

L["editor_rewards_cat"] = "Belohnung: %s"
L["editor_rewards_cat_money"] = "Geld"
L["editor_rewards_cat_xp"] = "XP"

L["editor_rewards_shared"] = "Nicht unter Spielern aufteilen:"
L["editor_rewards_capture"] = "%s für erfolgreiche Eroberung:"

L["editor_rewards_enable"] = "Zeitbasierte Belohnungen für %s erlauben:"
L["editor_rewards_time"] = "Zeit, bis %s generiert wird:"
L["editor_rewards_amount"] = "Anzahl an %s, was generiert wird:"
L["editor_rewards_max"] = "Maximale Anzahl an %s:"
L["editor_rewards_split"] = "%s aufteilen, wenn Erobern nicht möglich ist [Multi]:"

L["editor_rewards_reset"] = "Belohnungen für diese Zone zurücksetzen"

-- Copy mode
L["editor_copy"] = "Einstellungen von Eroberungszone kopieren"
L["editor_copy_zone"] = "Kopieren: %s (%s)"

-- Faction restrictions
L["editor_restrict"] = "Fraktions-Beschränkungen"
L["editor_restrict_setallowance"] = "Eroberung verbieten"
L["editor_restrict_setdefault"] = "Als Standard setzen"
L["editor_restrict_unsetallowance"] = "Eroberung erlauben"
L["editor_restrict_unsetdefault"] = "Als Standard zurücksetzen"
L["editor_restrict_setcapturetime"] = "Eroberungs-Geschw.-Multiplikator setzen"
L["editor_restrict_setuncapturetime"] = "Rückeroberungs-Geschw.-Multiplikator setzen"

L["editor_restrict_faction"] = "Fraktion"
L["editor_restrict_allowed"] = "Eroberung erlaubt"
L["editor_restrict_default"] = "Standard-Fraktion"
L["editor_restrict_capturespeed"] = "Eroberungs-Geschw."
L["editor_restrict_uncapturespeed"] = "Rückeroberungs-Geschw."

-- Faction setup
L["editor_faction_manage"] = "Fraktionen managen"
L["editor_faction_add"] = "Neue Fraktion hinzufügen..."
L["editor_faction_edit"] = "Fraktion editieren"
L["editor_faction_remove"] = "Fraktion entfernen"
L["editor_faction_save"] = "Fraktionen speichern"

L["editor_faction_editor"] = "Fraktions-Editor (%s)"
L["editor_faction_editor_new"] = "Neue Fraktion"
L["editor_faction_editor_name"] = "Einzigartiger Name angeben:"
L["editor_faction_editor_color"] = "Farbe angeben:"
L["editor_faction_editor_capturespeed"] = "Eroberungs-Geschw. [Multi]:"
L["editor_faction_editor_uncapturespeed"] = "Rückeroberungs-Geschw. [Multi]:"
L["editor_faction_editor_maxzones"] = "Maximale eroberte Zonen:"

L["editor_faction_editor_allowed"] = "Mitgliederliste:"
L["editor_faction_editor_team"] = "Beruf / Team"
L["editor_faction_editor_associated"] = "Zugehörig"
L["editor_faction_editor_switch"] = "Ändern"
L["editor_faction_editor_switch_all"] = "Alle ändern"

L["editor_faction_editor_enemies"] = "Gegnerliste:"
L["editor_faction_editor_faction"] = "Fraktion"
L["editor_faction_editor_enemy"] = "Verfeindet"

L["editor_faction_editor_error"] = "[MG CTF] %s:\nUngültiger Name! Kann nicht speichern..."
L["editor_faction_editor_save"] = "Änderungen übernehmen"

-- Adverts
L["editor_adverts"] = "Ankündigungen"

L["editor_adverts_cat"] = "Advert types"

L["editor_advert_global"] = "Globale Ankündigung, statt nur an betroffene Fraktionen:"
L["editor_advert_anon"] = "Fraktionsnamen in Ankündigungen verstecken:"
L["editor_advert_transmit"] = "Spielern innerhalb der Zone ankündigen:"
L["editor_advert_capturesuccess"] = "Ankündigung bei erfolgreicher Eroberung:"
L["editor_advert_capturebegin"] = "Ankündigung bei Start einer Eroberung:"
L["editor_advert_capturecancel"] = "Ankündigung bei Abbruch einer Eroberung:"

L["advert_capturesuccess"] = "%s%s wurde%s erobert."
L["advert_capturebegin"] = "%s%s wird%s erobert."
L["advert_capturecancel"] = "%s%s wird nicht länger%s erobert."
L["advert_of"] = " von %s"
L["advert_by"] = " durch %s"
L["advert_from"] = " von %s"

-- bLogs support
L["blogs_capturesuccess"] = "%s wurde von %s eingenommen. (Vorher: %s)"
L["blogs_collect"] = "{1} hat %s von %s eingesammelt."
L["blogs_enterzone"] = "{1} betrat %s."
L["blogs_exitzone"] = "{1} verließ %s."
L["blogs_capturebegin"] = "%s haben begonnen, %s einzunehmen."
L["blogs_capturebegin"] = "%s haben abgebrochen, %s einzunehmen."

-- Update 1.1

L["flag_begincapture"] = "Du hast angefangen, %s einzunehmen."
L["flag_captureforbidden"] = "Du kannst %s zur Zeit nicht einnehmen."

L["editor_minplayers_area"] = "Minimale Spieleranzahl in der Zone zum Erobern:"
L["editor_usetostart"] = "Mit Flaggengegenstand zum Erobern interagieren:"

-- Update 1.2.6

L["reason_minplayersarea"] = "Nicht genügend Spieler in der Nähe."
L["reason_maxzones"] = "Limit an eroberten Zonen erreicht."
L["reason_factionrestriction"] = "Fraktion kann dies nicht erobern."