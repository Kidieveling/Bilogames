/// @description Dialogue state and helpers

active = false;
active_speaker = noone;
conversation_speaker = noone;
text = "";
choices = [];
choice_index = 0;
input_cooldown = 0;
prompt_active = false;
prompt_text = "";
notice_text = "";
notice_timer = 0;

anchor_to_speaker = false;
player_movement_locked = false;

// Typewriter + choice reveal (legacy menus and conversation beats)
display_text = "";
full_text = "";
typewriter_index = 0;
typewriter_speed = 1;
typewriter_timer = 0;
text_finished = false;
choices_visible = false;

// Paced conversation mode
conv_active = false;
conv_beats = [];
conv_beat_index = 0;
conv_beat_type = "";
conv_pause_timer = 0;
conv_line_pause_after = 0;
conv_line_pause_active = false;
panel_speaker_name = "";
dialogue_dim_background = false;

#region Typewriter

Dialogue_ResetTypewriter = function(_full_text) {
	full_text = _full_text;
	text = _full_text;
	display_text = "";
	typewriter_index = 0;
	typewriter_timer = 0;
	text_finished = (string_length(_full_text) <= 0);
	
	if (text_finished) {
		display_text = _full_text;
		typewriter_index = string_length(_full_text);
	}
	
	Dialogue_UpdateChoicesVisibility();
};

Dialogue_UpdateChoicesVisibility = function() {
	if (!text_finished || array_length(choices) <= 0) {
		choices_visible = false;
		return;
	}
	
	if (conv_active && conv_beat_type != DIALOGUE_BEAT_CHOICES) {
		choices_visible = false;
		return;
	}
	
	choices_visible = true;
};

Dialogue_TickTypewriter = function() {
	if (!active || text_finished || string_length(full_text) <= 0) {
		return;
	}
	
	typewriter_timer += 1;
	if (typewriter_timer < typewriter_speed) {
		return;
	}
	
	typewriter_timer = 0;
	typewriter_index = min(string_length(full_text), typewriter_index + DIALOGUE_TYPEWRITER_CHARS_PER_FRAME);
	display_text = string_copy(full_text, 1, typewriter_index);
	
	if (typewriter_index >= string_length(full_text)) {
		text_finished = true;
		display_text = full_text;
		Dialogue_UpdateChoicesVisibility();
	}
};

Dialogue_FinishTypewriter = function() {
	if (text_finished) {
		return;
	}
	
	typewriter_index = string_length(full_text);
	display_text = full_text;
	text_finished = true;
	Dialogue_UpdateChoicesVisibility();
};

Dialogue_ResetPresentationState = function() {
	display_text = "";
	full_text = "";
	text = "";
	typewriter_index = 0;
	typewriter_timer = 0;
	text_finished = false;
	choices_visible = false;
};

Dialogue_GetBodyTextForLayout = function() {
	if (!active) {
		return "";
	}
	
	if (text_finished) {
		return full_text;
	}
	
	return display_text;
};

#endregion

#region Legacy menu API

SetActiveSpeaker = function(_speaker) {
	active_speaker = _speaker;
	conversation_speaker = _speaker;
	anchor_to_speaker = instance_exists(_speaker);
};

show = function(_text, _choices) {
	EndConversation();
	player_movement_locked = false;
	prompt_active = false;
	prompt_text = "";
	notice_timer = 0;
	
	choices = _choices;
	choice_index = 0;
	active = true;
	conv_active = false;
	dialogue_dim_background = false;
	
	panel_speaker_name = DialogueUI_GetSpeakerName(GetActiveSpeaker());
	var parsed = DialogueUI_ParseFormattedLine(_text);
	if (panel_speaker_name == "") {
		panel_speaker_name = parsed.speaker;
	}
	
	var bodyText = _text;
	if (parsed.speaker != "") {
		bodyText = parsed.body;
	}
	
	Dialogue_ResetTypewriter(bodyText);
};

#endregion

#region Conversation runner

StartConversation = function(_speaker, _beats) {
	if (array_length(_beats) <= 0) {
		return;
	}
	
	EndConversation();
	SetActiveSpeaker(_speaker);
	conv_beats = _beats;
	conv_beat_index = 0;
	conv_active = true;
	dialogue_dim_background = true;
	active = true;
	choices = [];
	choice_index = 0;
	prompt_active = false;
	prompt_text = "";
	notice_timer = 0;
	ApplyConversationBeat();
};

AppendConversationBeats = function(_beats) {
	for (var i = 0; i < array_length(_beats); i++) {
		array_push(conv_beats, _beats[i]);
	}
};

EndConversation = function() {
	conv_active = false;
	conv_beats = [];
	conv_beat_index = 0;
	conv_beat_type = "";
	conv_pause_timer = 0;
	conv_line_pause_after = 0;
	conv_line_pause_active = false;
	Dialogue_ResetPresentationState();
};

ApplyConversationBeat = function() {
	if (!conv_active) {
		return;
	}
	
	if (conv_beat_index >= array_length(conv_beats)) {
		hide();
		return;
	}
	
	var beat = conv_beats[conv_beat_index];
	conv_beat_type = beat.type;
	choices = [];
	choice_index = 0;
	conv_line_pause_active = false;
	conv_line_pause_after = 0;
	choices_visible = false;
	
	switch (beat.type) {
		case DIALOGUE_BEAT_LINE:
			panel_speaker_name = beat.speaker;
			Dialogue_ResetTypewriter(beat.text);
			conv_line_pause_after = beat.pause_after;
			break;
		
		case DIALOGUE_BEAT_PAUSE:
			Dialogue_ResetTypewriter("");
			break;
		
		case DIALOGUE_BEAT_CHOICES:
			choices = beat.choices;
			Dialogue_ResetTypewriter(beat.prompt);
			break;
		
		case DIALOGUE_BEAT_ACTION:
			Dialogue_ResetTypewriter("");
			if (variable_struct_exists(beat, "fn")) {
				method(beat, beat.fn)();
			}
			AdvanceConversationBeat();
			break;
	}
};

AdvanceConversationBeat = function() {
	conv_beat_index += 1;
	conv_line_pause_active = false;
	conv_pause_timer = 0;
	ApplyConversationBeat();
};

Conversation_IsLineComplete = function() {
	return text_finished;
};

Conversation_SkipTypewriter = function() {
	Dialogue_FinishTypewriter();
};

Conversation_TryAdvance = function() {
	if (!conv_active || !text_finished) {
		return false;
	}
	
	if (conv_beat_type == DIALOGUE_BEAT_CHOICES) {
		if (!choices_visible) {
			Dialogue_FinishTypewriter();
			return true;
		}
		return false;
	}
	
	if (conv_beat_type == DIALOGUE_BEAT_PAUSE) {
		conv_pause_timer = 0;
		AdvanceConversationBeat();
		return true;
	}
	
	if (conv_line_pause_active) {
		conv_line_pause_active = false;
		AdvanceConversationBeat();
		return true;
	}
	
	if (conv_line_pause_after > 0) {
		conv_line_pause_active = true;
		conv_pause_timer = conv_line_pause_after;
		return true;
	}
	
	AdvanceConversationBeat();
	return true;
};

Conversation_TickPause = function() {
	if (!conv_active) {
		return;
	}
	
	if (conv_beat_type == DIALOGUE_BEAT_PAUSE && conv_pause_timer > 0) {
		conv_pause_timer -= 1;
		if (conv_pause_timer <= 0) {
			AdvanceConversationBeat();
		}
		return;
	}
	
	if (conv_line_pause_active && conv_pause_timer > 0) {
		conv_pause_timer -= 1;
		if (conv_pause_timer <= 0) {
			conv_line_pause_active = false;
			AdvanceConversationBeat();
		}
	}
};

#endregion

prompt = function(_text) {
	if (!active && notice_timer <= 0) {
		prompt_text = _text;
		prompt_active = true;
	}
};

clear_prompt = function() {
	if (!active) {
		prompt_text = "";
		prompt_active = false;
	}
};

notify = function(_text, _duration) {
	if (!active) {
		prompt_active = false;
		prompt_text = "";
		notice_text = _text;
		notice_timer = _duration;
	}
};

hide = function() {
	active = false;
	EndConversation();
	dialogue_dim_background = false;
	panel_speaker_name = "";
	SetActiveSpeaker(noone);
	player_movement_locked = false;
	choices = [];
	choice_index = 0;
	input_cooldown = 12;
	with (obj_player) {
		npc_talk_cooldown = 18;
	}
};

Dialogue_PlayerMovementLocked = function() {
	if (!active) {
		return false;
	}
	return player_movement_locked || choices_visible;
};

GetActiveSpeaker = function() {
	if (instance_exists(active_speaker)) {
		return active_speaker;
	}
	if (instance_exists(conversation_speaker)) {
		return conversation_speaker;
	}
	return noone;
};

ComputeDialogueLayout = function() {
	var layout = {
		valid: false,
		box_x1: 0,
		box_y1: 0,
		box_x2: 0,
		box_y2: 0,
		choice_rects: [],
		display_text: "",
		body_text: "",
		speaker_name: ""
	};
	
	if (!active) {
		return layout;
	}
	
	draw_set_font(fntSmaller);
	
	var bodyText = Dialogue_GetBodyTextForLayout();
	var speakerName = panel_speaker_name;
	if (speakerName == "") {
		speakerName = DialogueUI_GetSpeakerName(GetActiveSpeaker());
	}
	
	var padding = DIALOGUEUI_PADDING;
	var lineGap = DIALOGUEUI_LINE_GAP;
	var panelW = display_get_gui_width() * DIALOGUEUI_WIDTH_FACTOR;
	var textWidth = panelW - padding * 2;
	var nameRowH = (speakerName != "") ? DIALOGUEUI_NAME_GAP : 0;
	var bodyLines = max(1, ceil(string_width(bodyText) / max(1, textWidth)));
	var choicesBlockH = choices_visible ? DIALOGUEUI_CHOICE_TOP_GAP + array_length(choices) * DIALOGUEUI_CHOICE_ROW_HEIGHT : 0;
	
	var contentH = nameRowH + bodyLines * lineGap + choicesBlockH;
	var panelH = contentH + padding * 2;
	var panel = DialogueUI_GetPanelRect(panelH);
	
	layout.valid = true;
	layout.box_x1 = panel.x1;
	layout.box_y1 = panel.y1;
	layout.box_x2 = panel.x2;
	layout.box_y2 = panel.y2;
	layout.speaker_name = speakerName;
	layout.body_text = text_finished ? full_text : display_text;
	layout.display_text = layout.body_text;
	layout.padding_x = padding;
	layout.padding_y = padding;
	layout.line_gap = lineGap;
	layout.text_width = textWidth;
	layout.text_lines = bodyLines;
	
	var textX = layout.box_x1 + padding;
	var textY = layout.box_y1 + padding;
	if (speakerName != "") {
		textY += nameRowH;
	}
	
	var choicesY = textY + bodyLines * lineGap + DIALOGUEUI_CHOICE_TOP_GAP;
	if (choices_visible) {
		for (var i = 0; i < array_length(choices); ++i) {
			array_push(layout.choice_rects, {
				x1: textX,
				y1: choicesY + i * DIALOGUEUI_CHOICE_ROW_HEIGHT,
				x2: layout.box_x2 - padding,
				y2: choicesY + (i + 1) * DIALOGUEUI_CHOICE_ROW_HEIGHT - 2
			});
		}
	}
	
	return layout;
};

DrawDialogueLayout = function(_layout) {
	if (!_layout.valid) {
		return;
	}
	
	if (dialogue_dim_background) {
		draw_set_alpha(0.15);
		draw_set_color(c_black);
		draw_rectangle(0, 0, display_get_gui_width(), display_get_gui_height(), false);
		draw_set_alpha(1);
	}
	
	draw_set_alpha(0.88);
	draw_set_color(make_color_rgb(12, 12, 16));
	draw_rectangle(_layout.box_x1, _layout.box_y1, _layout.box_x2, _layout.box_y2, false);
	draw_set_alpha(1);
	draw_set_color(make_color_rgb(90, 90, 98));
	draw_rectangle(_layout.box_x1, _layout.box_y1, _layout.box_x2, _layout.box_y2, true);
	
	var textX = _layout.box_x1 + _layout.padding_x;
	var textY = _layout.box_y1 + _layout.padding_y;
	
	if (_layout.speaker_name != "") {
		draw_set_color(make_color_rgb(200, 196, 184));
		draw_text(textX, textY, _layout.speaker_name);
		textY += DIALOGUEUI_NAME_GAP;
	}
	
	draw_set_color(c_white);
	draw_text_ext(textX, textY, _layout.body_text, _layout.line_gap, _layout.text_width);
	
	if (!choices_visible) {
		draw_set_color(c_white);
		return;
	}
	
	for (var i = 0; i < array_length(choices); ++i) {
		if (i >= array_length(_layout.choice_rects)) {
			break;
		}
		
		var choiceText = choices[i];
		if (is_struct(choiceText)) {
			choiceText = choiceText.text;
		}
		
		var row = _layout.choice_rects[i];
		var isSelected = (i == choice_index);
		
		if (isSelected) {
			draw_set_alpha(0.22);
			draw_set_color(make_color_rgb(70, 72, 88));
			draw_rectangle(row.x1 - 4, row.y1 - 2, row.x2 + 4, row.y2 + 2, false);
			draw_set_alpha(1);
		}
		
		draw_set_color(isSelected ? c_white : make_color_rgb(210, 210, 215));
		draw_text(row.x1, row.y1, (isSelected ? "> " : "  ") + choiceText);
	}
	
	draw_set_color(c_white);
};

ActivateChoice = function(_index) {
	if (_index < 0 || _index >= array_length(choices)) {
		return;
	}
	
	choice_index = _index;
	var choice = choices[_index];
	
	if (is_struct(choice) && variable_struct_exists(choice, "action")) {
		var _action = choice.action;
		method(choice, _action)();
	} else {
		hide();
	}
};

IsMouseOverDialogueGui = function(_mx, _my) {
	if (!active) {
		return false;
	}
	
	var layout = ComputeDialogueLayout();
	if (!layout.valid) {
		return false;
	}
	
	return point_in_rectangle(_mx, _my, layout.box_x1, layout.box_y1, layout.box_x2, layout.box_y2);
};

Conversation_WantsChoiceInput = function() {
	return conv_active && choices_visible;
};

Conversation_WantsAdvanceInput = function() {
	if (!conv_active || !text_finished || choices_visible) {
		return false;
	}
	
	if (conv_beat_type == DIALOGUE_BEAT_LINE) {
		return true;
	}
	if (conv_beat_type == DIALOGUE_BEAT_PAUSE) {
		return true;
	}
	return false;
};

Dialogue_HandleChoiceInput = function(_layout, _mouse_gui_x, _mouse_gui_y, _confirm_choice) {
	if (!choices_visible || array_length(choices) <= 0) {
		return false;
	}
	
	if (keyboard_check_pressed(ord("W"))) {
		choice_index -= 1;
	}
	if (keyboard_check_pressed(ord("S"))) {
		choice_index += 1;
	}
	choice_index = clamp(choice_index, 0, array_length(choices) - 1);
	
	var confirm_choice = _confirm_choice;
	
	if (_layout.valid && array_length(_layout.choice_rects) > 0) {
		var hovered_choice = -1;
		for (var i = 0; i < array_length(_layout.choice_rects); ++i) {
			var row = _layout.choice_rects[i];
			if (point_in_rectangle(_mouse_gui_x, _mouse_gui_y, row.x1, row.y1, row.x2, row.y2)) {
				hovered_choice = i;
			}
		}
		
		if (hovered_choice >= 0) {
			choice_index = hovered_choice;
			if (mouse_check_button_pressed(mb_left)) {
				confirm_choice = true;
			}
		}
	}
	
	if (confirm_choice) {
		ActivateChoice(choice_index);
		input_cooldown = 6;
		return true;
	}
	
	return false;
};
