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

// Paced conversation mode
conv_active = false;
conv_beats = [];
conv_beat_index = 0;
conv_beat_type = "";
conv_pause_timer = 0;
conv_line_pause_after = 0;
conv_line_pause_active = false;
typewriter_revealed = 0;
typewriter_target_length = 0;
conv_show_continue_hint = false;
panel_speaker_name = "";
dialogue_dim_background = false;

#region Legacy menu API

SetActiveSpeaker = function(_speaker) {
	active_speaker = _speaker;
	conversation_speaker = _speaker;
	anchor_to_speaker = instance_exists(_speaker);
};

show = function(_text, _choices) {
	EndConversation();
	player_movement_locked = false;
	text = _text;
	prompt_active = false;
	prompt_text = "";
	notice_timer = 0;
	
	if (array_length(_choices) == 0) {
		choices = [
			{
				text: "OK",
				action: function() {
					with (obj_dialogue) {
						hide();
					}
				}
			}
		];
	} else {
		choices = _choices;
	}
	
	choice_index = 0;
	active = true;
	conv_active = false;
	dialogue_dim_background = false;
	panel_speaker_name = DialogueUI_GetSpeakerName(GetActiveSpeaker());
	if (panel_speaker_name == "") {
		var parsed = DialogueUI_ParseFormattedLine(_text);
		panel_speaker_name = parsed.speaker;
	}
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
	typewriter_revealed = 0;
	typewriter_target_length = 0;
	conv_show_continue_hint = false;
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
	conv_show_continue_hint = false;
	conv_line_pause_active = false;
	conv_line_pause_after = 0;
	
	switch (beat.type) {
		case DIALOGUE_BEAT_LINE:
			panel_speaker_name = beat.speaker;
			text = beat.text;
			typewriter_target_length = string_length(text);
			typewriter_revealed = 0;
			conv_line_pause_after = beat.pause_after;
			break;
		
		case DIALOGUE_BEAT_PAUSE:
			typewriter_revealed = string_length(text);
			typewriter_target_length = string_length(text);
			conv_pause_timer = beat.frames;
			conv_show_continue_hint = false;
			break;
		
		case DIALOGUE_BEAT_CHOICES:
			text = beat.prompt;
			if (text != "") {
				typewriter_target_length = string_length(text);
				typewriter_revealed = 0;
			} else {
				typewriter_revealed = 0;
				typewriter_target_length = 0;
			}
			choices = beat.choices;
			choice_index = 0;
			break;
		
		case DIALOGUE_BEAT_ACTION:
			text = "";
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
	return typewriter_revealed >= typewriter_target_length;
};

Conversation_GetDisplayText = function() {
	if (!conv_active) {
		return text;
	}
	if (conv_beat_type == DIALOGUE_BEAT_PAUSE) {
		return "";
	}
	return string_copy(text, 1, typewriter_revealed);
};

Conversation_TickTypewriter = function() {
	if (!conv_active || conv_beat_type != DIALOGUE_BEAT_LINE) {
		if (conv_active && conv_beat_type == DIALOGUE_BEAT_CHOICES && text != "" && !Conversation_IsLineComplete()) {
			typewriter_revealed = min(typewriter_target_length, typewriter_revealed + DIALOGUE_TYPEWRITER_CHARS_PER_FRAME);
			conv_show_continue_hint = Conversation_IsLineComplete() && array_length(choices) == 0;
		}
		return;
	}
	
	if (!Conversation_IsLineComplete()) {
		typewriter_revealed = min(typewriter_target_length, typewriter_revealed + DIALOGUE_TYPEWRITER_CHARS_PER_FRAME);
	}
	
	conv_show_continue_hint = Conversation_IsLineComplete();
};

Conversation_SkipTypewriter = function() {
	typewriter_revealed = typewriter_target_length;
	conv_show_continue_hint = true;
};

Conversation_TryAdvance = function() {
	if (!conv_active) {
		return false;
	}
	
	if (conv_beat_type == DIALOGUE_BEAT_CHOICES) {
		if (text != "" && !Conversation_IsLineComplete()) {
			Conversation_SkipTypewriter();
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
	
	if (!Conversation_IsLineComplete()) {
		Conversation_SkipTypewriter();
		return true;
	}
	
	if (conv_line_pause_after > 0) {
		conv_line_pause_active = true;
		conv_pause_timer = conv_line_pause_after;
		conv_show_continue_hint = false;
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
	text = "";
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
	return player_movement_locked || Conversation_WantsChoiceInput();
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
	
	var bodyText = conv_active ? Conversation_GetDisplayText() : text;
	var parsed = DialogueUI_ParseFormattedLine(bodyText);
	var speakerName = panel_speaker_name;
	if (speakerName == "") {
		speakerName = parsed.speaker;
	}
	if (speakerName == "") {
		speakerName = DialogueUI_GetSpeakerName(GetActiveSpeaker());
	}
	if (!conv_active && parsed.speaker != "") {
		bodyText = parsed.body;
	}
	var padding = DIALOGUEUI_PADDING;
	var lineGap = DIALOGUEUI_LINE_GAP;
	var panelW = display_get_gui_width() * DIALOGUEUI_WIDTH_FACTOR;
	var textWidth = panelW - padding * 2;
	var nameRowH = (speakerName != "") ? DIALOGUEUI_NAME_GAP : 0;
	var bodyLines = max(1, ceil(string_width(bodyText) / max(1, textWidth)));
	var showContinue = conv_active && conv_show_continue_hint && array_length(choices) == 0;
	var continueH = showContinue ? DIALOGUEUI_LINE_GAP + DIALOGUEUI_CONTINUE_GAP : 0;
	var showChoices = array_length(choices) > 0 && (!conv_active || Conversation_WantsChoiceInput());
	var choicesBlockH = showChoices ? DIALOGUEUI_CHOICE_TOP_GAP + array_length(choices) * DIALOGUEUI_CHOICE_ROW_HEIGHT : 0;
	
	var contentH = nameRowH + bodyLines * lineGap + continueH + choicesBlockH;
	var panelH = contentH + padding * 2;
	var panel = DialogueUI_GetPanelRect(panelH);
	
	layout.valid = true;
	layout.box_x1 = panel.x1;
	layout.box_y1 = panel.y1;
	layout.box_x2 = panel.x2;
	layout.box_y2 = panel.y2;
	layout.speaker_name = speakerName;
	layout.body_text = bodyText;
	layout.display_text = bodyText;
	layout.padding_x = padding;
	layout.padding_y = padding;
	layout.line_gap = lineGap;
	layout.text_width = textWidth;
	layout.text_lines = bodyLines;
	layout.show_continue = showContinue;
	
	var textX = layout.box_x1 + padding;
	var textY = layout.box_y1 + padding;
	if (speakerName != "") {
		textY += nameRowH;
	}
	
	var choicesY = textY + bodyLines * lineGap + continueH + DIALOGUEUI_CHOICE_TOP_GAP;
	if (showChoices) {
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
	
	if (_layout.show_continue) {
		draw_set_color(make_color_rgb(160, 160, 168));
		var hintY = textY + _layout.text_lines * _layout.line_gap + DIALOGUEUI_CONTINUE_GAP;
		draw_text(textX, hintY, "— E / Click —");
		draw_set_color(c_white);
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
	if (!conv_active || conv_beat_type != DIALOGUE_BEAT_CHOICES) {
		return false;
	}
	if (text != "" && !Conversation_IsLineComplete()) {
		return false;
	}
	return array_length(choices) > 0;
};

Conversation_WantsAdvanceInput = function() {
	if (!conv_active) {
		return false;
	}
	if (Conversation_WantsChoiceInput()) {
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
