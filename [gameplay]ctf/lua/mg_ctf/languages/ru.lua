local L = MG_CTF.Language -- Don't touch this!

-- Capture zone
L["area_defaultname"] = "Зона захвата"
L["area_capturesuccess"] = "%s Была успешно захвачена."
L["area_unknown"] = "Неизвестно"
L["area_vacant"] = "Не захвачено"
L["area_captureimpossible"] = "Захват недоступен"
L["area_contested"] = "Отстаивание"
L["area_reward"] = "награды: "

-- Flag pole
L["flag_notcaptured"] = "Эта зона сначала должна быть захвачена!"
L["flag_needtobe"] = "Вы должны быть %s Для получения награды!"
L["flag_contested"] = "Эта зона отстаивается!"
L["flag_notfullycaptured"] = "Эта зона захвачена не полностью!"
L["flag_retrieved"] = "Вы собрали %s с %s."

-- Mini map
L["minimap_main"] = "Мини карта"
L["minimap_drag"] = "Тянуть курсором: Установить позицию"
L["minimap_scroll"] = "Прокрутка: Зум"
L["minimap_lock"] = "Закрепить на игроке"

-- Admin
L["admin_edit"] = "Зона захвата отредактирована.\nСохранить в \"mg_ctf_save\"!"
L["admin_save"] = "%s Зона/ы захвата сохранены."
L["admin_clear"] = "Зоны захвата очищены."
L["admin_notallowed"] = "У Вас нет прав на сохранение зон захвата."
L["admin_created"] = "Зона успешно создана.\nСохранить в \"mg_ctf_save\"!"
L["admin_lookatflag"] = "Вы должны смотреть на энтити флага."
L["admin_reset"] = "Награды успешно сброшены."
L["admin_reset_error"] = "Эта зона не захвачена!"
L["admin_tool_error"] = "Вам нужно взять Админ тул чтобы получить доступ к этой функции!"
L["admin_invalid_entity"] = "Неправильный энтити!\nВозможно достигнут лимит энтити."
L["admin_remove"] = "Zone #%s Была удалена."
L["admin_file_not_found"] = "Зона не найдена. (%s)"
L["admin_settings_copied"] = "Настройки скопированы."
L["admin_edit_faction"] = "Фракции обновлены."

L["admin_new"] = "ЛКМ: Создать новую зону захвата"
L["admin_delete"] = "ПКМ: Удалить зону перед Вами"
L["admin_settings"] = "Перезарядка: Открыть панель настройки"
L["admin_settings_ent"] = "Перезарядка: Открыть панель настройки для энтити флага"
L["admin_1stzone"] = "ЛКМ: Установить первую позицию зоны захвата"
L["admin_2ndzone"] = "ЛКМ: Установить вторую позицию зоны захвата"
L["admin_zone"] = "ЛКМ: Установить позицию зоны захвата"
L["admin_flagpos"] = "ЛКМ: Установить энтити флага"
L["admin_finish"] = "ЛКМ: Закончить настройку"
L["admin_cancel"] = "ПКМ: Закрыть"
L["admin_savecmd"] = "Сохранить в mg_ctf_save-console command"

-- Editor main
L["editor_header"] = "Собственность %s"
L["editor_toolname"] = "Админ тул"
L["editor_main"] = "Главные настройки"
L["editor_apply"] = "Применить"

L["editor_invalid_entity"] = "Неправильная зона!\nУбедитесь что редактируемая зона в вашем радиусе."
L["editor_vector_error"] = "[MG CTF] %s:\nНеправильный вектор! Нельзя сохранить... (%s)"
L["editor_color_error"] = "[MG CTF] %s:\nНеправильный цвет! Нельзя сохранить... (%s)"

L["editor_model"] = "Введите путь модели:"
L["editor_path"] = "models/path.mdl"
L["editor_name"] = "Введите название:"
L["editor_save"] = "Сохранить настройки"
L["editor_not_persistant"] = "Не сохранять статус зоны при изменении карты:"
L["editor_minplayers"] = "Минимум игроков для захвата:"
L["editor_capturetime"] = "Время захвата:"
L["editor_uncapturetime"] = "Время для освобождения:"

-- Categories
L["editor_cat"] = "Категория: "
L["editor_clickhere"] = "Нажмите сюда чтобы вернуться назад."
L["editor_current"] = "Данное: "

L["editor_cat_factions"] = "Фракции"
L["editor_cat_tool"] = "Админ тул"
L["editor_cat_select"] = "Выбор"
L["editor_cat_zone"] = "Зона"

-- Tool settings
L["editor_tool"] = "Настройки тула"
L["editor_tool_usesphere"] = "Использовать сферу вместо квадрата (Меньше производительность):"
L["editor_tool_spheresize"] = "Настроить радиус сферы:"

-- Select zone
L["editor_select"] = "Выберите зону для редактирования..."
L["editor_select_zone"] = "Выбрать: %s (%s)"

-- Zone Editor
L["editor_zone"] = "Редактор зоны"
L["editor_zone_num"] = "Зона #%s"
L["editor_zone_edit"] = "Создать зону"
L["editor_zone_sphere"] = "Создать сферу"
L["editor_zone_add"] = "Добавить новую зону..."
L["editor_zone_remove"] = "Удалить зону"

-- Rendering
L["editor_render"] = "Рендеринг"
L["editor_render_modelscale"] = "Масштаб модели:"
L["editor_render_color"] = "Цыет модели:"
L["editor_render_material"] = "Материал модели:"
L["editor_render_nodraw"] = "Невидимость:"
L["editor_render_not_solid"] = "Не твердый:"
L["editor_render_dont_color"] = "Не перекрашить энитит флага в зависимости от фракции:"
L["editor_render_drawpos"] = "Рендер позиции HUD'a:"
L["editor_render_mode"] = "Выбрать режим рендера:"
L["editor_render_fx"] = "Выбрать спецэффекты рендера:"
L["editor_render_pos"] = "Позиция энитит флага [Продвинутая]:"

-- Sounds
L["editor_sounds"] = "Звук"
L["editor_sound_capture_play"] = "Проиграть звук захвата:"
L["editor_sound_capture"] = "Звук захвата:"
L["editor_sound_capture_range"] = "Радиус звука захвата:"
L["editor_sound_capture_pitch"] = "Тональность звука захвата:"

-- Effects
L["editor_effects"] = "Эффекты"

L["editor_effects_cat_capture"] = "Эффект: Захват"
L["editor_effects_cat_collect"] = "Эффект: Сбор"

L["editor_effects_capture_prevent"] = "Предотвратить эффект завхата:"
L["editor_effects_capture_material"] = "Эффект захвата: Введите материал:"
L["editor_effects_capture_size"] = "Эффект захвата: Размер материала [xMult]:"
L["editor_effects_capture_particles"] = "Эффект захвата: Кол-во частиц [xMult]:"
L["editor_effects_capture_lifetime"] = "Эффект захвата: время сущ-ия частиц [xMult]:"
L["editor_effects_capture_range"] = "Эффект захвата: Радиус эффекта [xMult]:"

L["editor_effects_collect_prevent"] = "Предотвратить сбор денег-эффект:"
L["editor_effects_collect_material"] = "Эффект сбора: Введите материал:"
L["editor_effects_collect_size"] = "Эффект сбора: Размер материала [xMult]:"
L["editor_effects_collect_particles"] = "Эффект сбора: Кол-во частиц [xMult]:"
L["editor_effects_collect_lifetime"] = "Эффект сбора: время сущ-ия частиц [xMult]:"
L["editor_effects_collect_range"] = "Эффект сбора: Радиус эффекта [xMult]:"

-- Rewards
L["editor_rewards"] = "Награды"

L["editor_rewards_cat"] = "Награда: %s"
L["editor_rewards_cat_money"] = "Деньги"
L["editor_rewards_cat_xp"] = "Опыт"

L["editor_rewards_shared"] = "Не делить награды между игроками:"
L["editor_rewards_capture"] = "%s за успешный захват:"

L["editor_rewards_enable"] = "Включить %s награду по таймеру:"
L["editor_rewards_time"] = "Время до выдачи %s:"
L["editor_rewards_amount"] = "Кол-во %s по таймеру:"
L["editor_rewards_max"] = "Макс. вместимость %s:"
L["editor_rewards_split"] = "Разделить %s, если захват выключен (0-1):"

L["editor_rewards_reset"] = "Обнулить награды для этой зоны"

-- Copy mode
L["editor_copy"] = "Копировать настройки с зоны захвата"
L["editor_copy_zone"] = "Копировать: %s (%s)"

-- Faction restrictions
L["editor_restrict"] = "Ограничить фракции"
L["editor_restrict_setallowance"] = "запретить захват"
L["editor_restrict_setdefault"] = "Выставить по-умолчанию"
L["editor_restrict_unsetallowance"] = "Разрешить захват"
L["editor_restrict_unsetdefault"] = "Сбросить по-умолчанию"
L["editor_restrict_setcapturetime"] = "Установить множитель скорости захвата"
L["editor_restrict_setuncapturetime"] = "Установить множитель скорости освобождения"

L["editor_restrict_faction"] = "Фракция"
L["editor_restrict_allowed"] = "Захват разрешен"
L["editor_restrict_default"] = "По-умолчанию"
L["editor_restrict_capturespeed"] = "Скорость захвата"
L["editor_restrict_uncapturespeed"] = "Скорость освобождения"

-- Faction setup
L["editor_faction_manage"] = "Управление фракциями"
L["editor_faction_add"] = "Добавить новую фракцию..."
L["editor_faction_edit"] = "Редактировать фракцию"
L["editor_faction_remove"] = "Удалить фракцию"
L["editor_faction_save"] = "Сохранить фракции"

L["editor_faction_editor"] = "Редактор фракции (%s)"
L["editor_faction_editor_new"] = "Новая фракция"
L["editor_faction_editor_name"] = "Введите уникальное название:"
L["editor_faction_editor_color"] = "Введите цвет:"
L["editor_faction_editor_capturespeed"] = "Скорость захвата [xMult]:"
L["editor_faction_editor_uncapturespeed"] = "Скорость освобождения [xMult]:"
L["editor_faction_editor_maxzones"] = "Максимум захваченных зон:"

L["editor_faction_editor_allowed"] = "Список участников:"
L["editor_faction_editor_team"] = "Работа / Команда"
L["editor_faction_editor_associated"] = "Связанное"
L["editor_faction_editor_switch"] = "Переключить"
L["editor_faction_editor_switch_all"] = "Переключить все"

L["editor_faction_editor_enemies"] = "Список врагов:"
L["editor_faction_editor_faction"] = "Фракция"
L["editor_faction_editor_enemy"] = "Враг"

L["editor_faction_editor_error"] = "[MG CTF] %s:\nНеправильное имя! Нельзя сохранить..."
L["editor_faction_editor_save"] = "Сохранить фракцию"

-- Adverts
L["editor_adverts"] = "Объявления"

L["editor_adverts_cat"] = "Виды обьявлений"

L["editor_advert_global"] = "Глобальные объявления вместо объявлений фракциям:"
L["editor_advert_anon"] = "Скрыть названия фракций в объявлениях:"
L["editor_advert_transmit"] = "Объявление игрокам в зоне:"
L["editor_advert_capturesuccess"] = "Объявление при успешном захвате:"
L["editor_advert_capturebegin"] = "Объявление при начале захвата:"
L["editor_advert_capturecancel"] = "Объявление при прекращении захвата:"

L["advert_capturesuccess"] = "%s была захвачена%s%s."
L["advert_capturebegin"] = "%s%s захватывается%s."
L["advert_capturecancel"] = "%s%s больше не захватывается%s."
L["advert_of"] = "  %s"
L["advert_by"] = "  %s"
L["advert_from"] = " из %s"

-- bLogs support
L["blogs_capturesuccess"] = "%s была захвачена фракцией %s. (Предыдущая: %s)"
L["blogs_collect"] = "{1} Собрано %s с %s."
L["blogs_enterzone"] = "{1} Вход в %s."
L["blogs_exitzone"] = "{1} Выход с %s."
L["blogs_capturebegin"] = "%s Начат захват %s."
L["blogs_capturebegin"] = "%s Захват остановлен %s." 

-- Update 1.1

L["flag_begincapture"] = "Вы начали захват %s."
L["flag_captureforbidden"] = "Вам не разрешено снимать %s в этот момент."

L["editor_minplayers_area"] = "Требуются игроки в зоне для захвата:"
L["editor_usetostart"] = "Взаимодействовать с объектом флага для захвата:"

-- Update 1.2.6

L["reason_minplayersarea"] = "Not enough players within bounds."
L["reason_maxzones"] = "Limit of captured zones reached."
L["reason_factionrestriction"] = "Faction can not capture this."