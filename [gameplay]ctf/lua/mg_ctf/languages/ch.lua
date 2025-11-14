local L = MG_CTF.Language -- 不要碰这个!

-- 占领区域设置
L["area_defaultname"] = "占领区域"
L["area_capturesuccess"] = "%s 被成功占领."
L["area_unknown"] = "未知"
L["area_vacant"] = "未占领的"
L["area_captureimpossible"] = "禁用占领"
L["area_contested"] = "可以争夺"
L["area_reward"] = "奖励: "

-- 旗杆设置
L["flag_notcaptured"] = "需要先占领这个区域!"
L["flag_needtobe"] = "你必须是 %s 的人, 才能在这里领取奖励!"
L["flag_contested"] = "这个区域可以争夺!"
L["flag_notfullycaptured"] = "此区域没有被完全占领!"
L["flag_retrieved"] = "你争夺了 %s 来自 %s."

-- 小地图设置
L["minimap_main"] = "小地图"
L["minimap_drag"] = "拖动鼠标: 调整位置"
L["minimap_scroll"] = "滚动鼠标: 缩放大小"
L["minimap_lock"] = "锁定玩家"

-- 管理员设置
L["admin_edit"] = "已编辑占领区域.\n使用以下指令保存 \"mg_ctf_save\"!"
L["admin_save"] = "%s 占领区域已被保存."
L["admin_clear"] = "占领区域已被清除."
L["admin_notallowed"] = "你没有任何权限来保存占领区域."
L["admin_created"] = "成功创建区域.\n使用以下指令保存 \"mg_ctf_save\"!"
L["admin_lookatflag"] = "你必须瞄准一个旗帜实体."
L["admin_reset"] = "奖励成功重置."
L["admin_reset_error"] = "此区域未被占领!"
L["admin_tool_error"] = "你需要配备管理工具才能使用此功能!"
L["admin_invalid_entity"] = "无效的实体!\n可能已经达到了实体的上限."
L["admin_remove"] = "区域 #%s 已被移除."
L["admin_file_not_found"] = "找不到区域. (%s)"
L["admin_settings_copied"] = "已复制设置."
L["admin_edit_faction"] = "更新了派系."

L["admin_new"] = "左键点击: 创建一个新的占领区域"
L["admin_delete"] = "右键点击: 移除你面前的区域"
L["admin_settings"] = "重新装填(R): 打开设置面板"
L["admin_settings_ent"] = "重新装填(R): 打开旗帜实体的设置面板"
L["admin_1stzone"] = "左键点击: 设置占领区域的第一个位置"
L["admin_2ndzone"] = "左键点击: 设置占领区域的第二个位置"
L["admin_zone"] = "左键点击: 设置占领区域的位置"
L["admin_flagpos"] = "左键点击: 设置旗帜实体的位置"
L["admin_finish"] = "左键点击: 完成设置"
L["admin_cancel"] = "右键点击: 取消"
L["admin_savecmd"] = "使用 mg_ctf_save-console 指令进行保存"

-- 主要编辑
L["editor_header"] = "%s 的属性"
L["editor_toolname"] = "管理员工具"
L["editor_main"] = "主要设置"
L["editor_apply"] = "应用"

L["editor_invalid_entity"] = "无效区域!\n确保你在需要编辑的区域内."
L["editor_vector_error"] = "[MG CTF] %s:\n无效的矢量! 无法保存... (%s)"
L["editor_color_error"] = "[MG CTF] %s:\n无效的颜色! 无法保存... (%s)"

L["editor_model"] = "输入模型路径:"
L["editor_path"] = "models/path.mdl"
L["editor_name"] = "输入名称:"
L["editor_save"] = "保存设置"
L["editor_not_persistant"] = "不要在地图变化时保存占领状态:"
L["editor_minplayers"] = "最小玩家数:"
L["editor_capturetime"] = "需要占领的时间:"
L["editor_uncapturetime"] = "需要解除占领的时间:"

-- 分类设置
L["editor_cat"] = "分类: "
L["editor_clickhere"] = "点击这里返回."
L["editor_current"] = "目前状况: "

L["editor_cat_factions"] = "派系"
L["editor_cat_tool"] = "管理员工具"
L["editor_cat_select"] = "选择"
L["editor_cat_zone"] = "区域"

-- 工具设置
L["editor_tool"] = "使用范围"
L["editor_tool_usesphere"] = "使用球体代替盒子(低性能):"
L["editor_tool_spheresize"] = "修改球体的半径:"

-- 选择区域
L["editor_select"] = "选择区域进行编辑..."
L["editor_select_zone"] = "选择: %s (%s)"

-- 区域编辑
L["editor_zone"] = "编辑区域"
L["editor_zone_num"] = "区域 #%s"
L["editor_zone_edit"] = "制作区域"
L["editor_zone_sphere"] = "制作球体"
L["editor_zone_add"] = "添加新的区域..."
L["editor_zone_remove"] = "移除区域"

-- 渲染设置
L["editor_render"] = "渲染"
L["editor_render_modelscale"] = "模型比例:"
L["editor_render_color"] = "模型颜色:"
L["editor_render_material"] = "模型材质:"
L["editor_render_nodraw"] = "隐形的:"
L["editor_render_not_solid"] = "不牢固:"
L["editor_render_dont_color"] = "不要根据派系颜色进行着色:"
L["editor_render_drawpos"] = "渲染HUD的位置:"
L["editor_render_mode"] = "选择渲染模式:"
L["editor_render_fx"] = "选择渲染效果:"
L["editor_render_pos"] = "旗帜实体的位置[高级]:"

-- 音乐设置
L["editor_sounds"] = "音乐"
L["editor_sound_capture_play"] = "播放占领的音乐:"
L["editor_sound_capture"] = "占领音乐:"
L["editor_sound_capture_range"] = "占领音乐的范围:"
L["editor_sound_capture_pitch"] = "占领音乐的音调:"

-- 效果设置
L["editor_effects"] = "效果"

L["editor_effects_cat_capture"] = "效果: 占领"
L["editor_effects_cat_collect"] = "效果: 收集"

L["editor_effects_capture_prevent"] = "防止占领效果:"
L["editor_effects_capture_material"] = "输入材质:"
L["editor_effects_capture_size"] = "材质的尺寸[多样性]:"
L["editor_effects_capture_particles"] = "颗粒的数量[多样性]:"
L["editor_effects_capture_lifetime"] = "颗粒的存在时间[多样性]:"
L["editor_effects_capture_range"] = "效果范围[多样性]:"

L["editor_effects_collect_prevent"] = "防止收集效果:"
L["editor_effects_collect_material"] = "输入材质:"
L["editor_effects_collect_size"] = "材质的尺寸[多样性]:"
L["editor_effects_collect_particles"] = "颗粒的数量[多样性]:"
L["editor_effects_collect_lifetime"] = "颗粒的存在时间[多样性]:"
L["editor_effects_collect_range"] = "效果范围[多样性]:"

-- 奖励设置
L["editor_rewards"] = "奖励"

L["editor_rewards_cat"] = "奖励: %s"
L["editor_rewards_cat_money"] = "钱"
L["editor_rewards_cat_xp"] = "经验值"

L["editor_rewards_shared"] = "不要在玩家之间分享奖励:"
L["editor_rewards_capture"] = "奖励 %s 因为占领成功:"

L["editor_rewards_enable"] = "启用定时奖励 %s:"
L["editor_rewards_time"] = "增加所需时间 %s:"
L["editor_rewards_amount"] = "定时器 %s 金额:"
L["editor_rewards_max"] = "最大存储量 %s:"
L["editor_rewards_split"] = "分裂 %s, 如果占领功能被禁用[多样性]:"

L["editor_rewards_reset"] = "重置该区域的奖励"

-- 复制模式设置
L["editor_copy"] = "从占领区域复制设置"
L["editor_copy_zone"] = "复制: %s (%s)"

-- 派系限制设置
L["editor_restrict"] = "派系限制"
L["editor_restrict_setallowance"] = "不允许占领"
L["editor_restrict_setdefault"] = "设置为默认值"
L["editor_restrict_unsetallowance"] = "允许占领"
L["editor_restrict_unsetdefault"] = "未设置为默认值"
L["editor_restrict_setcapturetime"] = "设置占领速度倍数"
L["editor_restrict_setuncapturetime"] = "设置非占领速度倍数"

L["editor_restrict_faction"] = "派系"
L["editor_restrict_allowed"] = "允许占领"
L["editor_restrict_default"] = "默认派系"
L["editor_restrict_capturespeed"] = "占领速度"
L["editor_restrict_uncapturespeed"] = "非占领速度"

-- 派系设置
L["editor_faction_manage"] = "管理派系"
L["editor_faction_add"] = "添加新的派系..."
L["editor_faction_edit"] = "编辑派系"
L["editor_faction_remove"] = "移除派系"
L["editor_faction_save"] = "保存派系"

L["editor_faction_editor"] = "编辑派系 (%s)"
L["editor_faction_editor_new"] = "新的派系"
L["editor_faction_editor_name"] = "输入唯一的名称:"
L["editor_faction_editor_color"] = "输入颜色:"
L["editor_faction_editor_capturespeed"] = "占领速度[多样性]:"
L["editor_faction_editor_uncapturespeed"] = "非占领速度[多样性]:"
L["editor_faction_editor_maxzones"] = "最大占领区域:"

L["editor_faction_editor_allowed"] = "成员名单:"
L["editor_faction_editor_team"] = "职业 / 团队"
L["editor_faction_editor_associated"] = "相关的"
L["editor_faction_editor_switch"] = "更改"
L["editor_faction_editor_switch_all"] = "更改全部"

L["editor_faction_editor_enemies"] = "敌人名单:"
L["editor_faction_editor_faction"] = "派系"
L["editor_faction_editor_enemy"] = "是敌人"

L["editor_faction_editor_error"] = "[MG CTF] %s:\n无效的名称! 无法保存..."
L["editor_faction_editor_save"] = "应用修改"

-- 提醒设置
L["editor_adverts"] = "提醒"

L["editor_adverts_cat"] = "提醒类型"

L["editor_advert_global"] = "全局性的提醒, 而不是只针对受影响的派系:"
L["editor_advert_anon"] = "在提醒中隐藏派系名称:"
L["editor_advert_transmit"] = "给区域内的玩家提醒:"
L["editor_advert_capturesuccess"] = "成功占领后的提醒:"
L["editor_advert_capturebegin"] = "占领开始时的提醒:"
L["editor_advert_capturecancel"] = "占领取消的提醒:"

L["advert_capturesuccess"] = "被 %s 拿走%s%s."
L["advert_capturebegin"] = "%s%s 正在被占领%s."
L["advert_capturecancel"] = "%s%s 不再被占领%s."
L["advert_of"] = " 的 %s"
L["advert_by"] = " 来自 %s"
L["advert_from"] = " 从 %s"

-- bLogs支持设置
L["blogs_capturesuccess"] = "%s 被 %s 占领了. (上一页: %s)"
L["blogs_collect"] = "{1} 收集到了 %s 来自 %s."
L["blogs_enterzone"] = "{1} 加入了 %s."
L["blogs_exitzone"] = "{1} 退出了 %s."
L["blogs_capturebegin"] = "%s 开始占领 %s."
L["blogs_capturebegin"] = "%s 取消占领 %s."

-- Update 1.1

L["flag_begincapture"] = "您開始捕獲 %s."
L["flag_captureforbidden"] = "您現在不能捕獲 %s."

L["editor_minplayers_area"] = "玩家需要佔領的區域:"
L["editor_usetostart"] = "與標誌實體交互以捕獲:"

-- Update 1.2.6

L["reason_minplayersarea"] = "Not enough players within bounds."
L["reason_maxzones"] = "Limit of captured zones reached."
L["reason_factionrestriction"] = "Faction can not capture this."