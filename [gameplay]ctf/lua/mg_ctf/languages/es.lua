local L = MG_CTF.Language -- Don't touch this!

-- Capture zone
L["area_defaultname"] = "Zona de captura"
L["area_capturesuccess"] = "%s fue capturada satisfactoriamente."
L["area_unknown"] = "Desconocida"
L["area_vacant"] = "No capturada"
L["area_captureimpossible"] = "Capturación deshabilitada"
L["area_contested"] = "En disputa"
L["area_reward"] = "Recompensas: "

-- Flag pole
L["flag_notcaptured"] = "¡Esta zona necesita ser previamente capturada!"
L["flag_needtobe"] = "¡Tienes que ser %s para poder obtener recompensas aquí!"
L["flag_contested"] = "¡Esta zona está en disputa!"
L["flag_notfullycaptured"] = "¡Esta zona no fue completamente capturada!"
L["flag_retrieved"] = "Has obtenido %s de %s."

-- Mini map
L["minimap_main"] = "Mini mapa"
L["minimap_drag"] = "Mover mouse: Ajustar posición"
L["minimap_scroll"] = "Desplazar: Zoom"
L["minimap_lock"] = "Fijar en jugador"

-- Admin
L["admin_edit"] = "Zona de capturada editada.\nGuárdala con el comando \"mg_ctf_save\"!"
L["admin_save"] = "%s zona(s) de captura guardadas."
L["admin_clear"] = "Zonas de captura removidas."
L["admin_notallowed"] = "No tienes los permisos suficientes para guardar las zonas de captura."
L["admin_created"] = "Zona de captura creada.\nGuárdala con el comando \"mg_ctf_save\"!"
L["admin_lookatflag"] = "Debes apuntar hacia una bandera."
L["admin_reset"] = "Recompensas restablecidas satisfactoriamente."
L["admin_reset_error"] = "¡Esta zona no está capturada!"
L["admin_tool_error"] = "¡Debes equiparte la herramienta de admin para acceder a esta función!"
L["admin_invalid_entity"] = "¡Entidad inválida!\nQuizás el límite de entidades fue alcanzado."
L["admin_remove"] = "La zona #%s fue removida."
L["admin_file_not_found"] = "La zona no fue encontrada. (%s)"
L["admin_settings_copied"] = "Configuración copiada."
L["admin_edit_faction"] = "Facciones actualizadas."

L["admin_new"] = "Click izquierdo: Crear una nueva zona de captura"
L["admin_delete"] = "Click derecho: Remover la zona frente a ti"
L["admin_settings"] = "Recargar: Abrir el panel de configuración"
L["admin_settings_ent"] = "Recargar: Abrir el panel de configuración para la bandera (entidad)."
L["admin_1stzone"] = "Click izquierdo: Establecer la primera posición de la zona de captura"
L["admin_2ndzone"] = "Click izquierdo: Establecer la segunda posición de la zona de captura"
L["admin_zone"] = "Click izquierdo: Establecer la posición de la zona de captura"
L["admin_flagpos"] = "Click izquierdo: Establecer la posición de la bandera (entidad)"
L["admin_finish"] = "Click izquierdo: Finalizar configuración"
L["admin_cancel"] = "Click derecho: Cancelar"
L["admin_savecmd"] = "Guarda la configuración con el comando de consola mg_ctf_save"

-- Editor main
L["editor_header"] = "Propiedades de %s"
L["editor_toolname"] = "Herramienta de admin"
L["editor_main"] = "Ajustes principales"
L["editor_apply"] = "Aplicar"

L["editor_invalid_entity"] = "¡Zona inválida!\nAsegúrate de que la zona que estás intentando editar esté dentro de tu rango."
L["editor_vector_error"] = "[MG CTF] %s:\n¡Vector inválido! No se pudo guardar... (%s)"
L["editor_color_error"] = "[MG CTF] %s:\n¡Color inválido! No se pudo guardar... (%s)"

L["editor_model"] = "Ingresar directorio de modelo:"
L["editor_path"] = "models/directorio.mdl"
L["editor_name"] = "Ingresa el nombre:"
L["editor_save"] = "Guardar configuración"
L["editor_not_persistant"] = "No guardes el estado de captura al cambiar de mapa:"
L["editor_minplayers"] = "Jugadores mínimos para capturar esto:"
L["editor_capturetime"] = "Tiempo necesario para capturar:"
L["editor_uncapturetime"] = "Tiempo necesario para remover captura:"

-- Categories
L["editor_cat"] = "Categoría: "
L["editor_clickhere"] = "Click aquí para volver atrás."
L["editor_current"] = "Actual: "

L["editor_cat_factions"] = "Facciones"
L["editor_cat_tool"] = "Herramienta de admin."
L["editor_cat_select"] = "Selección"
L["editor_cat_zone"] = "Zona"

-- Tool settings
L["editor_tool"] = "Ajustes de herramienta"
L["editor_tool_usesphere"] = "Usa una esfera en vez de una caja (Menor rendimiento):"
L["editor_tool_spheresize"] = "Modifica el radio de la esfera:"

-- Select zone
L["editor_select"] = "Selecciona la zona a editar..."
L["editor_select_zone"] = "Seleccionar: %s (%s)"

-- Zone Editor
L["editor_zone"] = "Editor de zonas"
L["editor_zone_num"] = "Zona #%s"
L["editor_zone_edit"] = "Crear zona"
L["editor_zone_sphere"] = "Crear esfera"
L["editor_zone_add"] = "Agregar nueva zona..."
L["editor_zone_remove"] = "Remover zona"

-- Rendering
L["editor_render"] = "Renderizado"
L["editor_render_modelscale"] = "Escala del modelo:"
L["editor_render_color"] = "Color del modelo:"
L["editor_render_material"] = "Material del modelo:"
L["editor_render_nodraw"] = "Invisible:"
L["editor_render_not_solid"] = "Sin sólido:"
L["editor_render_dont_color"] = "No colorear bandera acorde al color de la facción:"
L["editor_render_drawpos"] = "Posición de renderizado del HUD:"
L["editor_render_mode"] = "Seleccionar modo de renderizado:"
L["editor_render_fx"] = "Seleccionar FX de renderizado:"
L["editor_render_pos"] = "Posición de la bandera [Avanzado]:"

-- Sounds
L["editor_sounds"] = "Sonido"
L["editor_sound_capture_play"] = "Reproducir sonido de captura:"
L["editor_sound_capture"] = "Sonido de captura:"
L["editor_sound_capture_range"] = "Rango del sonido de captura:"
L["editor_sound_capture_pitch"] = "Tono del sonido de captura:"

-- Effects
L["editor_effects"] = "Efectos"

L["editor_effects_cat_capture"] = "Efecto: Captura"
L["editor_effects_cat_collect"] = "Efecto: Colecta"

L["editor_effects_capture_prevent"] = "Prevenir efecto de captura:"
L["editor_effects_capture_material"] = "Efecto de captura: Ingresar material:"
L["editor_effects_capture_size"] = "Efecto de captura: Tamaño del material [xMult]:"
L["editor_effects_capture_particles"] = "Efecto de captura: Cantidad de partículas [xMult]:"
L["editor_effects_capture_lifetime"] = "Efecto de captura: Duración de las partículas [xMult]:"
L["editor_effects_capture_range"] = "Efecto de captura: Rango del efecto [xMult]:"

L["editor_effects_collect_prevent"] = "Prevenir efecto de recolección de dinero:"
L["editor_effects_collect_material"] = "Efecto de recolección: Ingresar material:"
L["editor_effects_collect_size"] = "Efecto de recolección: Tamaño del material [xMult]:"
L["editor_effects_collect_particles"] = "Efecto de recolección: Cantidad de partículas [xMult]:"
L["editor_effects_collect_lifetime"] = "Efecto de recolección: Duración de las partículas [xMult]:"
L["editor_effects_collect_range"] = "Efecto de recolección: Rango del efecto [xMult]:"

-- Rewards
L["editor_rewards"] = "Recompensas"

L["editor_rewards_cat"] = "Recompensa: %s"
L["editor_rewards_cat_money"] = "Dinero"
L["editor_rewards_cat_xp"] = "XP"

L["editor_rewards_shared"] = "No compartir recompensas entre jugadores:"
L["editor_rewards_capture"] = "%s por captura satisfactoria:"

L["editor_rewards_enable"] = "Habilitar recompensas de %s con temporizador:"
L["editor_rewards_time"] = "Tiempo requerido para añadir %s:"
L["editor_rewards_amount"] = "Duración del temporizador:"
L["editor_rewards_max"] = "Máximo de %s almacenado:"
L["editor_rewards_split"] = "Dividir %s, si la capturación está deshabilitada (0-1):"

L["editor_rewards_reset"] = "Reiniciar recompensas para esta zona"

-- Copy mode
L["editor_copy"] = "Copiar ajustes de una zona de captura"
L["editor_copy_zone"] = "Copiar: %s (%s)"

-- Faction restrictions
L["editor_restrict"] = "Restringir facciones"
L["editor_restrict_setallowance"] = "Deshabilitar captura"
L["editor_restrict_setdefault"] = "Establecer como por defecto"
L["editor_restrict_unsetallowance"] = "Habilitar captura"
L["editor_restrict_unsetdefault"] = "No establecer como por defecto"
L["editor_restrict_setcapturetime"] = "Establecer multiplicador de velocidad de captura"
L["editor_restrict_setuncapturetime"] = "Establecer multiplicador de velocidad de eliminación de captura"

L["editor_restrict_faction"] = "Facción"
L["editor_restrict_allowed"] = "Captura permitida"
L["editor_restrict_default"] = "Por defecto"
L["editor_restrict_capturespeed"] = "Velocidad de captura"
L["editor_restrict_uncapturespeed"] = "Velocidad de eliminación de captura"

-- Faction setup
L["editor_faction_manage"] = "Administrar facciones"
L["editor_faction_add"] = "Agregar nueva facción..."
L["editor_faction_edit"] = "Editar facción"
L["editor_faction_remove"] = "Remover facción"
L["editor_faction_save"] = "Guardar facciones"

L["editor_faction_editor"] = "Editor de facciones (%s)"
L["editor_faction_editor_new"] = "Nueva facción"
L["editor_faction_editor_name"] = "Ingresar nombre único:"
L["editor_faction_editor_color"] = "Ingresar color:"
L["editor_faction_editor_capturespeed"] = "Velocidad de captura [xMult]:"
L["editor_faction_editor_uncapturespeed"] = "Velocidad de removimiento de captura [xMult]:"
L["editor_faction_editor_maxzones"] = "Máximo de zonas capturadas:"

L["editor_faction_editor_allowed"] = "Lista de miembros:"
L["editor_faction_editor_team"] = "Trabajo / Equipo"
L["editor_faction_editor_associated"] = "Asociado"
L["editor_faction_editor_switch"] = "Cambiar"
L["editor_faction_editor_switch_all"] = "Cambiar todas"

L["editor_faction_editor_enemies"] = "Lista de enemigos:"
L["editor_faction_editor_faction"] = "Facción"
L["editor_faction_editor_enemy"] = "Es enemiga"

L["editor_faction_editor_error"] = "[MG CTF] %s:\n¡Nombre inválido! No se pudo guardar..."
L["editor_faction_editor_save"] = "Guardar facción"

-- Adverts
L["editor_adverts"] = "Anuncios"

L["editor_adverts_cat"] = "Tipos de aviso"

L["editor_advert_global"] = "Anuncios globales, en lugar de anunciar solo a las facciones afectadas:"
L["editor_advert_anon"] = "Ocultar nombre de facciones en anuncios:"
L["editor_advert_transmit"] = "Anunciar a jugadores en la zona:"
L["editor_advert_capturesuccess"] = "Anunciar captura satisfactoria:"
L["editor_advert_capturebegin"] = "Anunciar inicio de captura:"
L["editor_advert_capturecancel"] = "Anunciar cancelación de captura:"

L["advert_capturesuccess"] = "%s fue tomada%s%s."
L["advert_capturebegin"] = "%s%s está siendo capturada%s."
L["advert_capturecancel"] = "%s%s ya no está siendo capturada%s."
L["advert_of"] = " de %s"
L["advert_by"] = " por %s"
L["advert_from"] = " de %s"

-- bLogs support
L["blogs_capturesuccess"] = "%s fue capturada por %s. (Anterior: %s)"
L["blogs_collect"] = "{1} obtuvo %s de %s."
L["blogs_enterzone"] = "{1} ingresó a la zona %s."
L["blogs_exitzone"] = "{1} dejó la zona %s."
L["blogs_capturebegin"] = "%s inició la captura de %s."
L["blogs_capturebegin"] = "%s canceló la captura de %s."

-- Update 1.1

L["flag_begincapture"] = "Comenzaste la captura de %s."
L["flag_captureforbidden"] = "No tienes permitido capturar %s en este momento."

L["editor_minplayers_area"] = "Se requieren jugadores en el área para capturar:"
L["editor_usetostart"] = "Interactuar con la entidad de bandera para capturar:"

-- Update 1.2.6

L["reason_minplayersarea"] = "Not enough players within bounds."
L["reason_maxzones"] = "Limit of captured zones reached."
L["reason_factionrestriction"] = "Faction can not capture this."