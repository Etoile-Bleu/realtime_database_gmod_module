local L = MG_CTF.Language -- Don't touch this!

-- Capture zone
L["area_defaultname"] = "Strefa przejęcia"
L["area_capturesuccess"] = "%s pomyślnie został przejęty."
L["area_unknown"] = "Nieznany"
L["area_vacant"] = "Nieprzechwycony"
L["area_captureimpossible"] = "Przejmowanie anulowane"
L["area_contested"] = "Zajęty"
L["area_reward"] = "Nagrody: "

-- Flag pole
L["flag_notcaptured"] = "Ta strefa musi być najpierw przejęta!"
L["flag_needtobe"] = "Musisz mieć %s, aby odebrać tutaj nagrody!"
L["flag_contested"] = "This zone is contested!"
L["flag_notfullycaptured"] = "This zone is not fully captured!"
L["flag_retrieved"] = "Zebrałeś %s z %s."

-- Mini map
L["minimap_main"] = "Mini mapa"
L["minimap_drag"] = "Przeciągnij myszką: Dostosuj pozycję"
L["minimap_scroll"] = "Scroll: Przybliżenie"
L["minimap_lock"] = "Zablokuj na graczu"

-- Admin
L["admin_edit"] = "Strefa przejęcia edytowana.\nZapisz to przez \"mg_ctf_save\"!"
L["admin_save"] = "%s zapisanych stref przejęcia."
L["admin_clear"] = "Wyczyszczono strefy przejęcia."
L["admin_notallowed"] = "Nie masz permisji, aby zapisywać strefy przejęcia."
L["admin_created"] = "Strefa pomyślnie utworzona.\nZapisz to przez \"mg_ctf_save\"!"
L["admin_lookatflag"] = "Musisz celować w flagę."
L["admin_reset"] = "Pomyślnie zresetowano nagrody."
L["admin_reset_error"] = "Ta strefa nie jest przejęta!"
L["admin_tool_error"] = "Aby uzyskać dostęp do tej funkcji, musisz mieć narzędzie administratora!"
L["admin_invalid_entity"] = "Niewłaściwy przedmiot!\nPrawdopodobnie osiągnięto limit przedmiotów."
L["admin_remove"] = "Strefa #%s została usunięta."
L["admin_file_not_found"] = "Strefa nie mogła zostać znaleziona (%s)"
L["admin_settings_copied"] = "Ustawienia skopiowane."
L["admin_edit_faction"] = "Zaktualizowano frakcje"

L["admin_new"] = "LeftClick: Stwórz nową strefe "
L["admin_delete"] = "RightClick: Usuń strefę, która jest przed Tobą"
L["admin_settings"] = "Reload: Otwórz panel ustawień"
L["admin_settings_ent"] = "Reload: Otwórz panel ustawień dla flagi"
L["admin_1stzone"] = "Leftclick: Ustaw pierwszą pozycję strefy przejmowania"
L["admin_2ndzone"] = "Leftclick: Ustaw drugą pozycję strefy przejmowania"
L["admin_zone"] = "Leftclick: Ustaw pozycję strefy przejmowania"
L["admin_flagpos"] = "Leftclick: Ustaw lokalizację flagi"
L["admin_finish"] = "Leftclick: Zatwierdź ustawienia"
L["admin_cancel"] = "Rightclick: Anuluj"
L["admin_savecmd"] = "Zapisz poprzez komendę mg_ctf_save-console w konsoli"

-- Editor main
L["editor_header"] = " właściwości of %s"
L["editor_toolname"] = "Urządzienia administracji"
L["editor_main"] = "Ustawienia główne"
L["editor_apply"] = "Zastosować"

L["editor_invalid_entity"] = "Nieprawidłowa strefa!\nUpewnij się, że strefa, którą próbujesz edytować, znajduje się w Twoim zakresie."
L["editor_vector_error"] = "[MG CTF] %s:\nNieprawidłowy wektor! Nie można zapisać...(%s)"
L["editor_color_error"] = "[MG CTF] %s:\nNieprawidłowy kolor! Nie można zapisać...(%s)"

L["editor_model"] = "Podaj ścieżkę modelu:"
L["editor_path"] = "models/path.mdl"
L["editor_name"] = "Wpisz pseudonim:"
L["editor_save"] = "Zapisz ustawienia"
L["editor_not_persistant"] = "Nie zapisuj stanu przechwytywania po zmianach na mapie:"
L["editor_minplayers"] = "Minimalna liczba graczy, aby to uchwycić:"
L["editor_capturetime"] = "Potrzebny czas na uchwycenie:"
L["editor_uncapturetime"] = "Potrzebny czas na odbicie:"

-- Categories
L["editor_cat"] = "Kategorie: "
L["editor_clickhere"] = "Kliknij tutaj by się cofnąć."
L["editor_current"] = "Obecny: "

L["editor_cat_factions"] = "Frakcje"
L["editor_cat_tool"] = "Narzędzie administratora"
L["editor_cat_select"] = "Wybór"
L["editor_cat_zone"] = "Strefa"

-- Tool settings
L["editor_tool"] = "Ustawienia narzędzi"
L["editor_tool_usesphere"] = "Użyj sfery zamiast pudełka (Mniejsza wydajność):"
L["editor_tool_spheresize"] = "Modyfikacja promienia kuli:"

-- Select zone
L["editor_select"] = "Wybierz strefę do edycji..."
L["editor_select_zone"] = "Wybierz: %s (%s)"

-- Zone Editor
L["editor_zone"] = "Edytor strefy"
L["editor_zone_num"] = "Strefa #%s"
L["editor_zone_edit"] = "Stwórz strefe"
L["editor_zone_sphere"] = "Stwórz sfere"
L["editor_zone_add"] = "Dodaj nową strefe..."
L["editor_zone_remove"] = "Usuń strefę"

-- Rendering
L["editor_render"] = "Renderowanie"
L["editor_render_modelscale"] = "Model scali:"
L["editor_render_color"] = "Color modela:"
L["editor_render_material"] = "Materiał modela:"
L["editor_render_nodraw"] = "Niewidzialny:"
L["editor_render_not_solid"] = "Nietrwałe:"
L["editor_render_dont_color"] = "Nie koloruj flagi jednostki w zależności od przejętej frakcji:"
L["editor_render_drawpos"] = "WYrenderuj pozycję HUDa:"
L["editor_render_mode"] = "Wybierz tryb renderowania:"
L["editor_render_fx"] = "Wybierz render FX:"
L["editor_render_pos"] = "Pozycja jednostki flagowej [Zaawansowane]:"

-- Sounds
L["editor_sounds"] = "Dzwięk"
L["editor_sound_capture_play"] = "Odtwórz dzwięk przejęcia:"
L["editor_sound_capture"] = "Dzwięk przejęcia:"
L["editor_sound_capture_range"] = "Zasięg wychwytywania dźwięku:"
L["editor_sound_capture_pitch"] = "Wychwytywanie wysokości dźwięku:"

-- Effects
L["editor_effects"] = "Efekty"

L["editor_effects_cat_capture"] = "Efekt: Przechwytywanie"
L["editor_effects_cat_collect"] = "Efekt: Zbierz"

L["editor_effects_capture_prevent"] = "Zapobieganie efektowi przechwytywania:"
L["editor_effects_capture_material"] = "Efekt przejęcia: Wybierz materiał:"
L["editor_effects_capture_size"] = "Efekt przejęcia: Wielkość materiału [xMult]:"
L["editor_effects_capture_particles"] = "Efekt przejęcia: Ilość cząstek [xMult]:"
L["editor_effects_capture_lifetime"] = "Efekt przejęcia: Długość trwania cząstek [xMult]:"
L["editor_effects_capture_range"] = "Efekt przejęcia: Zasięg oddziaływania [xMult]:"

L["editor_effects_collect_prevent"] = "Zapobieganie zbieraniu pieniędzy-efekt:"
L["editor_effects_collect_material"] = "Zbierz efekt: Wpisz materiał:"
L["editor_effects_collect_size"] = "Zbierz efekt: Rozmiar materiału [xMult]:"
L["editor_effects_collect_particles"] = "Zbierz efekt: Liczba cząstek [xMult]:"
L["editor_effects_collect_lifetime"] = "Zbierz efekt: Długość cząstek [xMult]:"
L["editor_effects_collect_range"] = "Zbierz efekt: Zasięg efektu [xMult]:"

-- Rewards
L["editor_rewards"] = "Nagrody"

L["editor_rewards_cat"] = "Nagroda: %s"
L["editor_rewards_cat_money"] = "pieniądze"
L["editor_rewards_cat_xp"] = "XP"

L["editor_rewards_shared"] = "Nie dziel nagród między graczami:"
L["editor_rewards_capture"] = "%s za pomyślne przejęcie:"

L["editor_rewards_enable"] = "Włączenie czasowych nagród %s:"
L["editor_rewards_time"] = "Czas potrzebny na dodanie %s:"
L["editor_rewards_amount"] = "Kwota %s timera:"
L["editor_rewards_max"] = "Maksymalnie przechowywane %s:"
L["editor_rewards_split"] = "Podziel %s, jeśli przejmowanie jest wyłączone (0-1):"

L["editor_rewards_reset"] = "Zresetuj nagrody dla tej strefy"

-- Copy mode
L["editor_copy"] = "Kopiój ustawieńia z obszaru przechwytywania"
L["editor_copy_zone"] = "Skopiuj: %s (%s)"

-- Faction restrictions
L["editor_restrict"] = "Ograniczenie frakcji"
L["editor_restrict_setallowance"] = "Nie zezwalaj na przechwytywanie"
L["editor_restrict_setdefault"] = "Ustaw na domyślne"
L["editor_restrict_unsetallowance"] = "Zezwól na przechwytywanie"
L["editor_restrict_unsetdefault"] = "Ustaw domyślnie"
L["editor_restrict_setcapturetime"] = "Ustaw mnożnik prędkości przechwytywania"
L["editor_restrict_setuncapturetime"] = "Ustaw mnożnik prędkości przechwytywania"

L["editor_restrict_faction"] = "Frakcja"
L["editor_restrict_allowed"] = "Przejmowanie zezwolone"
L["editor_restrict_default"] = "Domyślne"
L["editor_restrict_capturespeed"] = "Szybkość przechwytywania"
L["editor_restrict_uncapturespeed"] = "Prędkość rozmontowania"

-- Faction setup
L["editor_faction_manage"] = "Zarządzaj frakcją"
L["editor_faction_add"] = "Utwórz nową frakcje..."
L["editor_faction_edit"] = "Edytuj frakcję"
L["editor_faction_remove"] = "Usuń frakcję"
L["editor_faction_save"] = "Zapisz frakcję"

L["editor_faction_editor"] = "Edytor frakcji (%s)"
L["editor_faction_editor_new"] = "Nowa frakcja"
L["editor_faction_editor_name"] = "Wpisz unikalne imię:"
L["editor_faction_editor_color"] = "Wybierz kolor:"
L["editor_faction_editor_capturespeed"] = "Czas przejmowania [xMult]:"
L["editor_faction_editor_uncapturespeed"] = "Czas Nie przejmowania [xMult]:"
L["editor_faction_editor_maxzones"] = "Maksymalna liczba przechwyconych stref:"

L["editor_faction_editor_allowed"] = "lista użytkowników:"
L["editor_faction_editor_team"] = "Praca / Drużyna"
L["editor_faction_editor_associated"] = "Powiązane"
L["editor_faction_editor_switch"] = "Zamień"
L["editor_faction_editor_switch_all"] = "Zamień wszystko"

L["editor_faction_editor_enemies"] = "Lista przeciwników:"
L["editor_faction_editor_faction"] = "Frakcja"
L["editor_faction_editor_enemy"] = "Czy wróg"

L["editor_faction_editor_error"] = "[MG CTF] %s:\nNie prawidłowe imie! Nie można zapisać..."
L["editor_faction_editor_save"] = "Zapisz frakcję"

-- Adverts
L["editor_adverts"] = "Ogłoszenia"

L["editor_adverts_cat"] = "Rodzaje ogłoszeń"

L["editor_advert_global"] = "Ogłoszenia globalne, zamiast tylko do dotkniętych frakcji:"
L["editor_advert_anon"] = "Schowaj nazwy frakcji w ogłoszeniach:"
L["editor_advert_transmit"] = "Ogłoszenie dla graczy w strefie:"
L["editor_advert_capturesuccess"] = "Ogłoś o pomyślnym przejęciu:"
L["editor_advert_capturebegin"] = "Ogłos o starcie przejmowania:"
L["editor_advert_capturecancel"] = "Ogłoś o przestaniu przejmowania:"

L["advert_capturesuccess"] = "%s Zostało przejęte%s%s."
L["advert_capturebegin"] = "%s%s Jest przejmowane%s."
L["advert_capturecancel"] = "%s%s Nie jest już przejmowane%s."
L["advert_of"] = " z %s"
L["advert_by"] = " przez %s"
L["advert_from"] = " od %s"

-- bLogs support
L["blogs_capturesuccess"] = "%s Zostało przejęte przez %s. (Poprzedni: %s)"
L["blogs_collect"] = "{1} zebrano %s z %s."
L["blogs_enterzone"] = "{1} weszło na %s."
L["blogs_exitzone"] = "{1} wyszło z %s."
L["blogs_capturebegin"] = "%s Zaczeło przejmować %s."
L["blogs_capturebegin"] = "%s Przestało przejmować %s."

-- Update 1.1

L["flag_begincapture"] = "Rozpocząłeś chwytanie %s."
L["flag_captureforbidden"] = "Nie możesz schwytać %s w tym momencie."

L["editor_minplayers_area"] = "Gracze wymagani w obszarze do przejęcia:"
L["editor_usetostart"] = "Wejdź w interakcję z podmiotem flagi, aby przechwycić:"

-- Update 1.2.6

L["reason_minplayersarea"] = "Not enough players within bounds."
L["reason_maxzones"] = "Limit of captured zones reached."
L["reason_factionrestriction"] = "Faction can not capture this."