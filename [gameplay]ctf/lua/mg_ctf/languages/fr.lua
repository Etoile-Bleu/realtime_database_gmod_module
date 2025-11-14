local L = MG_CTF.Language -- Don't touch this!

-- Capture zone
L["area_defaultname"] = "Zone de capture"
L["area_capturesuccess"] = "%s a été capturé avec succès."
L["area_unknown"] = "Inconnu"
L["area_vacant"] = "Non capturé"
L["area_captureimpossible"] = "Capture désactivée"
L["area_contested"] = "Contesté"
L["area_reward"] = "Récompenses: "

-- Flag pole
L["flag_notcaptured"] = "Cette zone doit être capturée en premier!"
L["flag_needtobe"] = "Vous devez être %s afin de collecter des récompenses ici!"
L["flag_contested"] = "Cette zone est contestée!"
L["flag_notfullycaptured"] = "Cette zone n'est pas entièrement capturée!"
L["flag_retrieved"] = "Vous avez collecté %s de %s."

-- Mini map
L["minimap_main"] = "Mini-Carte"
L["minimap_drag"] = "Faites glisser la souris: Ajustez la position"
L["minimap_scroll"] = "Scroll: Zoom"
L["minimap_lock"] = "Verrouiller le lecteur"

-- Admin
L["admin_edit"] = "Zone de capture modifiée.\nEnregistrez-le via \"mg_ctf_save\"!"
L["admin_save"] = "%s zone de capture(s) enregistrée(s)."
L["admin_clear"] = "Zones de capture effacées."
L["admin_notallowed"] = "Vous n'avez aucune autorisation pour enregistrer les zones de capture."
L["admin_created"] = "Zone créée avec succès.\nEnregistrez-le via \"mg_ctf_save\"!"
L["admin_lookatflag"] = "Vous devez viser un drapeau."
L["admin_reset"] = "Récompenses réinitialisées avec succès."
L["admin_reset_error"] = "Cette zone n'est pas capturée!"
L["admin_tool_error"] = "Vous devez vous équiper de l'outil d'administration pour accéder à cette fonction!"
L["admin_invalid_entity"] = "Entité invalide!\nPeut-être que la limite d'entité a été atteinte."
L["admin_remove"] = "Zone #%s a été retiré."
L["admin_file_not_found"] = "La zone n'a pas pu être trouvée. (%s)"
L["admin_settings_copied"] = "Paramètres copiés."
L["admin_edit_faction"] = "Factions mises à jour."

L["admin_new"] = "Clic gauche: Créer une nouvelle zone de capture"
L["admin_delete"] = "Clic droit: Supprimer la zone devant vous"
L["admin_settings"] = "Recharger: Ouvrir le panneau des paramètres"
L["admin_settings_ent"] = "Recharger: ouvrir le panneau des paramètres pour le drapeau"
L["admin_1stzone"] = "Clic gauche: définir la première position de la zone de capture"
L["admin_2ndzone"] = "Clic gauche: définir la deuxième position de la zone de capture"
L["admin_zone"] = "Clic gauche: Définir la position de la zone de capture"
L["admin_flagpos"] = "Clic gauche: définir l'emplacement de l'entité du drapeau"
L["admin_finish"] = "Clic gauche: terminer la configuration"
L["admin_cancel"] = "Clic droit: Annuler"
L["admin_savecmd"] = "Enregistrer via la commande mg_ctf_save-console"

-- Editor main
L["editor_header"] = "Propriétés de %s"
L["editor_toolname"] = "Outil staff"
L["editor_main"] = "Réglages principaux"
L["editor_apply"] = "Appliquer"

L["editor_invalid_entity"] = "Zone invalide!\nAssurez-vous que la zone que vous essayez de modifier se trouve dans votre plage."
L["editor_vector_error"] = "[MG CTF] %s:\nVecteur non valide! Impossible d'enregistrer... (%s)"
L["editor_color_error"] = "[MG CTF] %s:\nCouleur invalide! Impossible d'enregistrer... (%s)"

L["editor_model"] = "Entrez le chemin du modèle:"
L["editor_path"] = "models/path.mdl"
L["editor_name"] = "Entrez le nom:"
L["editor_save"] = "Enregistrer les paramètres"
L["editor_not_persistant"] = "Ne pas enregistrer l'état de la capture sur les modifications de la carte:"
L["editor_minplayers"] = "Joueurs minimum:"
L["editor_capturetime"] = "Temps nécessaire pour capturer:"
L["editor_uncapturetime"] = "Temps nécessaire pour décapturer:"

-- Categories
L["editor_cat"] = "Catégorie: "
L["editor_clickhere"] = "Cliquez ici pour revenir en arrière."
L["editor_current"] = "Actuel: "

L["editor_cat_factions"] = "Factions"
L["editor_cat_tool"] = "Outil d'administration"
L["editor_cat_select"] = "Sélection"
L["editor_cat_zone"] = "Zone"

-- Tool settings
L["editor_tool"] = "Utilisation de la sphère"
L["editor_tool_usesphere"] = "Utiliser la sphère au lieu de la boîte (moins de performances):"
L["editor_tool_spheresize"] = "Modifier le rayon de la sphère:"

-- Select zone
L["editor_select"] = "Sélectionnez la zone à modifier..."
L["editor_select_zone"] = "Sélectionner: %s (%s)"

-- Zone Editor
L["editor_zone"] = "Éditeur de zones"
L["editor_zone_num"] = "Zone #%s"
L["editor_zone_edit"] = "Créer une zone"
L["editor_zone_sphere"] = "Faire une sphère"
L["editor_zone_add"] = "Ajouter une nouvelle zone..."
L["editor_zone_remove"] = "Supprimer la zone"

-- Rendering
L["editor_render"] = "Rendu"
L["editor_render_modelscale"] = "Échelle du modèle:"
L["editor_render_color"] = "Couleur du modèle:"
L["editor_render_material"] = "Matériau du modèle:"
L["editor_render_nodraw"] = "Invisible:"
L["editor_render_not_solid"] = "Pas solide:"
L["editor_render_dont_color"] = "Ne colorez pas selon la couleur de la faction:"
L["editor_render_drawpos"] = "Position de rendu du HUD:"
L["editor_render_mode"] = "Sélectionnez le mode de rendu:"
L["editor_render_fx"] = "Sélectionnez le rendu FX:"
L["editor_render_pos"] = "Position de l'entité de pavillon [Avancé]:"

-- Sounds
L["editor_sounds"] = "Sonner"
L["editor_sound_capture_play"] = "Jouer le son de capture:"
L["editor_sound_capture"] = "Capturer le son:"
L["editor_sound_capture_range"] = "Plage sonore de capture:"
L["editor_sound_capture_pitch"] = "Capturez la hauteur du son:"

-- Effects
L["editor_effects"] = "Effets"

L["editor_effects_cat_capture"] = "Effet: Capturer"
L["editor_effects_cat_collect"] = "Effet: Collecter"

L["editor_effects_capture_prevent"] = "Empêcher l'effet de capture:"
L["editor_effects_capture_material"] = "Entrer le matériel:"
L["editor_effects_capture_size"] = "Taille du matériel [Mult]:"
L["editor_effects_capture_particles"] = "Quantité de particules [Mult]:"
L["editor_effects_capture_lifetime"] = "Durée de vie des particules [Mult]:"
L["editor_effects_capture_range"] = "Gamme d'effet [Mult]:"

L["editor_effects_collect_prevent"] = "Empêcher l'effet de collecte:"
L["editor_effects_collect_material"] = "Entrer le matériel:"
L["editor_effects_collect_size"] = "Taille du matériel [Mult]:"
L["editor_effects_collect_particles"] = "Quantité de particules [Mult]:"
L["editor_effects_collect_lifetime"] = "Durée de vie des particules [Mult]:"
L["editor_effects_collect_range"] = "Gamme d'effet [Mult]:"

-- Rewards
L["editor_rewards"] = "Récompenses"

L["editor_rewards_cat"] = "Récompense: %s"
L["editor_rewards_cat_money"] = "argent"
L["editor_rewards_cat_xp"] = "XP"

L["editor_rewards_shared"] = "Ne partagez pas les récompenses entre les joueurs:"
L["editor_rewards_capture"] = "%s pour capturer avec succès:"

L["editor_rewards_enable"] = "Activer les récompenses en %s chronométré:"
L["editor_rewards_time"] = "Temps nécessaire pour ajouter de l'%s:"
L["editor_rewards_amount"] = "Montant de l'%s du minuteur:"
L["editor_rewards_max"] = "Maximum d'%s stocké:"
L["editor_rewards_split"] = "Fractionner l'%s, si la capture est désactivée [Mult]:"

L["editor_rewards_reset"] = "Réinitialiser les récompenses pour cette zone"

-- Copy mode
L["editor_copy"] = "Copier les paramètres de la zone de capture"
L["editor_copy_zone"] = "Copie: %s (%s)"

-- Faction restrictions
L["editor_restrict"] = "Restreindre les factions"
L["editor_restrict_setallowance"] = "Interdire la capture"
L["editor_restrict_setdefault"] = "Définir par défaut"
L["editor_restrict_unsetallowance"] = "Autoriser la capture"
L["editor_restrict_unsetdefault"] = "Non défini par défaut"
L["editor_restrict_setcapturetime"] = "Définir le multiplicateur de vitesse de capture"
L["editor_restrict_setuncapturetime"] = "Définir le multiplicateur de vitesse de non-capture"

L["editor_restrict_faction"] = "Faction"
L["editor_restrict_allowed"] = "Capture autorisée"
L["editor_restrict_default"] = "Faction par défaut"
L["editor_restrict_capturespeed"] = "Vitesse de capture"
L["editor_restrict_uncapturespeed"] = "Vitesse de non-capture"

-- Faction setup
L["editor_faction_manage"] = "Gérer les factions"
L["editor_faction_add"] = "Ajouter une nouvelle faction..."
L["editor_faction_edit"] = "Modifier la faction"
L["editor_faction_remove"] = "Supprimer la faction"
L["editor_faction_save"] = "Sauvegarder les factions"

L["editor_faction_editor"] = "Éditeur de faction (%s)"
L["editor_faction_editor_new"] = "Nouvelle faction"
L["editor_faction_editor_name"] = "Entrez un nom unique:"
L["editor_faction_editor_color"] = "Entrez la couleur:"
L["editor_faction_editor_capturespeed"] = "Vitesse de capture [Mult]:"
L["editor_faction_editor_uncapturespeed"] = "Vitesse de non-capture [Mult]:"
L["editor_faction_editor_maxzones"] = "Zones capturées maximales:"

L["editor_faction_editor_allowed"] = "Liste des membres:"
L["editor_faction_editor_team"] = "Travail/Equipe"
L["editor_faction_editor_associated"] = "Associé"
L["editor_faction_editor_switch"] = "Changer"
L["editor_faction_editor_switch_all"] = "Tout basculer"

L["editor_faction_editor_enemies"] = "Liste d'ennemis:"
L["editor_faction_editor_faction"] = "Faction"
L["editor_faction_editor_enemy"] = "est ennemi"

L["editor_faction_editor_error"] = "[MG CTF] %s:\nNom incorrect! Impossible d'enregistrer..."
L["editor_faction_editor_save"] = "Apply changes"

-- Adverts
L["editor_adverts"] = "Annonces"

L["editor_adverts_cat"] = "Types d'annonces"

L["editor_advert_global"] = "Publicités mondiales, au lieu des seules factions affectées:"
L["editor_advert_anon"] = "Masquer les noms de faction dans les publicités:"
L["editor_advert_transmit"] = "Annonce aux joueurs de la zone:"
L["editor_advert_capturesuccess"] = "Annonce sur capture réussie:"
L["editor_advert_capturebegin"] = "Annonce au début de la capture:"
L["editor_advert_capturecancel"] = "Annonce sur capture annuler:"

L["advert_capturesuccess"] = "%s a été pris%s%s."
L["advert_capturebegin"] = "%s%s est capturé%s."
L["advert_capturecancel"] = "%s%s n'est plus capturé%s."
L["advert_of"] = " de %s"
L["advert_by"] = " par %s"
L["advert_from"] = " de %s"

-- bLogs support
L["blogs_capturesuccess"] = "%s a été capturé par %s. (Précédent: %s)"
L["blogs_collect"] = "{1} collecté %s de %s."
L["blogs_enterzone"] = "{1} entré %s."
L["blogs_exitzone"] = "{1} sortie %s."
L["blogs_capturebegin"] = "%s a commencé à capturer %s."
L["blogs_capturebegin"] = "%s capture annulée %s."

-- Update 1.1

L["flag_begincapture"] = "Vous avez commencé la capture de %s."
L["flag_captureforbidden"] = "Vous n'êtes pas autorisé à capturer %s à ce moment là."

L["editor_minplayers_area"] = "Joueurs requis dans la zone à capturer:"
L["editor_usetostart"] = "Interagir avec l'entité de drapeau à capturer:"

-- Update 1.2.6

L["reason_minplayersarea"] = "Not enough players within bounds."
L["reason_maxzones"] = "Limit of captured zones reached."
L["reason_factionrestriction"] = "Faction can not capture this."