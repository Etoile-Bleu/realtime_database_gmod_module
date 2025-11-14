local L = MG_CTF.Language -- Don't touch this!

-- Capture zone
L["area_defaultname"] = "Bölgeyi ele geçir"
L["area_capturesuccess"] = "%s başarıyla ele geçirildi."
L["area_unknown"] = "Bilinmeyen"
L["area_vacant"] = "Ele Geçirilmemiş"
L["area_captureimpossible"] = "Ele geçirme deaktif"
L["area_contested"] = "Çekişmeli"
L["area_reward"] = "Ödüller: "

-- Flag pole
L["flag_notcaptured"] = "Bölgenin ilk ele geçirilmesi lazım!"
L["flag_needtobe"] = "Ödülleri toplamak için %s olman lazım!"
L["flag_contested"] = "Bu bölge çekişmeli durumda"
L["flag_notfullycaptured"] = "Bu alan tam olarak ele geçirilmemiş!"
L["flag_retrieved"] = "%s'yı %s dan aldın."

-- Mini map
L["minimap_main"] = "Küçük harita"
L["minimap_drag"] = "Fareyi sürükle: Pozisyonu ayarla"
L["minimap_scroll"] = "Kaydır: Yakınlaştır"
L["minimap_lock"] = "Oyuncuya kitle"

-- Admin
L["admin_edit"] = "Bölge düzenlendi.\nŞurası aracılığıyla kaydedin \"mg_ctf_save\"!"
L["admin_save"] = "%s tane bölge kaydedildi."
L["admin_clear"] = "Bölgeler temizlendi."
L["admin_notallowed"] = "Bölgeleri kaydetmeye yeterli yetkin yok."
L["admin_created"] = "Bölge başarıyla kaydedildi.\nŞurası aracılığıyla kaydedin \"mg_ctf_save\"!"
L["admin_lookatflag"] = "Bayrak varlığına bakmanız lazım."
L["admin_reset"] = "Ödüller sıfırlandı."
L["admin_reset_error"] = "Bölge ele geçirilmemiş!"
L["admin_tool_error"] = "Fonksiyonu kullanmak için admin eşyasını almanız gerekmektedir"
L["admin_invalid_entity"] = "Geçersiz varlık!\nVarlık limiti dolmuş olabilir."
L["admin_remove"] = "#%s bölgesi kaldırıldı."
L["admin_file_not_found"] = "Bölge bulunamadı. (%s)"
L["admin_settings_copied"] = "Ayarlar kopyalandı."
L["admin_edit_faction"] = "Taraflar güncellendi."

L["admin_new"] = "Soltık: Yeni bir bölge oluştur"
L["admin_delete"] = "Sağtık: Önündeki bölgeyi kaldır"
L["admin_settings"] = "Yenidendoldur: Ayarlarıa ç"
L["admin_settings_ent"] = "Yenidendoldur: Bayrak varlığı için ayarları aç"
L["admin_1stzone"] = "Soltık: Bölgenin ilk pozisyonunu ayarla"
L["admin_2ndzone"] = "Soltık: Bölgenin ikinci pozisyonunu ayarla"
L["admin_zone"] = "Soltık: Bölgenin pozisyonunu ayarla"
L["admin_flagpos"] = "Soltık: Bayrak varlığını ayarla"
L["admin_finish"] = "Soltık: Ayarlamayı sonlandır"
L["admin_cancel"] = "Sağtık: İptal"
L["admin_savecmd"] = "mg_ctf_save-console komutuyla kaydet"

-- Editor main
L["editor_header"] = "%s'nın özellikleri"
L["editor_toolname"] = "Admin Aracı"
L["editor_main"] = "Ana Ayarlar"
L["editor_apply"] = "Onayla"

L["editor_invalid_entity"] = "Geçersiz alan!\nAlanın senin menzilinde olduğundan emin ol."
L["editor_vector_error"] = "[MG CTF] %s:\nGeçersiz vektör! Kaydedilemedi... (%s)"
L["editor_color_error"] = "[MG CTF] %s:\nGeçersiz renk! kaydedilemedi... (%s)"

L["editor_model"] = "Model bağlantısını gir:"
L["editor_path"] = "models/path.mdl"
L["editor_name"] = "Editör İsmi:"
L["editor_save"] = "Ayarları Kaydet"
L["editor_not_persistant"] = "Harita değişiklikleriyle ele geçirme durumunu kaydetme:"
L["editor_minplayers"] = "Ele geçirmek için azami oyuncu sayısı:"
L["editor_capturetime"] = "Ele geçirmek için gereken zaman:"
L["editor_uncapturetime"] = "Tarafsız hale gelmesi için gereken süre:"

-- Categories
L["editor_cat"] = "Kategori: "
L["editor_clickhere"] = "Buraya tıklayarak geri git."
L["editor_current"] = "Mevcut: "

L["editor_cat_factions"] = "Taraflar"
L["editor_cat_tool"] = "Admin Aracı"
L["editor_cat_select"] = "Seçim"
L["editor_cat_zone"] = "Bölge"

-- Tool settings
L["editor_tool"] = "Araç ayarları"
L["editor_tool_usesphere"] = "Kutu yerine küre kullanın (daha az performans):"
L["editor_tool_spheresize"] = "Kürenin yarıçapını değiştir:"

-- Select zone
L["editor_select"] = "Düzenlenecek bölgeyi seçin..."
L["editor_select_zone"] = "Şunu Seç: %s (%s)"

-- Zone Editor
L["editor_zone"] = "Bölge Düzenleyicisi"
L["editor_zone_num"] = "Bölge #%s"
L["editor_zone_edit"] = "Bölge yarat"
L["editor_zone_sphere"] = "Küre yarat"
L["editor_zone_add"] = "Yeni bölge yarat..."
L["editor_zone_remove"] = "Bölgeyi kaldır"

-- Rendering
L["editor_render"] = "Renderlanıyor"
L["editor_render_modelscale"] = "Model Boyutu:"
L["editor_render_color"] = "Modelin Tengi:"
L["editor_render_material"] = "Modelin materyeli:"
L["editor_render_nodraw"] = "Görünmez:"
L["editor_render_not_solid"] = "Katı Değil:"
L["editor_render_dont_color"] = "Ele geçiren tarafa göre rengi ayarlama:"
L["editor_render_drawpos"] = "HUD'un renderanma pozisyonu:"
L["editor_render_mode"] = "Render modunu seç:"
L["editor_render_fx"] = "Render efektini seç:"
L["editor_render_pos"] = "Bayrak varlığının pozisyonu [Gelişmiş]:"

-- Sounds
L["editor_sounds"] = "Ses"
L["editor_sound_capture_play"] = "Ele geçirme sesini oynat:"
L["editor_sound_capture"] = "Ele geçirme sesi:"
L["editor_sound_capture_range"] = "Ele geçirme sesi mesafesi:"
L["editor_sound_capture_pitch"] = "Ele geçirme sesinin frekansı:"

-- Effects
L["editor_effects"] = "Efektler"

L["editor_effects_cat_capture"] = "Efekt: Ele Geçirme"
L["editor_effects_cat_collect"] = "Efekt: Topla"

L["editor_effects_capture_prevent"] = "Ele geçirme efektini engelle:"
L["editor_effects_capture_material"] = "Ele geçirme efekti: materyal giriş yap:"
L["editor_effects_capture_size"] = "Ele geçirme efekti: Materyal boyutu [xMult]:"
L["editor_effects_capture_particles"] = "Ele geçirme efekti: Parçacık sayısı [xMult]:"
L["editor_effects_capture_lifetime"] = "Ele geçirme efekti: Parçacık kalış süresi [xMult]:"
L["editor_effects_capture_range"] = "Ele geçirme efekti: Efekt menzili [xMult]:"

L["editor_effects_collect_prevent"] = "Para toplama efektini engelle:"
L["editor_effects_collect_material"] = "Toplama efekti: materyal giriş yap:"
L["editor_effects_collect_size"] = "Toplama efekti: Materyal boyutu [xMult]:"
L["editor_effects_collect_particles"] = "Toplama efekti: Parçacık sayısı [xMult]:"
L["editor_effects_collect_lifetime"] = "Toplama efekti: Parçacık kalış süresi [xMult]:"
L["editor_effects_collect_range"] = "Toplama efekti: Efekt menzili [xMult]:"

-- Rewards
L["editor_rewards"] = "Ödüller"

L["editor_rewards_cat"] = "Ödül: %s"
L["editor_rewards_cat_money"] = "Para"
L["editor_rewards_cat_xp"] = "TP"

L["editor_rewards_shared"] = "Oyuncular arasında ödülü paylaştırma:"
L["editor_rewards_capture"] = "Ele geçirme sonucu gelen %s:"

L["editor_rewards_enable"] = "Süreli gelen ödülleri aktif et:"
L["editor_rewards_time"] = "%s eklenmesi için gereken süre:"
L["editor_rewards_amount"] = "Süreçin %s miktarı:"
L["editor_rewards_max"] = "Maksimum depolanan %s:"
L["editor_rewards_split"] = "Ele geçirme deaktifse %s böl (0-1):"

L["editor_rewards_reset"] = "Bu bölge için ödülleri sıfırla"

-- Copy mode
L["editor_copy"] = "Ele geçirme bölgesinin ayarlarını kopyala"
L["editor_copy_zone"] = "Kopyala: %s (%s)"

-- Faction restrictions
L["editor_restrict"] = "Tarafları kısıtla"
L["editor_restrict_setallowance"] = "Ele geçirmeyi kapat"
L["editor_restrict_setdefault"] = "Varsayılan olarak ayarla"
L["editor_restrict_unsetallowance"] = "Ele geçirmeyi aç"
L["editor_restrict_unsetdefault"] = "Varsayılan olarak ayarlama"
L["editor_restrict_setcapturetime"] = "Ele geçirme hızı çarpanını ayarla"
L["editor_restrict_setuncapturetime"] = "Ele geçirmeme hızı çarpanını ayarla"

L["editor_restrict_faction"] = "Taraf"
L["editor_restrict_allowed"] = "Ele geçirmeye izin ver"
L["editor_restrict_default"] = "Varsayılan"
L["editor_restrict_capturespeed"] = "Ele geçirme hızı"
L["editor_restrict_uncapturespeed"] = "Ele geçirmeme hızı"

-- Faction setup
L["editor_faction_manage"] = "Tarafları Ayarla"
L["editor_faction_add"] = "Yeni taraf ekle..."
L["editor_faction_edit"] = "Tarafı düzenle"
L["editor_faction_remove"] = "Tarafı kaldır"
L["editor_faction_save"] = "Tarafı kaydet"

L["editor_faction_editor"] = "Taraf düzenleyicisi (%s)"
L["editor_faction_editor_new"] = "Yeni taraf"
L["editor_faction_editor_name"] = "Eşsiz bir isim girin:"
L["editor_faction_editor_color"] = "Renk girin:"
L["editor_faction_editor_capturespeed"] = "ELe geçirme hızı [xMult]:"
L["editor_faction_editor_uncapturespeed"] = "Elden kaybetme hızı [xMult]:"
L["editor_faction_editor_maxzones"] = "Maksimum ele geçirilmiş bölgeler:"

L["editor_faction_editor_allowed"] = "Üye listesi:"
L["editor_faction_editor_team"] = "Meslek / Takım"
L["editor_faction_editor_associated"] = "İlişkili"
L["editor_faction_editor_switch"] = "Değiştir"
L["editor_faction_editor_switch_all"] = "Hepsini değiştir"

L["editor_faction_editor_enemies"] = "Düşman listesi:"
L["editor_faction_editor_faction"] = "Taraf"
L["editor_faction_editor_enemy"] = "Düşman"

L["editor_faction_editor_error"] = "[MG CTF] %s:\nGeçersiz isim! Kaydedilemedi..."
L["editor_faction_editor_save"] = "Tarafı Kaydet"

-- Adverts
L["editor_adverts"] = "Duyurular"

L["editor_adverts_cat"] = "Duyuru türleri"

L["editor_advert_global"] = "Sadece ilişkili gruba değil global bir duyuru geç:"
L["editor_advert_anon"] = "Duyurularda taraf ismini sakla:"
L["editor_advert_transmit"] = "Bölge içindeki kişilere duyur:"
L["editor_advert_capturesuccess"] = "Başarılı bir ele geçirmede duyur:"
L["editor_advert_capturebegin"] = "Ele geçirme başlandığında duyur:"
L["editor_advert_capturecancel"] = "Ele geçirme iptal olduğunda duyur:"

L["advert_capturesuccess"] = "%s ele geçirildi%s%s."
L["advert_capturebegin"] = "%s%s ele geçirilmekte%s."
L["advert_capturecancel"] = "%s%s artık ele geçirilmiyor%s."
L["advert_of"] = "%s'nın"
L["advert_by"] = "%s tarafından"
L["advert_from"] = "%s tarafından"

-- bLogs support
L["blogs_capturesuccess"] = "%s, %s tarafından ele geçirildi. (Önceki: %s)"
L["blogs_collect"] = "{1}, %s kadarı şuradan ele geçirdi %s."
L["blogs_enterzone"] = "{1}, %s'ya giriş yaptı."
L["blogs_exitzone"] = "{1}, %s'dan çıkış yaptı."
L["blogs_capturebegin"] = "%s, %s'yı ele geçirmeye başladı."
L["blogs_capturebegin"] = "%s, %s'yı ele geçirmeyi durduru."

-- Update 1.1

L["flag_begincapture"] = "yakalamaya başladın %s."
L["flag_captureforbidden"] = "yakalamana izin verilmiyor %s şu anda."

L["editor_minplayers_area"] = "Yakalamak için bölgede gerekli oyuncular:"
L["editor_usetostart"] = "Yakalamak için bayrak varlığıyla etkileşim kurun:"

-- Update 1.2.6

L["reason_minplayersarea"] = "Not enough players within bounds."
L["reason_maxzones"] = "Limit of captured zones reached."
L["reason_factionrestriction"] = "Faction can not capture this."