/// @description Dev HUD panels (F1–F4): perf, quest, dialogue flags, pathfinding.

#macro DEBUG_OVERLAY_PERF 0
#macro DEBUG_OVERLAY_QUEST 1
#macro DEBUG_OVERLAY_DIALOGUE 2
#macro DEBUG_OVERLAY_PATH 3

function DebugOverlay_InitGlobals() {
	if (!variable_global_exists("debug_panel_perf")) {
		global.debug_panel_perf = true;
	}
	if (!variable_global_exists("debug_panel_quest")) {
		global.debug_panel_quest = false;
	}
	if (!variable_global_exists("debug_panel_dialogue")) {
		global.debug_panel_dialogue = false;
	}
	if (!variable_global_exists("debug_panel_path")) {
		global.debug_panel_path = false;
	}
	// Legacy alias from older F3-only toggle.
	global.debug_overlay_enabled = global.debug_panel_perf;
}

function DebugOverlay_TogglePanel(_panel) {
	DebugOverlay_InitGlobals();
	switch (_panel) {
		case DEBUG_OVERLAY_PERF:
			global.debug_panel_perf = !global.debug_panel_perf;
			global.debug_overlay_enabled = global.debug_panel_perf;
			break;
		case DEBUG_OVERLAY_QUEST:
			global.debug_panel_quest = !global.debug_panel_quest;
			break;
		case DEBUG_OVERLAY_DIALOGUE:
			global.debug_panel_dialogue = !global.debug_panel_dialogue;
			break;
		case DEBUG_OVERLAY_PATH:
			global.debug_panel_path = !global.debug_panel_path;
			break;
	}
}

function DebugOverlay_IsPanelActive(_panel) {
	DebugOverlay_InitGlobals();
	switch (_panel) {
		case DEBUG_OVERLAY_PERF: return global.debug_panel_perf;
		case DEBUG_OVERLAY_QUEST: return global.debug_panel_quest;
		case DEBUG_OVERLAY_DIALOGUE: return global.debug_panel_dialogue;
		case DEBUG_OVERLAY_PATH: return global.debug_panel_path;
	}
	return false;
}

function DebugOverlay_AnyPanelActive() {
	DebugOverlay_InitGlobals();
	return global.debug_panel_perf
		|| global.debug_panel_quest
		|| global.debug_panel_dialogue
		|| global.debug_panel_path;
}

function DebugOverlay_FlagText(_value) {
	return _value ? "Y" : "N";
}

function DebugOverlay_BuildQuestLines() {
	Quest_Init();
	var info = Quest_Woodcutting_GetQuestInfo();
	var state = Quest_Woodcutting_GetState();
	var state_label = "not started";
	if (state == 1) {
		state_label = "active";
	} else if (state == 2) {
		state_label = "complete";
	}
	
	return [
		"Woodcutting state: " + state_label + " (" + string(state) + ")",
		"Logs: " + string(info.progress) + " / " + string(info.required),
		"Can turn in: " + DebugOverlay_FlagText(Quest_Woodcutting_CanComplete()),
		"Panel: " + info.status,
		"Objective: " + info.objective,
		"Return: " + info.return_to
	];
}

function DebugOverlay_BuildDialogueLines() {
	GameState_Init();
	var lines = [
		"--- GameState ---",
		"trial started: " + DebugOverlay_FlagText(GameState_IsSecondChanceTrialStarted()),
		"intro complete: " + DebugOverlay_FlagText(GameState_IsWelcomerIntroComplete()),
		"tour complete: " + DebugOverlay_FlagText(GameState_IsWelcomerGuidedTourComplete()),
		"briefing complete: " + DebugOverlay_FlagText(GameState_IsWelcomerBriefingComplete()),
		"brief remaining: " + string(GameState_GetBriefingRemainingCount()),
		"what_happened: " + DebugOverlay_FlagText(GameState_HasBriefingHeard(GAMESTATE_BRIEF_WHAT_HAPPENED)),
		"markless: " + DebugOverlay_FlagText(GameState_HasBriefingHeard(GAMESTATE_BRIEF_MARKLESS)),
		"hearthmere: " + DebugOverlay_FlagText(GameState_HasBriefingHeard(GAMESTATE_BRIEF_HEARTHMERE)),
		"sponsor: " + DebugOverlay_FlagText(GameState_HasBriefingHeard(GAMESTATE_BRIEF_SPONSOR)),
		"marks: " + DebugOverlay_FlagText(GameState_HasBriefingHeard(GAMESTATE_BRIEF_MARKS)),
		"trial_info: " + DebugOverlay_FlagText(GameState_HasBriefingHeard(GAMESTATE_BRIEF_TRIAL_INFO)),
		"woodcut approved: " + DebugOverlay_FlagText(GameState_IsWoodcuttingMarkApproved()),
		"woodcut ack: " + DebugOverlay_FlagText(GameState_IsWoodcuttingAcknowledged())
	];
	
	if (!instance_exists(obj_dialogue)) {
		array_push(lines, "--- obj_dialogue: missing ---");
		return lines;
	}
	
	with (obj_dialogue) {
		array_push(lines, "--- obj_dialogue ---");
		array_push(lines, "active: " + DebugOverlay_FlagText(active));
		array_push(lines, "conv_active: " + DebugOverlay_FlagText(conv_active));
		array_push(lines, "beat: " + string(conv_beat_type) + " #" + string(conv_beat_index));
		array_push(lines, "text_finished: " + DebugOverlay_FlagText(text_finished));
		array_push(lines, "choices_visible: " + DebugOverlay_FlagText(choices_visible));
		array_push(lines, "choices: " + string(array_length(choices)));
		array_push(lines, "prompt: " + DebugOverlay_FlagText(prompt_active));
		array_push(lines, "notice_timer: " + string(notice_timer));
		array_push(lines, "movement_locked: " + DebugOverlay_FlagText(player_movement_locked));
	}
	
	var welcomer = instance_find(obj_welcomer, 0);
	if (instance_exists(welcomer)) {
		array_push(lines, "--- Welcomer ---");
		array_push(lines, "guided_tour: " + DebugOverlay_FlagText(welcomer.guided_tour_active));
		array_push(lines, "guided_phase: " + string(welcomer.guided_phase));
		array_push(lines, "intro_node: " + string(welcomer.intro_dialogue_node));
		if (variable_instance_exists(welcomer, "intro_branches_asked")) {
			array_push(lines, "branches_asked: " + string(array_length(welcomer.intro_branches_asked)));
		}
	}
	
	return lines;
}

function DebugOverlay_BuildPathLines() {
	var lines = ["--- Player ---"];
	var player = instance_find(obj_player, 0);
	if (!instance_exists(player)) {
		array_push(lines, "obj_player: missing");
		return lines;
	}
	
	with (player) {
		array_push(lines, "moving: " + DebugOverlay_FlagText(moving));
		array_push(lines, "tile: (" + string(TileXFromPosition(x)) + "," + string(TileYFromBottom(y)) + ")");
		array_push(lines, "path len: " + string(array_length(click_path)) + " idx: " + string(click_path_index));
		array_push(lines, "pending_move: " + DebugOverlay_FlagText(pending_click_move));
		array_push(lines, "pending_action: " + string(pending_click_action));
		array_push(lines, "pending_label: " + string(pending_click_action_label));
		array_push(lines, "pending_target: " + string(pending_click_target));
		array_push(lines, "kb buffer: (" + string(buffer_x) + "," + string(buffer_y) + ")");
		array_push(lines, "npc_talk_cd: " + string(npc_talk_cooldown));
	}
	
	if (instance_exists(obj_controller)) {
		array_push(lines, "--- Controller ---");
		array_push(lines, "context menu: " + DebugOverlay_FlagText(obj_controller.menu_open));
		array_push(lines, "menu_target: " + string(obj_controller.menu_target));
	}
	
	return lines;
}

/// @returns {Real} panel height in GUI pixels
function DebugOverlay_DrawPanel(_x, _y, _title, _lines, _panel_w = 300) {
	var line_h = 14;
	var pad = 6;
	var panel_h = pad * 2 + line_h + array_length(_lines) * line_h;
	
	draw_set_alpha(0.82);
	draw_set_color(c_black);
	draw_rectangle(_x, _y, _x + _panel_w, _y + panel_h, false);
	draw_set_alpha(1);
	draw_set_color(make_color_rgb(90, 90, 98));
	draw_rectangle(_x, _y, _x + _panel_w, _y + panel_h, true);
	
	draw_set_font(fntSmaller);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_color(c_yellow);
	var text_x = _x + pad;
	var text_y = _y + pad;
	draw_text(text_x, text_y, _title);
	text_y += line_h;
	draw_set_color(c_white);
	
	for (var i = 0; i < array_length(_lines); i++) {
		draw_text(text_x, text_y, _lines[i]);
		text_y += line_h;
	}
	
	return panel_h;
}

function DebugOverlay_DrawPathWorld() {
	if (!DebugOverlay_IsPanelActive(DEBUG_OVERLAY_PATH)) {
		return;
	}
	
	var player = instance_find(obj_player, 0);
	if (!instance_exists(player)) {
		return;
	}
	
	var px = player.x;
	var py = player.y;
	
	draw_set_color(c_yellow);
	draw_set_alpha(0.9);
	
	if (player.moving) {
		draw_line(px, py, player.target_x, player.target_y);
		draw_circle(player.target_x, player.target_y, 4, false);
	}
	
	if (array_length(player.click_path) > 0) {
		var prev_x = px;
		var prev_y = py;
		for (var i = player.click_path_index; i < array_length(player.click_path); i++) {
			var pt = player.click_path[i];
			draw_line(prev_x, prev_y, pt.x, pt.y);
			draw_circle(pt.x, pt.y, 3, false);
			prev_x = pt.x;
			prev_y = pt.y;
		}
	}
	
	if (instance_exists(player.pending_click_target)) {
		var tgt = player.pending_click_target;
		draw_set_color(c_lime);
		draw_line(px, py, tgt.x, tgt.y);
		draw_circle(tgt.x, tgt.y, 6, true);
	}
	
	draw_set_alpha(1);
	draw_set_color(c_white);
}
